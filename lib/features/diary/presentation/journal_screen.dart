import 'package:budowapro/features/diary/domain/journal_entry.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'journal_controller.dart';
import 'journal_ui_text.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final _searchController = TextEditingController();
  JournalEntryType? _type;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(journalControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.journalTitle)),
      floatingActionButton: state.value?.project == null
          ? null
          : FloatingActionButton(
              key: const ValueKey('journalAddButton'),
              tooltip: l10n.journalAddTooltip,
              onPressed: state.value?.isMutating == true
                  ? null
                  : () => context.push('/diary/new'),
              child: const Icon(Icons.add_rounded),
            ),
      body: state.when(
        loading: () => AppLoadingState(label: l10n.journalTitle),
        error: (error, stackTrace) => AppErrorState(
          title: l10n.journalLoadError,
          retryLabel: l10n.retryAction,
          onRetry: () => ref.read(journalControllerProvider.notifier).refresh(),
        ),
        data: (data) {
          if (data.project == null) {
            return AppEmptyState(
              icon: Icons.menu_book_outlined,
              title: l10n.journalNoProjectTitle,
              message: l10n.journalNoProjectMessage,
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(journalControllerProvider.notifier).refresh(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: _JournalFilters(
                      controller: _searchController,
                      type: _type,
                      onSubmitted: (value) => ref
                          .read(journalControllerProvider.notifier)
                          .setSearchTerm(value),
                      onTypeChanged: (value) {
                        setState(() => _type = value);
                        ref
                            .read(journalControllerProvider.notifier)
                            .setTypeFilter(value);
                      },
                    ),
                  ),
                ),
                if (data.isMutating)
                  const SliverToBoxAdapter(
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
                if (data.entries.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppEmptyState(
                      icon: Icons.menu_book_outlined,
                      title: l10n.journalEmptyTitle,
                      message: l10n.journalEmptyMessage,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
                    sliver: SliverList.separated(
                      itemCount: data.entries.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      itemBuilder: (context, index) => _JournalRow(
                        entry: data.entries[index],
                        onTap: () => context.push(
                          '/diary/${Uri.encodeComponent(data.entries[index].id)}',
                        ),
                      ),
                    ),
                  ),
                if (data.nextPage != null)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    sliver: SliverToBoxAdapter(
                      child: OutlinedButton.icon(
                        onPressed: data.isLoadingMore
                            ? null
                            : () => ref
                                  .read(journalControllerProvider.notifier)
                                  .loadNext(),
                        icon: data.isLoadingMore
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.expand_more_rounded),
                        label: Text(l10n.journalLoadMore),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _JournalFilters extends StatelessWidget {
  const _JournalFilters({
    required this.controller,
    required this.type,
    required this.onSubmitted,
    required this.onTypeChanged,
  });

  final TextEditingController controller;
  final JournalEntryType? type;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<JournalEntryType?> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: l10n.journalSearchHint,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).deleteButtonTooltip,
                    onPressed: () {
                      controller.clear();
                      onSubmitted('');
                    },
                    icon: const Icon(Icons.clear_rounded),
                  ),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: Text(l10n.journalAllFilter),
                selected: type == null,
                onSelected: (_) => onTypeChanged(null),
              ),
              const SizedBox(width: 6),
              ...JournalEntryType.values.map(
                (value) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    avatar: Icon(journalTypeIcon(value), size: 18),
                    label: Text(journalTypeLabel(l10n, value)),
                    selected: type == value,
                    onSelected: (_) => onTypeChanged(value),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _JournalRow extends StatelessWidget {
  const _JournalRow({required this.entry, required this.onTap});

  final JournalEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final date = DateFormat(
      'dd.MM.yyyy, HH:mm',
      'pl_PL',
    ).format(entry.occurredAtUtc.toLocal());
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: colors.surfaceContainerHighest,
        foregroundColor: colors.primary,
        child: Icon(journalTypeIcon(entry.type)),
      ),
      title: Text(
        entry.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '${journalTypeLabel(l10n, entry.type)} · '
          '${journalStatusLabel(l10n, entry.status)} · $date\n'
          '${entry.body ?? l10n.journalNoContent}',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      isThreeLine: true,
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
