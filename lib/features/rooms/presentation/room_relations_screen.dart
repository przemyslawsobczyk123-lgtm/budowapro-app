import 'dart:async';

import 'package:budowapro/features/rooms/data/room_providers.dart';
import 'package:budowapro/features/rooms/domain/room.dart';
import 'package:budowapro/features/rooms/domain/room_repository.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoomRelationsScreen extends ConsumerWidget {
  const RoomRelationsScreen({
    required this.projectId,
    required this.roomId,
    super.key,
  });

  final String projectId;
  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final repository = ref.watch(roomRepositoryProvider);
    return DefaultTabController(
      length: RoomRelationKind.values.length,
      child: Scaffold(
        key: const ValueKey('roomRelationsScreen'),
        appBar: AppBar(
          title: Text(l10n.roomRelationsTitle),
          bottom: TabBar(
            isScrollable: true,
            tabs: RoomRelationKind.values
                .map(
                  (kind) => Tab(
                    icon: Icon(_relationIcon(kind)),
                    text: _relationLabel(l10n, kind),
                  ),
                )
                .toList(growable: false),
          ),
        ),
        body: repository.when(
          loading: () => AppLoadingState(label: l10n.roomsLoading),
          error: (error, stackTrace) => AppErrorState(
            title: l10n.roomsLoadError,
            retryLabel: l10n.retryAction,
            onRetry: () => ref.invalidate(roomRepositoryProvider),
          ),
          data: (value) => TabBarView(
            children: RoomRelationKind.values
                .map(
                  (kind) => _RoomRelationTab(
                    repository: value,
                    projectId: projectId,
                    roomId: roomId,
                    kind: kind,
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ),
    );
  }
}

class _RoomRelationTab extends StatefulWidget {
  const _RoomRelationTab({
    required this.repository,
    required this.projectId,
    required this.roomId,
    required this.kind,
  });

  final RoomRepository repository;
  final String projectId;
  final String roomId;
  final RoomRelationKind kind;

  @override
  State<_RoomRelationTab> createState() => _RoomRelationTabState();
}

class _RoomRelationTabState extends State<_RoomRelationTab> {
  final _search = TextEditingController();
  Timer? _debounce;
  late Future<List<RoomRelationCandidate>> _load = _request();

  Future<List<RoomRelationCandidate>> _request() =>
      widget.repository.listRelationCandidates(
        projectId: widget.projectId,
        roomId: widget.roomId,
        kind: widget.kind,
        searchText: _search.text,
      );

  void _reload() {
    setState(() {
      _load = _request();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: TextField(
            key: ValueKey('roomRelationSearch-${widget.kind.name}'),
            controller: _search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l10n.roomRelationsSearchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l10n.clearAction,
                      onPressed: () {
                        _search.clear();
                        _reload();
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
            onSubmitted: (_) => _reload(),
            onChanged: (_) {
              setState(() {});
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 300), _reload);
            },
          ),
        ),
        Expanded(
          child: FutureBuilder<List<RoomRelationCandidate>>(
            future: _load,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return AppLoadingState(label: l10n.roomsLoading);
              }
              if (snapshot.hasError) {
                return AppErrorState(
                  title: l10n.roomsLoadError,
                  retryLabel: l10n.retryAction,
                  onRetry: _reload,
                );
              }
              final candidates =
                  snapshot.data ?? const <RoomRelationCandidate>[];
              if (candidates.isEmpty) {
                return AppEmptyState(
                  icon: _relationIcon(widget.kind),
                  title: _relationLabel(l10n, widget.kind),
                  message: l10n.roomRelationsEmpty,
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: candidates.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final candidate = candidates[index];
                  final assignedHere = candidate.isAssignedTo(widget.roomId);
                  final assignedElsewhere =
                      candidate.assignedRoomId != null && !assignedHere;
                  final details = <String>[
                    if (candidate.supportingLabel != null)
                      candidate.supportingLabel!,
                    if (assignedElsewhere)
                      l10n.roomRelationsAssignedElsewhere(
                        candidate.assignedRoomName!,
                      ),
                  ];
                  return CheckboxListTile(
                    key: ValueKey(
                      'roomRelation-${widget.kind.name}-${candidate.id}',
                    ),
                    value: assignedHere,
                    title: Text(candidate.title),
                    subtitle: details.isEmpty ? null : Text(details.join('\n')),
                    secondary: Icon(_relationIcon(widget.kind)),
                    onChanged: (value) => _changeAssignment(
                      candidate,
                      value: value ?? false,
                      assignedElsewhere: assignedElsewhere,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _changeAssignment(
    RoomRelationCandidate candidate, {
    required bool value,
    required bool assignedElsewhere,
  }) async {
    final l10n = AppLocalizations.of(context);
    if (value && assignedElsewhere) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.roomRelationsMoveTitle),
          content: Text(
            l10n.roomRelationsMoveMessage(candidate.assignedRoomName!),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancelAction),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.roomRelationsMoveAction),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    try {
      if (widget.kind == RoomRelationKind.contact) {
        await widget.repository.setContactLinked(
          projectId: widget.projectId,
          roomId: widget.roomId,
          contactId: candidate.id,
          isLinked: value,
        );
      } else if (value) {
        await widget.repository.assignRecord(
          projectId: widget.projectId,
          roomId: widget.roomId,
          type: _recordType(widget.kind),
          recordId: candidate.id,
        );
      } else {
        await widget.repository.unassignRecord(
          projectId: widget.projectId,
          type: _recordType(widget.kind),
          recordId: candidate.id,
        );
      }
      if (mounted) _reload();
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.roomRelationsSaveError)));
    }
  }
}

String _relationLabel(AppLocalizations l10n, RoomRelationKind kind) =>
    switch (kind) {
      RoomRelationKind.cost => l10n.roomRelatedCosts,
      RoomRelationKind.decision => l10n.roomRelatedDecisions,
      RoomRelationKind.technicalPhoto => l10n.roomRelatedPhotos,
      RoomRelationKind.defect => l10n.roomRelatedDefects,
      RoomRelationKind.contact => l10n.roomRelatedTeams,
    };

IconData _relationIcon(RoomRelationKind kind) => switch (kind) {
  RoomRelationKind.cost => Icons.payments_outlined,
  RoomRelationKind.decision => Icons.rule_folder_outlined,
  RoomRelationKind.technicalPhoto => Icons.photo_library_outlined,
  RoomRelationKind.defect => Icons.report_problem_outlined,
  RoomRelationKind.contact => Icons.groups_outlined,
};

RoomRecordType _recordType(RoomRelationKind kind) => switch (kind) {
  RoomRelationKind.cost => RoomRecordType.cost,
  RoomRelationKind.decision ||
  RoomRelationKind.defect => RoomRecordType.journal,
  RoomRelationKind.technicalPhoto => RoomRecordType.technicalPhoto,
  RoomRelationKind.contact => throw ArgumentError.value(kind, 'kind'),
};
