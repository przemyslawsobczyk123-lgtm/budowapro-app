import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';

import 'release_support.dart';

Future<void> main(List<String> arguments) async {
  try {
    final options = parseReleaseOptions(arguments);
    if (options.showHelp) {
      stdout.write(_usage);
      return;
    }

    final environment = validateReleaseEnvironment(
      Platform.environment,
      validationOnly: options.validationOnly,
    );
    final repository = await _Repository.open(Directory.current);
    final builder = _AndroidReleaseBuilder(
      repository: repository,
      environment: environment,
      options: options,
    );
    await builder.build();
  } on ReleaseFailure catch (error) {
    stderr.writeln('Release failed: ${error.message}');
    exitCode = 1;
  } on ProcessException catch (error) {
    stderr.writeln(
      'Release failed: could not start ${error.executable}. '
      'Check the required Android and Flutter tooling.',
    );
    exitCode = 1;
  } on Object catch (error) {
    stderr.writeln('Release failed: ${error.runtimeType}.');
    exitCode = 1;
  }
}

const String _usage = '''
BudowaPRO Android production release

Usage:
  dart run tool/release/build_android_release.dart [--allow-dirty] [--validation]

Options:
  --allow-dirty  Permit a release from a dirty Git worktree.
  --validation   Permit reserved test metadata and mark artifacts test-only.
  -h, --help     Show this help.

Required environment variables:
  BUDOWAPRO_UPLOAD_STORE_FILE
  BUDOWAPRO_UPLOAD_STORE_PASSWORD
  BUDOWAPRO_UPLOAD_KEY_ALIAS
  BUDOWAPRO_UPLOAD_KEY_PASSWORD
  BUDOWAPRO_UPLOAD_CERT_SHA256
  BUDOWAPRO_PUBLISHER_NAME
  BUDOWAPRO_PRIVACY_CONTACT_EMAIL
  BUDOWAPRO_PRIVACY_POLICY_URL
''';

final class _AndroidReleaseBuilder {
  _AndroidReleaseBuilder({
    required this.repository,
    required this.environment,
    required this.options,
  });

  final _Repository repository;
  final ReleaseEnvironment environment;
  final ReleaseOptions options;

