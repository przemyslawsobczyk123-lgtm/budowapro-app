import 'package:budowapro/features/backup/presentation/backup_screen.dart';
import 'package:budowapro/features/captures/presentation/captures_screen.dart';
import 'package:budowapro/features/costs/presentation/cost_budget_screen.dart';
import 'package:budowapro/features/costs/presentation/cost_details_screen.dart';
import 'package:budowapro/features/costs/presentation/cost_form_screen.dart';
import 'package:budowapro/features/costs/presentation/cost_register_initial_filter.dart';
import 'package:budowapro/features/contacts/presentation/contact_details_screen.dart';
import 'package:budowapro/features/contacts/presentation/contact_form_screen.dart';
import 'package:budowapro/features/contacts/presentation/contacts_screen.dart';
import 'package:budowapro/features/contacts/presentation/site_visit_form_screen.dart';
import 'package:budowapro/features/dashboard/presentation/dashboard_screen.dart';
import 'package:budowapro/features/diary/presentation/journal_details_screen.dart';
import 'package:budowapro/features/diary/presentation/journal_form_screen.dart';
import 'package:budowapro/features/diary/presentation/journal_screen.dart';
import 'package:budowapro/features/documents/presentation/document_details_screen.dart';
import 'package:budowapro/features/documents/presentation/document_form_screen.dart';
import 'package:budowapro/features/documents/presentation/document_viewer_screen.dart';
import 'package:budowapro/features/documents/presentation/documents_screen.dart';
import 'package:budowapro/features/legal/presentation/legal_center_screen.dart';
import 'package:budowapro/features/legal/presentation/legal_document_screen.dart';
import 'package:budowapro/features/legal/presentation/privacy_settings_screen.dart';
import 'package:budowapro/features/materials/presentation/material_details_screen.dart';
import 'package:budowapro/features/materials/presentation/material_form_screen.dart';
import 'package:budowapro/features/materials/presentation/materials_screen.dart';
import 'package:budowapro/features/projects/presentation/project_form_screen.dart';
import 'package:budowapro/features/punch_list/presentation/defect_details_screen.dart';
import 'package:budowapro/features/punch_list/presentation/defect_form_screen.dart';
import 'package:budowapro/features/punch_list/presentation/protocol_details_screen.dart';
import 'package:budowapro/features/punch_list/presentation/protocol_form_screen.dart';
import 'package:budowapro/features/punch_list/presentation/punch_screen.dart';
import 'package:budowapro/features/quotes/presentation/quote_comparison_screen.dart';
import 'package:budowapro/features/quotes/presentation/quote_details_screen.dart';
import 'package:budowapro/features/quotes/presentation/quote_form_screen.dart';
import 'package:budowapro/features/quotes/presentation/quotes_screen.dart';
import 'package:budowapro/features/receipt_scan/presentation/receipt_scan_screen.dart';
import 'package:budowapro/features/reports/presentation/budget_report_screen.dart';
import 'package:budowapro/features/rooms/presentation/room_choice_form_screen.dart';
import 'package:budowapro/features/rooms/presentation/room_details_screen.dart';
import 'package:budowapro/features/rooms/presentation/room_form_screen.dart';
import 'package:budowapro/features/rooms/presentation/room_relations_screen.dart';
import 'package:budowapro/features/rooms/presentation/rooms_screen.dart';
import 'package:budowapro/features/schedule/data/schedule_providers.dart';
import 'package:budowapro/features/schedule/presentation/schedule_event_details_screen.dart';
import 'package:budowapro/features/schedule/presentation/schedule_event_form_screen.dart';
import 'package:budowapro/features/schedule/presentation/schedule_plan_screen.dart';
import 'package:budowapro/features/shell/presentation/app_shell.dart';
import 'package:budowapro/features/shell/presentation/more_tools_screen.dart';
import 'package:budowapro/features/technical_photos/presentation/technical_photo_details_screen.dart';
import 'package:budowapro/features/technical_photos/presentation/technical_photo_form_screen.dart';
import 'package:budowapro/features/technical_photos/presentation/technical_photos_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  late final GoRouter router;
  router = GoRouter(
    initialLocation: AppSection.start.path,
    routes: [
      GoRoute(
        path: '/projects/new',
        builder: (context, state) => const ProjectFormScreen(),
      ),
      GoRoute(
        path: '/projects/:projectId/edit',
        builder: (context, state) =>
            ProjectFormScreen(projectId: state.pathParameters['projectId']),
      ),
      GoRoute(
        path: '/projects/:projectId/costs/new',
        builder: (context, state) =>
            CostFormScreen(projectId: state.pathParameters['projectId']!),
      ),
      GoRoute(
        path: '/projects/:projectId/receipt-scans/new',
        builder: (context, state) =>
            ReceiptScanScreen(projectId: state.pathParameters['projectId']!),
      ),
      GoRoute(
        path: '/projects/:projectId/costs/:costEntryId',
        builder: (context, state) => CostDetailsScreen(
          projectId: state.pathParameters['projectId']!,
          costEntryId: state.pathParameters['costEntryId']!,
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/costs/:costEntryId/edit',
        builder: (context, state) => CostFormScreen(
          projectId: state.pathParameters['projectId']!,
          costEntryId: state.pathParameters['costEntryId']!,
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/documents/:documentId/view',
        builder: (context, state) => DocumentViewerScreen(
          projectId: state.pathParameters['projectId']!,
          documentId: state.pathParameters['documentId']!,
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/documents/:documentId/edit',
        builder: (context, state) => DocumentFormScreen(
          projectId: state.pathParameters['projectId']!,
          documentId: state.pathParameters['documentId']!,
          isNew: state.uri.queryParameters['new'] == '1',
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/documents/:documentId',
        builder: (context, state) => DocumentDetailsScreen(
          projectId: state.pathParameters['projectId']!,
          documentId: state.pathParameters['documentId']!,
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/schedule/new',
        builder: (context, state) => ScheduleEventFormScreen(
          projectId: state.pathParameters['projectId']!,
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/schedule/:eventId/edit',
        builder: (context, state) => ScheduleEventFormScreen(
          projectId: state.pathParameters['projectId']!,
          eventId: state.pathParameters['eventId']!,
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/schedule/:eventId',
        builder: (context, state) => ScheduleEventDetailsScreen(
          projectId: state.pathParameters['projectId']!,
          eventId: state.pathParameters['eventId']!,
        ),
      ),
      GoRoute(
        path: '/contacts',
        builder: (context, state) => const ContactsScreen(),
      ),
      GoRoute(
        path: '/quotes',
        builder: (context, state) => const QuotesScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const BudgetReportScreen(),
      ),
      GoRoute(path: '/rooms', builder: (context, state) => const RoomsScreen()),
      GoRoute(
        path: '/materials',
        builder: (context, state) => const MaterialsScreen(),
      ),
      GoRoute(
        path: '/projects/:projectId/materials/new',
        builder: (context, state) =>
            MaterialFormScreen(projectId: state.pathParameters['projectId']!),
      ),
      GoRoute(
        path: '/projects/:projectId/materials/:materialId/edit',
        builder: (context, state) => MaterialFormScreen(
          projectId: state.pathParameters['projectId']!,
          materialId: state.pathParameters['materialId']!,
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/materials/:materialId',
        builder: (context, state) => MaterialDetailsScreen(
          projectId: state.pathParameters['projectId']!,
          materialId: state.pathParameters['materialId']!,
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/rooms/new',
        builder: (context, state) =>
            RoomFormScreen(projectId: state.pathParameters['projectId']!),
      ),
      GoRoute(
        path: '/projects/:projectId/rooms/:roomId/edit',
        builder: (context, state) => RoomFormScreen(
          projectId: state.pathParameters['projectId']!,
          roomId: state.pathParameters['roomId']!,
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/rooms/:roomId/choices/new',
        builder: (context, state) => RoomChoiceFormScreen(
          projectId: state.pathParameters['projectId']!,
          roomId: state.pathParameters['roomId']!,
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/rooms/:roomId/relations',
        builder: (context, state) => RoomRelationsScreen(
          projectId: state.pathParameters['projectId']!,
          roomId: state.pathParameters['roomId']!,
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/rooms/:roomId/choices/:choiceId/edit',
        builder: (context, state) => RoomChoiceFormScreen(
          projectId: state.pathParameters['projectId']!,
          roomId: state.pathParameters['roomId']!,
          choiceId: state.pathParameters['choiceId']!,
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/rooms/:roomId',
        builder: (context, state) => RoomDetailsScreen(
          projectId: state.pathParameters['projectId']!,
          roomId: state.pathParameters['roomId']!,
        ),
      ),
      GoRoute(
        path: '/backup',
        builder: (context, state) => const BackupScreen(),
      ),
      GoRoute(
        path: '/captures',
        builder: (context, state) => const CapturesScreen(),
      ),
      GoRoute(
        path: '/diary/new',
        builder: (context, state) => const JournalFormScreen(),
      ),
      GoRoute(
        path: '/diary/:entryId/edit',
        builder: (context, state) =>
            JournalFormScreen(entryId: state.pathParameters['entryId']!),
      ),
      GoRoute(
        path: '/diary/:entryId',
        builder: (context, state) =>
            JournalDetailsScreen(entryId: state.pathParameters['entryId']!),
      ),
      GoRoute(
        path: '/diary',
        builder: (context, state) => const JournalScreen(),
      ),
      GoRoute(
        path: '/technical',
        builder: (context, state) => const TechnicalPhotosScreen(),
      ),
      GoRoute(path: '/punch', builder: (context, state) => const PunchScreen()),
      GoRoute(
        path: '/projects/:projectId/punch/defects/new',
        builder: (context, state) =>
            DefectFormScreen(projectId: state.pathParameters['projectId']!),
      ),
      GoRoute(
        path: '/projects/:projectId/punch/defects/:defectId/edit',
        builder: (context, state) => DefectFormScreen(
          projectId: state.pathParameters['projectId']!,
          defectId: state.pathParameters['defectId']!,
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/punch/defects/:defectId',
        builder: (context, state) => DefectDetailsScreen(
          projectId: state.pathParameters['projectId']!,
          defectId: state.pathParameters['defectId']!,
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/punch/protocols/new',
        builder: (context, state) => ProtocolFormScreen(
          projectId: state.pathParameters['projectId']!,
          initialDefectId: state.uri.queryParameters['defectId'],
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/punch/protocols/:protocolId/edit',
        builder: (context, state) => ProtocolFormScreen(
          projectId: state.pathParameters['projectId']!,
          protocolId: state.pathParameters['protocolId']!,
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/punch/protocols/:protocolId',
        builder: (context, state) => ProtocolDetailsScreen(
          projectId: state.pathParameters['projectId']!,
          protocolId: state.pathParameters['protocolId']!,
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/technical/:attachmentId/edit',
        builder: (context, state) => TechnicalPhotoFormScreen(
          projectId: state.pathParameters['projectId']!,
          attachmentId: state.pathParameters['attachmentId']!,
          isNew: state.uri.queryParameters['new'] == '1',
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/technical/:attachmentId',
        builder: (context, state) => TechnicalPhotoDetailsScreen(
          projectId: state.pathParameters['projectId']!,
          attachmentId: state.pathParameters['attachmentId']!,
        ),
      ),
      GoRoute(
        path: '/legal',
        builder: (context, state) => const LegalCenterScreen(),
      ),
      GoRoute(
        path: '/legal/privacy-policy',
        builder: (context, state) =>
            const LegalDocumentScreen(kind: LegalDocumentKind.privacyPolicy),
      ),
      GoRoute(
        path: '/legal/terms',
        builder: (context, state) =>
            const LegalDocumentScreen(kind: LegalDocumentKind.termsOfUse),
      ),
      GoRoute(
        path: '/legal/privacy-settings',
        builder: (context, state) => const PrivacySettingsScreen(),
      ),
      GoRoute(
        path: '/projects/:projectId/quotes/new',
        builder: (context, state) => QuoteFormScreen(
          projectId: state.pathParameters['projectId']!,
          initialContactId: state.uri.queryParameters['contactId'],
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/quotes/compare',
        builder: (context, state) => QuoteComparisonScreen(
          projectId: state.pathParameters['projectId']!,
          quoteIds:
              state.uri.queryParameters['ids']
                  ?.split(',')
                  .where((value) => value.isNotEmpty)
                  .toList(growable: false) ??
              const <String>[],
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/quotes/:quoteId/edit',
        builder: (context, state) => QuoteFormScreen(
          projectId: state.pathParameters['projectId']!,
          quoteId: state.pathParameters['quoteId']!,
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/quotes/:quoteId',
        builder: (context, state) => QuoteDetailsScreen(
          projectId: state.pathParameters['projectId']!,
          quoteId: state.pathParameters['quoteId']!,
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/contacts/new',
        builder: (context, state) =>
            ContactFormScreen(projectId: state.pathParameters['projectId']!),
      ),
      GoRoute(
        path: '/projects/:projectId/contacts/:contactId/edit',
        builder: (context, state) => ContactFormScreen(
          projectId: state.pathParameters['projectId']!,
          contactId: state.pathParameters['contactId']!,
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/contacts/:contactId/visits/new',
        builder: (context, state) => SiteVisitFormScreen(
          projectId: state.pathParameters['projectId']!,
          contactId: state.pathParameters['contactId']!,
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/contacts/:contactId/visits/:visitId/edit',
        builder: (context, state) => SiteVisitFormScreen(
          projectId: state.pathParameters['projectId']!,
          contactId: state.pathParameters['contactId']!,
          visitId: state.pathParameters['visitId']!,
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/contacts/:contactId',
        builder: (context, state) => ContactDetailsScreen(
          projectId: state.pathParameters['projectId']!,
          contactId: state.pathParameters['contactId']!,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: AppSection.values.map(_branchFor).toList(growable: false),
      ),
    ],
  );

  ref.listen(scheduleNotificationTargetProvider, (previous, target) {
    if (target == null) return;
    router.go(
      '/projects/${Uri.encodeComponent(target.projectId)}'
      '/schedule/${Uri.encodeComponent(target.eventId)}',
    );
    ref.read(scheduleNotificationTargetProvider.notifier).clear();
  });

  ref.onDispose(router.dispose);
  return router;
});

StatefulShellBranch _branchFor(AppSection section) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: section.path,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: switch (section) {
            AppSection.start => const DashboardScreen(),
            AppSection.plan => SchedulePlanScreen(
              initialTab: state.uri.queryParameters['tab'] == 'stages' ? 1 : 0,
            ),
            AppSection.build => const DocumentsScreen(),
            AppSection.more => const MoreToolsScreen(),
            AppSection.budget => CostBudgetScreen(
              initialFilter: CostRegisterInitialFilter.fromQueryParameters(
                state.uri.queryParameters,
              ),
            ),
          },
        ),
      ),
    ],
  );
}
