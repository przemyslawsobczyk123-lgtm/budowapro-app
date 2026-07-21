import 'dart:async';

import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/contacts/presentation/contact_ui_text.dart';
import 'package:budowapro/features/contacts/presentation/contacts_controller.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final contacts = ref.watch(contactsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.contactsTitle)),
      body: contacts.when(
        loading: () => AppLoadingState(label: l10n.projectsLoading),
        error: (error, stackTrace) => AppErrorState(
          title: l10n.contactsLoadError,
          retryLabel: l10n.retryAction,
          onRetry: () =>
              ref.read(contactsControllerProvider.notifier).refresh(),
        ),
        data: (state) => _body(l10n, state),
      ),
      floatingActionButton: contacts.value?.project == null
          ? null
          : FloatingActionButton(
              tooltip: l10n.contactsAddTooltip,
              onPressed: () async {
                final projectId = contacts.requireValue.project!.id;
                final changed = await context.push<bool>(
                  '/projects/${Uri.encodeComponent(projectId)}/contacts/new',
                );
                if (changed == true && mounted) {
                  await ref.read(contactsControllerProvider.notifier).refresh();
                }
              },
              child: const Icon(Icons.person_add_alt_1_outlined),
            ),
    );
  }

  Widget _body(AppLocalizations l10n, ContactsState state) {
    final project = state.project;
    if (project == null) {
      return AppEmptyState(
        key: const ValueKey('contactsNoProject'),
        icon: Icons.groups_outlined,
        title: l10n.contactsNoProjectTitle,
        message: l10n.contactsNoProjectMessage,
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(contactsControllerProvider.notifier).refresh(),
      child: CustomScrollView(
        key: const ValueKey('contactsContent'),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    key: const ValueKey('contactsSearchField'),
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: l10n.contactsSearchHint,
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: l10n.clearAction,
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                                _search('');
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                      _search(value);
                    },
                  ),
                  const SizedBox(height: 10),
                  _FilterRow(state: state),
                  const SizedBox(height: 12),
                  Text(
                    l10n.contactsResultCount(state.contacts.length),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          ),
          if (state.contacts.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: AppEmptyState(
                icon: Icons.person_search_outlined,
                title:
                    state.searchTerm.isEmpty &&
                        state.roleFilter == null &&
                        state.stageFilter == null
                    ? l10n.contactsEmptyTitle
                    : l10n.contactsNoResultsTitle,
                message:
                    state.searchTerm.isEmpty &&
                        state.roleFilter == null &&
                        state.stageFilter == null
                    ? l10n.contactsEmptyMessage
                    : l10n.contactsNoResultsMessage,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 96),
              sliver: SliverList.separated(
                itemCount: state.contacts.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) => _ContactRow(
                  contact: state.contacts[index],
                  stages: state.stages,
                  onTap: () async {
                    final contact = state.contacts[index];
                    final changed = await context.push<bool>(
                      '/projects/${Uri.encodeComponent(project.id)}'
                      '/contacts/${Uri.encodeComponent(contact.id)}',
                    );
                    if (changed == true && mounted) {
                      await ref
                          .read(contactsControllerProvider.notifier)
                          .refresh();
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _search(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      ref.read(contactsControllerProvider.notifier).setSearchTerm(value);
    });
  }
}

class _FilterRow extends ConsumerWidget {
  const _FilterRow({required this.state});

  final ContactsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<ContactRole?>(
            key: const ValueKey('contactsRoleFilter'),
            initialValue: state.roleFilter,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.contactsRoleFilterLabel,
              prefixIcon: const Icon(Icons.badge_outlined),
            ),
            items: <DropdownMenuItem<ContactRole?>>[
              DropdownMenuItem(value: null, child: Text(l10n.contactsAllRoles)),
              ...ContactRole.values.map(
                (role) => DropdownMenuItem(
                  value: role,
                  child: Text(
                    contactRoleLabel(l10n, role),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            onChanged: (value) => ref
                .read(contactsControllerProvider.notifier)
                .setRoleFilter(value),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<String?>(
            key: const ValueKey('contactsStageFilter'),
            initialValue: state.stageFilter,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.contactsStageFilterLabel,
              prefixIcon: const Icon(Icons.account_tree_outlined),
            ),
            items: <DropdownMenuItem<String?>>[
              DropdownMenuItem(
                value: null,
                child: Text(l10n.contactsAllStages),
              ),
              ...state.stages.map(
                (stage) => DropdownMenuItem(
                  value: stage.id,
                  child: Text(
                    stageName(l10n, stage),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            onChanged: (value) => ref
                .read(contactsControllerProvider.notifier)
                .setStageFilter(value),
          ),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.contact,
    required this.stages,
    required this.onTap,
  });

  final Contact contact;
  final List<ProjectStage> stages;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final primaryRole = contact.roles.first;
    final stageNames = stages
        .where((stage) => contact.stageIds.contains(stage.id))
        .map((stage) => stageName(l10n, stage))
        .join(', ');
    final details = <String>[
      contactRoleLabel(l10n, primaryRole),
      if (stageNames.isNotEmpty) stageNames,
      if (contact.phone != null) contact.phone!,
    ];
    return ListTile(
      key: ValueKey('contactRow-${contact.id}'),
      minTileHeight: 76,
      leading: CircleAvatar(
        child: Icon(
          contact.kind == ContactKind.company
              ? Icons.business_outlined
              : contactRoleIcon(primaryRole),
        ),
      ),
      title: Text(
        contact.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        details.join(' · '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