  Future<void> build() async {
    final uploadStoreFile = await _requireReadableUploadKeystore();
    final keytool = _findExecutable('keytool');
    final uploadCertificateSha256 = await _verifyUploadCertificate(
      keytool: keytool,
      storeFile: uploadStoreFile,
    );

    final sourceWasDirty = await repository.isDirty();
    if (sourceWasDirty && !options.allowDirty) {
      throw const ReleaseFailure(
        'Git worktree is dirty. Commit all source changes or explicitly use '
        '--allow-dirty.',
      );
    }

    final pubspec = File(_join(repository.root.path, 'pubspec.yaml'));
    final version = parsePubspecVersion(await pubspec.readAsString());
    final commit = await repository.commitSha();

    await _validateAndroidReleaseConfiguration();
    await _verifyPrivacyPolicyUrl(environment.privacyPolicyUrl);
    await _runQualityGates();

    if (!options.allowDirty && await repository.isDirty()) {
      throw const ReleaseFailure(
        'Quality gates changed tracked source files. Review and commit them '
        'before building a release.',
      );
    }

    final jarsigner = _findExecutable('jarsigner');
    final java = _findExecutable('java');
    final zipalign = _findAndroidBuildTool('zipalign');
    final bundletool = await _ensureBundletool(repository.root);
    final runStartedAt = DateTime.now().toUtc();
    final releaseDirectory = Directory(
      _joinAll(<String>[
        repository.root.path,
        'build',
        'releases',
        sanitizePathSegment(version),
        _releaseRunId(runStartedAt),
      ]),
    );
    final dartSymbolsDirectory = Directory(
      _joinAll(<String>[releaseDirectory.path, 'symbols', 'dart']),
    );
    await dartSymbolsDirectory.create(recursive: true);
    final obfuscationMap = File(
      _join(dartSymbolsDirectory.path, 'obfuscation-map.json'),
    );

    await repository.runFlutter(
      'Build signed, obfuscated Android App Bundle',
      buildAppBundleArguments(
        environment: environment,
        dartSymbolsDirectory: dartSymbolsDirectory.absolute.path,
        obfuscationMapFile: obfuscationMap.absolute.path,
      ),
    );

    final builtBundle = File(
      _joinAll(<String>[
        repository.root.path,
        'build',
        'app',
        'outputs',
        'bundle',
        'release',
        'app-release.aab',
      ]),
    );
    if (!await _isRegularFile(builtBundle) || await builtBundle.length() == 0) {
      throw const ReleaseFailure(
        'Flutter did not produce build/app/outputs/bundle/release/'
        'app-release.aab.',
      );
    }

    final archivedBundle = File(
      _join(
        releaseDirectory.path,
        'BudowaPRO-${sanitizePathSegment(version)}.aab',
      ),
    );
    final candidateBundle = File('${archivedBundle.path}.candidate');
    await candidateBundle.parent.create(recursive: true);
    await builtBundle.copy(candidateBundle.path);

    final signature = await repository
        .capture('Verify AAB signature', jarsigner, <String>[
          '-J-Duser.language=en',
          '-J-Duser.country=US',
          '-verify',
          candidateBundle.absolute.path,
        ]);
    requireJarsignerVerification('${signature.stdout}\n${signature.stderr}');
    final bundleCertificate = await repository
        .capture('Verify AAB signing certificate', keytool, <String>[
          '-J-Duser.language=en',
          '-J-Duser.country=US',
          '-printcert',
          '-jarfile',
          candidateBundle.absolute.path,
        ]);
    requireExpectedCertificateSha256(
      expected: uploadCertificateSha256,
      actual: certificateSha256FromKeytool(
        '${bundleCertificate.stdout}\n${bundleCertificate.stderr}',
      ),
    );

    final bundleConfig = await repository
        .capture('Inspect AAB page alignment', java, <String>[
          '-jar',
          bundletool.absolute.path,
          'dump',
          'config',
          '--bundle=${candidateBundle.absolute.path}',
        ]);
    require16KbPageAlignment(bundleConfig.stdout);

    final manifest = await repository
        .capture('Inspect release manifest permissions', java, <String>[
          '-jar',
          bundletool.absolute.path,
          'dump',
          'manifest',
          '--bundle=${candidateBundle.absolute.path}',
        ]);
    if (manifest.stdout.trim().isEmpty) {
      throw const ReleaseFailure(
        'bundletool returned an empty release manifest.',
      );
    }
    requireSafeManifest(manifest.stdout);

    final aabNativeLibraryCount = await _verify64BitNativeLibraries(
      candidateBundle,
    );
    final apkVerification = await _verifyUniversalApk(
      repository: repository,
      java: java,
      zipalign: zipalign,
      bundletool: bundletool,
      bundle: candidateBundle,
      workingDirectory: releaseDirectory,
    );

    await candidateBundle.rename(archivedBundle.path);
    final aabSha256 = await _sha256File(archivedBundle);

    final symbols = await _archiveAvailableSymbols(
      repositoryRoot: repository.root,
      releaseDirectory: releaseDirectory,
      dartSymbolsDirectory: dartSymbolsDirectory,
    );
    final metadata = <String, Object?>{
      'schemaVersion': 2,
      'application': 'BudowaPRO',
      'platform': 'android',
      'version': version,
      'createdAtUtc': runStartedAt.toIso8601String(),
      'gitCommit': commit,
      'sourceWasDirty': sourceWasDirty,
      'validationOnly': options.validationOnly,
      'aab': <String, Object?>{
        'file': _relativePath(releaseDirectory, archivedBundle),
        'byteSize': await archivedBundle.length(),
        'sha256': aabSha256,
      },
      'verification': <String, Object?>{
        'jarsignerVerified': true,
        'uploadCertificateSha256': uploadCertificateSha256,
        'manifestPermissions': expectedManifestPermissions.toList()..sort(),
        'pageAlignment': <String, Object?>{
          'bundleConfig': 'PAGE_ALIGNMENT_16K',
          'aab64BitElfLibraries': aabNativeLibraryCount,
          'universalApk64BitElfLibraries': apkVerification.nativeLibraryCount,
          'universalApkZipalign16Kb': true,
        },
      },
      'symbols': symbols,
      'tooling': <String, Object?>{
        'bundletoolVersion': bundletoolVersion,
        'bundletoolSha256': bundletoolSha256,
        'dartVersion': Platform.version.split(' ').first,
      },
    };
    final metadataFile = File(
      _join(releaseDirectory.path, 'release-metadata.json'),
    );
    await metadataFile.writeAsString(
      '${const JsonEncoder.withIndent('  ').convert(metadata)}\n',
      flush: true,
    );

    stdout.writeln('');
    stdout.writeln('Release verified.');
    stdout.writeln(
      'Artifacts: ${_relativePath(repository.root, releaseDirectory)}',
    );
    stdout.writeln('AAB SHA-256: $aabSha256');
  }

