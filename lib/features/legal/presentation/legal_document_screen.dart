import 'package:budowapro/features/legal/data/legal_providers.dart';
import 'package:budowapro/features/legal/domain/legal_release_config.dart';
import 'package:budowapro/features/legal/domain/legal_sources.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LegalDocumentKind { privacyPolicy, termsOfUse }

class LegalDocumentScreen extends ConsumerWidget {
  const LegalDocumentScreen({required this.kind, super.key});

  final LegalDocumentKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final config = ref.watch(legalReleaseConfigProvider);
    final sections = switch (kind) {
      LegalDocumentKind.privacyPolicy => _privacySections(l10n, config),
      LegalDocumentKind.termsOfUse => _termsSections(l10n, config),
    };
    final title = kind == LegalDocumentKind.privacyPolicy
        ? l10n.privacyPolicyTitle
        : l10n.termsOfUseTitle;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        key: ValueKey('legalDocument-${kind.name}'),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              kind == LegalDocumentKind.privacyPolicy
                  ? l10n.privacyPolicyIntro
                  : l10n.termsOfUseIntro,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          for (var index = 0; index < sections.length; index++)
            _DocumentSection(
              section: sections[index],
              initiallyExpanded: index == 0,
            ),
          if (kind == LegalDocumentKind.privacyPolicy) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                l10n.legalOfficialSourcesTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            _SourceTile(
              label: l10n.legalSourceMlKitTerms,
              uri: LegalSources.mlKitTerms,
            ),
            _SourceTile(
              label: l10n.legalSourceMlKitDisclosure,
              uri: LegalSources.mlKitDataDisclosure,
            ),
            _SourceTile(
              label: l10n.legalSourceGooglePrivacy,
              uri: LegalSources.googlePrivacy,
            ),
            _SourceTile(label: l10n.legalSourceGdpr, uri: LegalSources.gdpr),
            _SourceTile(
              label: l10n.legalSourceUodo,
              uri: LegalSources.uodoComplaint,
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(
              l10n.legalDocumentVersion,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

final class _LegalSectionData {
  const _LegalSectionData({required this.title, required this.body});

  final String title;
  final String body;
}

class _DocumentSection extends StatelessWidget {
  const _DocumentSection({
    required this.section,
    required this.initiallyExpanded,
  });

  final _LegalSectionData section;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      tilePadding: const EdgeInsets.symmetric(horizontal: 20),
      childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      title: Text(section.title, style: Theme.of(context).textTheme.titleSmall),
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      children: [Text(section.body)],
    );
  }
}

class _SourceTile extends ConsumerWidget {
  const _SourceTile({required this.label, required this.uri});

  final String label;
  final Uri uri;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      minTileHeight: 56,
      leading: const Icon(Icons.open_in_new_rounded),
      title: Text(label),
      subtitle: Text(uri.host),
      onTap: () async {
        var opened = false;
        try {
          opened = await ref.read(legalLinkGatewayProvider).openExternal(uri);
        } on Object {
          opened = false;
        }
        if (!opened && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).legalOpenLinkError),
            ),
          );
        }
      },
    );
  }
}

List<_LegalSectionData> _privacySections(
  AppLocalizations l10n,
  LegalReleaseConfig config,
) {
  final publisher = config.hasPublisherName
      ? config.publisherName.trim()
      : l10n.legalNotConfiguredValue;
  final contact = config.hasValidContactEmail
      ? config.contactEmail.trim()
      : l10n.legalNotConfiguredValue;
  return <_LegalSectionData>[
    _LegalSectionData(
      title: l10n.privacySectionPublisherTitle,
      body: l10n.privacySectionPublisherBody(publisher, contact),
    ),
    _LegalSectionData(
      title: l10n.privacySectionLocalDataTitle,
      body: l10n.privacySectionLocalDataBody,
    ),
    _LegalSectionData(
      title: l10n.privacySectionPurposeTitle,
      body: l10n.privacySectionPurposeBody,
    ),
    _LegalSectionData(
      title: l10n.privacySectionOcrTitle,
      body: l10n.privacySectionOcrBody,
    ),
    _LegalSectionData(
      title: l10n.privacySectionSharingTitle,
      body: l10n.privacySectionSharingBody,
    ),
    _LegalSectionData(
      title: l10n.privacySectionRetentionTitle,
      body: l10n.privacySectionRetentionBody,
    ),
    _LegalSectionData(
      title: l10n.privacySectionRightsTitle,
      body: l10n.privacySectionRightsBody(contact),
    ),
    _LegalSectionData(
      title: l10n.privacySectionSecurityTitle,
      body: l10n.privacySectionSecurityBody,
    ),
    _LegalSectionData(
      title: l10n.privacySectionChangesTitle,
      body: l10n.privacySectionChangesBody,
    ),
  ];
}

List<_LegalSectionData> _termsSections(
  AppLocalizations l10n,
  LegalReleaseConfig config,
) {
  final publisher = config.hasPublisherName
      ? config.publisherName.trim()
      : l10n.legalNotConfiguredValue;
  final contact = config.hasValidContactEmail
      ? config.contactEmail.trim()
      : l10n.legalNotConfiguredValue;
  return <_LegalSectionData>[
    _LegalSectionData(
      title: l10n.termsSectionProviderTitle,
      body: l10n.termsSectionProviderBody(publisher, contact),
    ),
    _LegalSectionData(
      title: l10n.termsSectionPurposeTitle,
      body: l10n.termsSectionPurposeBody,
    ),
    _LegalSectionData(
      title: l10n.termsSectionSafetyTitle,
      body: l10n.termsSectionSafetyBody,
    ),
    _LegalSectionData(
      title: l10n.termsSectionUserDataTitle,
      body: l10n.termsSectionUserDataBody,
    ),
    _LegalSectionData(
      title: l10n.termsSectionOcrTitle,
      body: l10n.termsSectionOcrBody,
    ),
    _LegalSectionData(
      title: l10n.termsSectionAvailabilityTitle,
      body: l10n.termsSectionAvailabilityBody,
    ),
    _LegalSectionData(
      title: l10n.termsSectionLiabilityTitle,
      body: l10n.termsSectionLiabilityBody,
    ),
    _LegalSectionData(
      title: l10n.termsSectionLawTitle,
      body: l10n.termsSectionLawBody,
    ),
    _LegalSectionData(
      title: l10n.termsSectionChangesTitle,
      body: l10n.termsSectionChangesBody,
    ),
  ];
}
