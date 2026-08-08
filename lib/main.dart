import 'dart:async';

import 'package:budowapro/core/errors/app_error_guard.dart';
import 'package:budowapro/core/routing/app_router.dart';
import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/legal/data/legal_providers.dart';
import 'package:budowapro/features/legal/presentation/legal_acceptance_screen.dart';
import 'package:budowapro/features/schedule/data/schedule_providers.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/services/local_private_cache_cleaner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

void main() {
  AppErrorGuard.run(() async {
    WidgetsFlutterBinding.ensureInitialized();
    final cacheCleaner = LocalPrivateCacheCleaner.forDevice();
    final staleCache = await cacheCleaner.detachStale();
    pdfrxFlutterInitialize();
    runApp(const ProviderScope(child: MainApp()));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(cacheCleaner.purge(staleCache));
    });
  });
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acceptance = ref.watch(legalTermsAcceptedProvider);
    if (acceptance.asData?.value != true) {
      return _legalBootstrapApp(ref, acceptance);
    }

    ref.watch(scheduleNotificationBootstrapProvider);
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }

  Widget _legalBootstrapApp(WidgetRef ref, AsyncValue<bool> acceptance) {
    final config = ref.watch(legalReleaseConfigProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      home: acceptance.when(
        data: (_) => LegalAcceptanceScreen(
          onAccept: () async {
            final repository = await ref.read(
              legalAcceptanceRepositoryProvider.future,
            );
            await repository.acceptCurrentTerms();
            ref.invalidate(legalTermsAcceptedProvider);
          },
          onOpenTerms: () => _openLegalUri(ref, config.publicTermsUri),
          onOpenPrivacy: () =>
              _openLegalUri(ref, config.publicPrivacyPolicyUri),
        ),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (_, _) => _LegalBootstrapError(
          onRetry: () => ref.invalidate(legalTermsAcceptedProvider),
        ),
      ),
    );
  }

  Future<bool> _openLegalUri(WidgetRef ref, Uri? uri) async {
    if (uri == null) return false;
    return ref.read(legalLinkGatewayProvider).openExternal(uri);
  }
}

class _LegalBootstrapError extends StatelessWidget {
  const _LegalBootstrapError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 40),
                const SizedBox(height: 16),
                Text(
                  l10n.legalAcceptanceLoadError,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.legalAcceptanceRetry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