  Future<File> _requireReadableUploadKeystore() async {
    final configuredPath = environment.uploadStoreFile;
    final storeFile = _isAbsolutePath(configuredPath)
        ? File(configuredPath)
        : File(
            _joinAll(<String>[repository.root.path, 'android', configuredPath]),
          );
    if (!await _isRegularFile(storeFile)) {
      throw const ReleaseFailure(
        'BUDOWAPRO_UPLOAD_STORE_FILE does not point to a readable file.',
      );
    }
    try {
      await storeFile.openRead(0, 1).drain<void>();
    } on FileSystemException {
      throw const ReleaseFailure(
        'BUDOWAPRO_UPLOAD_STORE_FILE does not point to a readable file.',
      );
    }
    return storeFile;
  }

  Future<String> _verifyUploadCertificate({
    required String keytool,
    required File storeFile,
  }) async {
    final certificate = await repository
        .capture('Verify upload certificate', keytool, <String>[
          '-J-Duser.language=en',
          '-J-Duser.country=US',
          '-list',
          '-v',
          '-keystore',
          storeFile.absolute.path,
          '-alias',
          environment.uploadKeyAlias,
          '-storepass:env',
          'BUDOWAPRO_UPLOAD_STORE_PASSWORD',
        ]);
    final actual = certificateSha256FromKeytool(
      '${certificate.stdout}\n${certificate.stderr}',
    );
    requireExpectedCertificateSha256(
      expected: environment.uploadCertificateSha256,
      actual: actual,
    );
    return actual;
  }

  Future<void> _validateAndroidReleaseConfiguration() async {
    final appDirectory = _joinAll(<String>[
      repository.root.path,
      'android',
      'app',
    ]);
    final buildGradle = File(_join(appDirectory, 'build.gradle.kts'));
    final proguardRules = File(_join(appDirectory, 'proguard-rules.pro'));
    if (!await _isRegularFile(buildGradle) ||
        !await _isRegularFile(proguardRules)) {
      throw const ReleaseFailure(
        'Android release shrinker configuration is incomplete.',
      );
    }
    requireAndroidReleaseShrinkerConfiguration(
      buildGradle: await buildGradle.readAsString(),
      proguardRules: await proguardRules.readAsString(),
    );
  }

  Future<void> _runQualityGates() async {
    await repository.runFlutter('Resolve Flutter dependencies', const <String>[
      'pub',
      'get',
    ]);
    await repository.runFlutter(
      'Generate Flutter localizations',
      const <String>['gen-l10n'],
    );
    await repository.run(
      'Check Dart formatting',
      Platform.resolvedExecutable,
      const <String>[
        'format',
        '--output=none',
        '--set-exit-if-changed',
        'lib',
        'test',
        'tool',
      ],
    );
    await repository.runFlutter('Analyze Flutter project', const <String>[
      'analyze',
    ]);
    await repository.runFlutter('Run Flutter tests', const <String>['test']);
  }
}

