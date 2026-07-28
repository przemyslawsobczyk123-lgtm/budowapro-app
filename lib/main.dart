import 'dart:async';

import 'package:budowapro/core/errors/app_error_guard.dart';
import 'package:budowapro/core/routing/app_router.dart';
import 'package:budowapro/core/theme/app_theme.dart';
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
}
