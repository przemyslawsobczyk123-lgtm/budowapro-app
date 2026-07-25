import 'package:budowapro/features/stages/domain/stage_guidance.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/presentation/stage_guidance_ui_text.dart';
import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

Future<String?> showStageGuidanceSheet(
  BuildContext context, {
  required StageGuidanceDefinition guidance,
  required List<ChecklistItem> relatedItems,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.94,
      child: _StageGuidanceSheet(
        guidance: guidance,
        relatedItems: relatedItems,
      ),
    ),
  );
}

class _StageGuidanceSheet extends StatelessWidget {
  const _StageGuidanceSheet({
    required this.guidance,
    required this.relatedItems,
  });

  final StageGuidanceDefinition guidance;
  final List<ChecklistItem> relatedItems;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final content = stageGuidanceContent(l10n, guidance.key);
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(content.title, style: theme.textTheme.titleLarge),
                ),
                IconButton(
                  tooltip: l10n.stageGuidanceCloseAction,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                _SafetyNotice(l10n: l10n),
                const SizedBox(height: 20),
                _TimingBand(timing: content.timing),
                const SizedBox(height: 20),
                Text(content.summary, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 24),
                _GuidanceSection(
                  title: l10n.stageGuidanceCheckHeading,
                  items: content.checks,
                ),
                const SizedBox(height: 24),
                _GuidanceSection(
                  title: l10n.stageGuidanceQuestionsHeading,
                  items: content.questions,
                  icon: Icons.question_answer_outlined,
                ),
                if (relatedItems.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    l10n.stageGuidanceRelatedChecklistHeading,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  for (final item in relatedItems)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.checklist_rounded),
                      title: Text(checklistTitle(l10n, item)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.pop(context, item.id),
                    ),
                ],
                const SizedBox(height: 24),
                Text(
                  l10n.stageGuidanceSourcesHeading,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                for (final source in guidance.sources)
                  _SourceReference(source: source),
                const SizedBox(height: 8),
                Text(
                  l10n.stageGuidanceVersion(
                    StageGuidanceCatalog.contentVersion,
                    StageGuidanceCatalog.verifiedOnIso,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceReference extends StatelessWidget {
  const _SourceReference({required this.source});

  final StageGuidanceSourceReference source;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final metadataStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stageGuidanceSourceTitle(l10n, source.key),
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            stageGuidanceSourceTypeLabel(l10n, source.type),
            style: metadataStyle,
          ),
          Text(
            l10n.stageGuidanceSourceRevision(source.revision),
            style: metadataStyle,
          ),
          Text(
            l10n.stageGuidanceSourceVerifiedOn(source.verifiedOnIso),
            style: metadataStyle,
          ),
          const SizedBox(height: 4),
          SelectableText(
            source.urlValue,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyNotice extends StatelessWidget {
  const _SafetyNotice({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.engineering_outlined,
              color: theme.colorScheme.onTertiaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.stageGuidanceDisclaimerTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.stageGuidanceDisclaimerMessage,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
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

class _TimingBand extends StatelessWidget {
  const _TimingBand({required this.timing});

  final String timing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.schedule_rounded,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(timing, style: theme.textTheme.titleSmall)),
      ],
    );
  }
}

class _GuidanceSection extends StatelessWidget {
  const _GuidanceSection({
    required this.title,
    required this.items,
    this.icon = Icons.fact_check_outlined,
  });

  final String title;
  final List<String> items;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 10),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 10),
                Expanded(child: Text(item)),
              ],
            ),
          ),
      ],
    );
  }
}