final class _ApkVerification {
  const _ApkVerification({required this.nativeLibraryCount});

  final int nativeLibraryCount;
}

Future<_ApkVerification> _verifyUniversalApk({
  required _Repository repository,
  required String java,
  required String zipalign,
  required File bundletool,
  required File bundle,
  required Directory workingDirectory,
}) async {
  final apkSet = File(_join(workingDirectory.path, 'alignment-check.apks'));
  final universalApk = File(
    _join(workingDirectory.path, 'alignment-check-universal.apk'),
  );
  try {
    await repository
        .run('Build universal APK for 16 KB verification', java, <String>[
          '-jar',
          bundletool.absolute.path,
          'build-apks',
          '--bundle=${bundle.absolute.path}',
          '--output=${apkSet.absolute.path}',
          '--mode=universal',
          '--overwrite',
        ]);
    await _extractUniversalApk(apkSet: apkSet, output: universalApk);
    final nativeLibraryCount = await _verify64BitNativeLibraries(universalApk);
    await repository.capture(
      'Verify universal APK ZIP alignment',
      zipalign,
      <String>['-c', '-P', '16', '-v', '4', universalApk.absolute.path],
    );
    return _ApkVerification(nativeLibraryCount: nativeLibraryCount);
  } finally {
    await _deleteIfPresent(universalApk);
    await _deleteIfPresent(apkSet);
  }
}

