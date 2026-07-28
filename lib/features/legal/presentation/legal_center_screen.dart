import 'package:budowapro/features/legal/data/legal_providers.dart';
import 'package:budowapro/features/legal/domain/legal_release_config.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LegalCenterScreen extends ConsumerWidget {
  const LegalCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final config = ref.watch(legalReleaseConfigProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.legalCenterTitle)),
      body: ListView(
        key: const ValueKey('legalCenterContent'),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _LegalIntro(config: config),
          _SectionTitle(text: l10n.legalDocumentsSection),
          ListTile(
            key: const ValueKey('privacyPolicyTile'),
            minTileHeight: 64,
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacyPolicyTitle),
            subtitle: Text(l10n.privacyPolicyTileSubtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/legal/privacy-policy'),
          ),
          const Divider(height: 1, indent: 72),
          ListTile(
            key: const ValueKey('termsOfUseTile'),
            minTileHeight: 64,
            leading: const Icon(Icons.gavel_outlined),
            title: Text(l10n.termsOfUseTitle),
            subtitle: Text(l10n.termsOfUseTileSubtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/legal/terms'),
          ),
          const Divider(height: 1, indent: 72),
          ListTile(
            key: const ValueKey('privacySettingsTile'),
            minTileHeight: 64,
            leading: const Icon(Icons.tune_rounded),
            title: Text(l10n.privacySettingsTitle),
            subtitle: Text(l10n.privacySettingsTileSubtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/legal/privacy-settings'),
          ),
          const Divider(height: 1, indent: 72),
          ListTile(
            key: const ValueKey('licensesTile'),
            minTileHeight: 64,
            leading: const Icon(Icons.code_rounded),
            title: Text(l10n.openSourceLicensesTitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => showLicensePage(
              context: context,
              applicationName: l10n.appTitle,
            ),
          ),
          _SectionTitle(text: l10n.legalPublisherSection),
          _ValueTile(
            icon: Icons.business_outlined,
            label: l10n.legalPublisherLabel,
            value: config.hasPublisherName
                ? config.publisherName.trim()
                : l10n.legalNotConfiguredValue,
          ),
          _ValueTile(
            icon: Icons.alternate_email_rounded,
            label: l10n.legalContactLabel,
            value: config.hasValidContactEmail
                ? config.contactEmail.trim()
                : l10n.legalNotConfiguredValue,
            onTap: config.hasValidContactEmail
                ? () => _open(
                    context,
                    ref,
                    Uri(
                      scheme: 'mailto',
                      path: config.contactEmail.trim(),
                      queryParameters: <String, String>{
                        'subject': l10n.legalEmailSubject,
                      },
                    ),
                  )
                : null,
          ),
          if (config.publicPrivacyPolicyUri case final uri?)
            _ValueTile(
              icon: Icons.public_rounded,
              label: l10n.legalPublicPolicyLabel,
              value: uri.host,
              onTap: () => _open(context, ref, uri),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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

class _LegalIntro extends StatelessWidget {
  const _LegalIntro({required this.config});

  final LegalReleaseConfig config;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: config.hasCompleteLegalMetadata
          ? colorScheme.secondaryContainer
          : colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              config.hasCompleteLegalMetadata
                  ? Icons.verified_user_outlined
                  : Icons.warning_amber_rounded,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.hasCompleteLegalMetadata
                        ? l10n.legalIntroTitle
                        : l10n.legalReleaseConfigMissingTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    config.hasCompleteLegalMetadata
                        ? l10n.legalIntroMessage
                        : l10n.legalReleaseConfigMissingMessage(
                            config.missingRequirements
                                .map((value) => _requirementLabel(l10n, value))
                                .join(', '),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _ValueTile extends StatelessWidget {
  const _ValueTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 64,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
      trailing: onTap == null ? null : const Icon(Icons.open_in_new_rounded),
      onTap: onTap,
    );
  }
}

String _requirementLabel(
  AppLocalizations l10n,
  LegalReleaseRequirement requirement,
) => switch (requirement) {
  LegalReleaseRequirement.publisherName =>
    l10n.legalMissingPublisherRequirement,
  LegalReleaseRequirement.contactEmail => l10n.legalMissingEmailRequirement,
  LegalReleaseRequirement.publicPrivacyPolicyUrl =>
    l10n.legalMissingPublicUrlRequirement,
};

Future<void> _open(BuildContext context, WidgetRef ref, Uri uri) async {
  var opened = false;
  try {
    opened = await ref.read(legalLinkGatewayProvider).openExternal(uri);
  } on Object {
    opened = false;
  }
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).legalOpenLinkError)),
    );
  }
}