Future<void> _extractUniversalApk({
  required File apkSet,
  required File output,
}) async {
  final input = InputFileStream(apkSet.path);
  try {
    final archive = ZipDecoder().decodeStream(input);
    final candidates = archive
        .where(
          (entry) =>
              entry.isFile &&
              (entry.name.replaceAll(r'\', '/').endsWith('/universal.apk') ||
                  entry.name == 'universal.apk'),
        )
        .toList(growable: false);
    if (candidates.length != 1) {
      throw const ReleaseFailure(
        'bundletool did not produce exactly one universal APK.',
      );
    }
    final bytes = candidates.single.readBytes();
    if (bytes == null || bytes.isEmpty) {
      throw const ReleaseFailure('The universal APK is empty.');
    }
    await output.writeAsBytes(bytes, flush: true);
  } finally {
    await input.close();
  }
}

Future<int> _verify64BitNativeLibraries(File zipFile) async {
  final input = InputFileStream(zipFile.path);
  var count = 0;
  try {
    final archive = ZipDecoder().decodeStream(input);
    for (final entry in archive) {
      if (!entry.isFile || !is64BitAndroidNativeLibrary(entry.name)) {
        continue;
      }
      final bytes = entry.readBytes();
      if (bytes == null) {
        throw ReleaseFailure('Could not read native library ${entry.name}.');
      }
      require64BitElfLoadAlignment(name: entry.name, bytes: bytes);
      count++;
    }
  } finally {
    await input.close();
  }
  if (count == 0) {
    throw const ReleaseFailure(
      'The Android artifact contains no 64-bit native libraries.',
    );
  }
  return count;
}

final class _Repository {
  _Repository._({
    required this.root,
    required this.gitExecutable,
    required this.flutterCommand,
  });

  final Directory root;
  final String gitExecutable;
  final _ToolCommand flutterCommand;

  static Future<_Repository> open(Directory workingDirectory) async {
    final git = _findExecutable('git');
    final result = await _captureProcess(git, const <String>[
      'rev-parse',
      '--show-toplevel',
    ], workingDirectory: workingDirectory.path);
    if (result.exitCode != 0 || result.stdout.trim().isEmpty) {
      throw const ReleaseFailure(
        'Run this command inside the BudowaPRO Git repository.',
      );
    }

    final root = Directory(result.stdout.trim());
    final hasPubspec = await _isRegularFile(
      File(_join(root.path, 'pubspec.yaml')),
    );
    final hasAndroid = await Directory(_join(root.path, 'android')).exists();
    if (!hasPubspec || !hasAndroid) {
      throw const ReleaseFailure(
        'The Git root is not a Flutter Android repository.',
      );
    }

    return _Repository._(
      root: root,
      gitExecutable: git,
      flutterCommand: _resolveFlutterCommand(),
    );
  }

  Future<bool> isDirty() async {
    final result = await capture(
      'Check Git worktree',
      gitExecutable,
      const <String>['status', '--porcelain', '--untracked-files=all'],
      announce: false,
    );
    return result.stdout.trim().isNotEmpty;
  }

  Future<String> commitSha() async {
    final result = await capture(
      'Read Git commit',
      gitExecutable,
      const <String>['rev-parse', 'HEAD'],
      announce: false,
    );
    final value = result.stdout.trim();
    if (!RegExp(r'^[a-f0-9]{40}$').hasMatch(value)) {
      throw const ReleaseFailure('Could not determine the Git commit SHA.');
    }
    return value;
  }

  Future<void> runFlutter(String label, List<String> arguments) {
    return run(label, flutterCommand.executable, <String>[
      ...flutterCommand.prefixArguments,
      ...arguments,
    ]);
  }

  Future<void> run(
    String label,
    String executable,
    List<String> arguments,
  ) async {
    stdout.writeln('[release] $label');
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: root.path,
      runInShell: false,
    );
    final stdoutDone = stdout.addStream(process.stdout);
    final stderrDone = stderr.addStream(process.stderr);
    final processExitCode = await process.exitCode;
    await Future.wait<void>(<Future<void>>[stdoutDone, stderrDone]);
    if (processExitCode != 0) {
      throw ReleaseFailure('$label failed with exit code $processExitCode.');
    }
  }

  Future<_CapturedProcess> capture(
    String label,
    String executable,
    List<String> arguments, {
    bool announce = true,
  }) async {
    if (announce) {
      stdout.writeln('[release] $label');
    }
    final result = await _captureProcess(
      executable,
      arguments,
      workingDirectory: root.path,
    );
    if (result.exitCode != 0) {
      if (result.stderr.trim().isNotEmpty) {
        stderr.write(result.stderr);
        if (!result.stderr.endsWith('\n')) {
          stderr.writeln();
        }
      }
      throw ReleaseFailure('$label failed with exit code ${result.exitCode}.');
    }
    return result;
  }
}

final class _ToolCommand {
  const _ToolCommand(this.executable, this.prefixArguments);

  final String executable;
  final List<String> prefixArguments;
}

final class _CapturedProcess {
  const _CapturedProcess({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  final int exitCode;
  final String stdout;
  final String stderr;
}

Future<_CapturedProcess> _captureProcess(
  String executable,
  List<String> arguments, {
  required String workingDirectory,
}) async {
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    runInShell: false,
  );
  final stdoutFuture = process.stdout
      .transform(const Utf8Decoder(allowMalformed: true))
      .join();
  final stderrFuture = process.stderr
      .transform(const Utf8Decoder(allowMalformed: true))
      .join();
  final results = await Future.wait<Object>(<Future<Object>>[
    process.exitCode,
    stdoutFuture,
    stderrFuture,
  ]);
  return _CapturedProcess(
    exitCode: results[0] as int,
    stdout: results[1] as String,
    stderr: results[2] as String,
  );
}

_ToolCommand _resolveFlutterCommand() {
  final flutterRoot = _findFlutterRoot();
  if (flutterRoot != null) {
    final snapshot = File(
      _joinAll(<String>[
        flutterRoot.path,
        'bin',
        'cache',
        'flutter_tools.snapshot',
      ]),
    );
    final packageConfig = File(
      _joinAll(<String>[
        flutterRoot.path,
        'packages',
        'flutter_tools',
        '.dart_tool',
        'package_config.json',
      ]),
    );
    if (snapshot.existsSync() && packageConfig.existsSync()) {
      return _ToolCommand(Platform.resolvedExecutable, <String>[
        '--packages=${packageConfig.absolute.path}',
        snapshot.absolute.path,
      ]);
    }
  }

  if (Platform.isWindows) {
    throw const ReleaseFailure(
      'Could not safely locate the Flutter tool snapshot on Windows.',
    );
  }
  return _ToolCommand(_findExecutable('flutter'), const <String>[]);
}

Directory? _findFlutterRoot() {
  final configured = Platform.environment.entries
      .where((entry) => entry.key.toUpperCase() == 'FLUTTER_ROOT')
      .map((entry) => entry.value.trim())
      .where((value) => value.isNotEmpty)
      .firstOrNull;
  if (configured != null) {
    final directory = Directory(configured);
    if (directory.existsSync()) {
      return directory;
    }
  }

  var inferred = File(Platform.resolvedExecutable).parent;
  for (var index = 0; index < 4; index++) {
    inferred = inferred.parent;
  }
  if (File(
    _joinAll(<String>[inferred.path, 'bin', 'cache', 'flutter_tools.snapshot']),
  ).existsSync()) {
    return inferred;
  }

  final flutter = _findExecutableOrNull(
    Platform.isWindows ? 'flutter.bat' : 'flutter',
  );
  return flutter == null ? null : File(flutter).parent.parent;
}

String _findExecutable(String name) {
  final executable = _findExecutableOrNull(name);
  if (executable == null) {
    throw ReleaseFailure(
      'Required executable is not available on PATH: $name.',
    );
  }
  return executable;
}

String _findAndroidBuildTool(String name) {
  final sdkRoot = Platform.environment.entries
      .where(
        (entry) =>
            entry.key.toUpperCase() == 'ANDROID_SDK_ROOT' ||
            entry.key.toUpperCase() == 'ANDROID_HOME',
      )
      .map((entry) => entry.value.trim())
      .where((value) => value.isNotEmpty)
      .firstOrNull;
  if (sdkRoot != null) {
    final buildTools = Directory(_joinAll(<String>[sdkRoot, 'build-tools']));
    if (buildTools.existsSync()) {
      final versions =
          buildTools
              .listSync(followLinks: false)
              .whereType<Directory>()
              .toList()
            ..sort((left, right) => right.path.compareTo(left.path));
      final executableName = Platform.isWindows ? '$name.exe' : name;
      for (final version in versions) {
        final candidate = File(_join(version.path, executableName));
        if (candidate.existsSync()) return candidate.absolute.path;
      }
    }
  }
  return _findExecutable(name);
}

String? _findExecutableOrNull(String name) {
  final path = Platform.environment.entries
      .where((entry) => entry.key.toUpperCase() == 'PATH')
      .map((entry) => entry.value)
      .firstOrNull;
  if (path == null) {
    return null;
  }

  final names = <String>{
    name,
    if (Platform.isWindows && !name.toLowerCase().endsWith('.exe')) '$name.exe',
  };
  for (final directoryPath in path.split(Platform.isWindows ? ';' : ':')) {
    final directory = directoryPath.trim().replaceAll(RegExp(r'^"|"$'), '');
    if (directory.isEmpty) {
      continue;
    }
    for (final candidateName in names) {
      final candidate = File(_join(directory, candidateName));
      if (candidate.existsSync()) {
        return candidate.absolute.path;
      }
    }
  }
  return null;
}

Future<void> _deleteIfPresent(File file) async {
  try {
    if (await file.exists()) await file.delete();
  } on FileSystemException {
    // Verification artifacts are ignored and retried by the next release run.
  }
}

Future<void> _verifyPrivacyPolicyUrl(String value) async {
  stdout.writeln('[release] Verify public privacy policy URL');
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  try {
    final request = await client.getUrl(Uri.parse(value));
    request.headers.set(HttpHeaders.acceptHeader, 'text/html');
    final response = await request.close().timeout(const Duration(seconds: 20));
    final contentType = response.headers.contentType?.mimeType;
    final redirectsAreHttps = response.redirects.every(
      (redirect) =>
          redirect.location.scheme.isEmpty ||
          redirect.location.scheme == 'https',
    );
    await response.take(1).drain<void>();
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        !redirectsAreHttps ||
        contentType != 'text/html') {
      throw const ReleaseFailure(
        'The privacy policy URL must return successful public HTML.',
      );
    }
  } on ReleaseFailure {
    rethrow;
  } on Object {
    throw const ReleaseFailure(
      'The privacy policy URL could not be verified as public HTML.',
    );
  } finally {
    client.close(force: true);
  }
}

Future<File> _ensureBundletool(Directory repositoryRoot) async {
  final directory = Directory(
    _joinAll(<String>[repositoryRoot.path, 'build', 'tools']),
  );
  await directory.create(recursive: true);
  final target = File(
    _join(directory.path, 'bundletool-all-$bundletoolVersion.jar'),
  );

  if (await _isRegularFile(target)) {
    if ((await _sha256File(target)).toUpperCase() == bundletoolSha256) {
      stdout.writeln('[release] Use verified bundletool $bundletoolVersion');
      return target;
    }
    await target.delete();
  }

  stdout.writeln('[release] Download bundletool $bundletoolVersion');
  final partial = File('${target.path}.part');
  if (await partial.exists()) {
    await partial.delete();
  }

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  try {
    final request = await client.getUrl(Uri.parse(bundletoolDownloadUrl));
    final response = await request.close().timeout(const Duration(seconds: 30));
    if (response.statusCode != HttpStatus.ok) {
      await response.drain<void>();
      throw ReleaseFailure(
        'bundletool download returned HTTP ${response.statusCode}.',
      );
    }
    const maxBundletoolBytes = 64 * 1024 * 1024;
    if (response.contentLength > maxBundletoolBytes) {
      await response.drain<void>();
      throw const ReleaseFailure('bundletool download is unexpectedly large.');
    }
    await _writeBoundedDownload(
      response,
      partial,
      maxBytes: maxBundletoolBytes,
    );
  } on ReleaseFailure {
    rethrow;
  } on Object {
    throw const ReleaseFailure('Could not download bundletool.');
  } finally {
    client.close(force: true);
  }

  final digest = (await _sha256File(partial)).toUpperCase();
  if (digest != bundletoolSha256) {
    await partial.delete();
    throw const ReleaseFailure(
      'Downloaded bundletool failed SHA-256 verification.',
    );
  }
  await partial.rename(target.path);
  return target;
}

Future<Map<String, Object?>> _archiveAvailableSymbols({
  required Directory repositoryRoot,
  required Directory releaseDirectory,
  required Directory dartSymbolsDirectory,
}) async {
  final androidSymbolsDirectory = Directory(
    _joinAll(<String>[releaseDirectory.path, 'symbols', 'android']),
  );
  final mappingSource = File(
    _joinAll(<String>[
      repositoryRoot.path,
      'build',
      'app',
      'outputs',
      'mapping',
      'release',
      'mapping.txt',
    ]),
  );
  String? mappingPath;
  if (await _isRegularFile(mappingSource)) {
    final mappingTarget = File(
      _join(androidSymbolsDirectory.path, 'mapping.txt'),
    );
    await mappingTarget.parent.create(recursive: true);
    await mappingSource.copy(mappingTarget.path);
    mappingPath = _relativePath(releaseDirectory, mappingTarget);
  }

  final nativeSources = <MapEntry<String, FileSystemEntity>>[
    MapEntry<String, FileSystemEntity>(
      'native-debug-symbols',
      Directory(
        _joinAll(<String>[
          repositoryRoot.path,
          'build',
          'app',
          'outputs',
          'native-debug-symbols',
          'release',
        ]),
      ),
    ),
    MapEntry<String, FileSystemEntity>(
      'native-symbol-tables',
      Directory(
        _joinAll(<String>[
          repositoryRoot.path,
          'build',
          'app',
          'intermediates',
          'native_symbol_tables',
          'release',
        ]),
      ),
    ),
  ];
  final nativePaths = <String>[];
  for (final source in nativeSources) {
    if (source.value is Directory &&
        await (source.value as Directory).exists()) {
      final target = Directory(_join(androidSymbolsDirectory.path, source.key));
      await _copyDirectory(source.value as Directory, target);
      nativePaths.addAll(await _filesRelativeTo(releaseDirectory, target));
    }
  }

  return <String, Object?>{
    'dart': await _filesRelativeTo(releaseDirectory, dartSymbolsDirectory),
    'androidMapping': mappingPath,
    'native': nativePaths..sort(),
  };
}

Future<void> _copyDirectory(Directory source, Directory destination) async {
  await destination.create(recursive: true);
  await for (final entity in source.list(recursive: true, followLinks: false)) {
    if (entity is! File) {
      continue;
    }
    final relative = entity.absolute.path.substring(
      source.absolute.path.length + 1,
    );
    final target = File(_join(destination.path, relative));
    await target.parent.create(recursive: true);
    await entity.copy(target.path);
  }
}

Future<List<String>> _filesRelativeTo(
  Directory root,
  Directory directory,
) async {
  if (!await directory.exists()) {
    return <String>[];
  }
  final paths = <String>[];
  await for (final entity in directory.list(
    recursive: true,
    followLinks: false,
  )) {
    if (entity is File) {
      paths.add(_relativePath(root, entity));
    }
  }
  paths.sort();
  return paths;
}

Future<String> _sha256File(File file) async {
  return (await sha256.bind(file.openRead()).first).toString();
}

Future<void> _writeBoundedDownload(
  Stream<List<int>> source,
  File destination, {
  required int maxBytes,
}) async {
  final sink = destination.openWrite();
  var byteCount = 0;
  try {
    await for (final chunk in source.timeout(const Duration(seconds: 60))) {
      byteCount += chunk.length;
      if (byteCount > maxBytes) {
        throw const ReleaseFailure(
          'bundletool download is unexpectedly large.',
        );
      }
      sink.add(chunk);
    }
  } finally {
    await sink.close();
  }
}

Future<bool> _isRegularFile(File file) async {
  return await FileSystemEntity.type(file.path, followLinks: false) ==
      FileSystemEntityType.file;
}

String _releaseRunId(DateTime utc) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${utc.year.toString().padLeft(4, '0')}'
      '${twoDigits(utc.month)}'
      '${twoDigits(utc.day)}T'
      '${twoDigits(utc.hour)}'
      '${twoDigits(utc.minute)}'
      '${twoDigits(utc.second)}'
      '${utc.millisecond.toString().padLeft(3, '0')}Z';
}

bool _isAbsolutePath(String value) {
  if (Platform.isWindows) {
    return RegExp(r'^[A-Za-z]:[\\/]').hasMatch(value) ||
        value.startsWith(r'\\') ||
        value.startsWith('//');
  }
  return value.startsWith('/');
}

String _relativePath(Directory root, FileSystemEntity entity) {
  final rootPath = root.absolute.path;
  final entityPath = entity.absolute.path;
  final prefix = rootPath.endsWith(Platform.pathSeparator)
      ? rootPath
      : '$rootPath${Platform.pathSeparator}';
  if (!entityPath.startsWith(prefix)) {
    throw const ReleaseFailure('Artifact is outside the expected directory.');
  }
  return entityPath.substring(prefix.length).replaceAll(r'\', '/');
}

String _join(String left, String right) {
  if (left.endsWith(Platform.pathSeparator)) {
    return '$left$right';
  }
  return '$left${Platform.pathSeparator}$right';
}

String _joinAll(List<String> parts) {
  if (parts.isEmpty) {
    throw ArgumentError.value(parts, 'parts');
  }
  return parts.skip(1).fold(parts.first, _join);
}
