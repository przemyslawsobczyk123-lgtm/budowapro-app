import 'package:budowapro/features/captures/data/capture_providers.dart';
import 'package:budowapro/features/captures/domain/capture_draft.dart';
import 'package:budowapro/features/captures/domain/capture_repository.dart';
import 'package:budowapro/features/costs/data/cost_providers.dart';
import 'package:budowapro/features/dashboard/presentation/dashboard_controller.dart';
import 'package:budowapro/features/diary/presentation/journal_controller.dart';
import 'package:budowapro/features/documents/presentation/documents_controller.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/features/schedule/presentation/schedule_plan_controller.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

final capturesControllerProvider =
    AsyncNotifierProvider<CapturesController, CapturesState>(
      CapturesController.new,
    );

final class CapturesState {
  CapturesState({
    required this.project,
    required Iterable<CaptureDraft> open,
    required Iterable<CaptureDraft> history,
    required this.openTotal,
    required this.historyTotal,
    this.openNextPage,
    this.historyNextPage,
    this.isMutating = false,
    this.isLoadingMore = false,
  }) : open = List<CaptureDraft>.unmodifiable(open),
       history = List<CaptureDraft>.unmodifiable(history);

  factory CapturesState.noProject() => CapturesState(
    project: null,
    open: const <CaptureDraft>[],
    history: const <CaptureDraft>[],
    openTotal: 0,
    historyTotal: 0,
  );

  final Project? project;
  final List<CaptureDraft> open;
  final List<CaptureDraft> history;
  final int openTotal;
  final int historyTotal;
  final PageRequest? openNextPage;
  final PageRequest? historyNextPage;
  final bool isMutating;
  final bool isLoadingMore;

  CapturesState copyWith({
    Iterable<CaptureDraft>? open,
    Iterable<CaptureDraft>? history,
    PageRequest? openNextPage,
    PageRequest? historyNextPage,
    bool clearOpenNextPage = false,
    bool clearHistoryNextPage = false,
    bool? isMutating,
    bool? isLoadingMore,
  }) => CapturesState(
    project: project,
    open: open ?? this.open,
    history: history ?? this.history,
    openTotal: openTotal,
    historyTotal: historyTotal,
    openNextPage: clearOpenNextPage ? null : openNextPage ?? this.openNextPage,
    historyNextPage: clearHistoryNextPage
        ? null
        : historyNextPage ?? this.historyNextPage,
    isMutating: isMutating ?? this.isMutating,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

final class CapturesController extends AsyncNotifier<CapturesState> {
  static const int pageSize = PageRequest.maximumLimit;
  Future<void> _mutationQueue = Future<void>.value();

  @override
  Future<CapturesState> build() async {
    final projects = await ref.watch(projectsControllerProvider.future);
    final project = projects.selectedProject;
    if (project == null) return CapturesState.noProject();
    return _load(project);
  }

  Future<void> refresh() async {
    final project = state.value?.project;
    if (project == null) {
      ref.invalidateSelf();
      return;
    }
    state = const AsyncLoading<CapturesState>();
    final refreshed = await AsyncValue.guard(() => _load(project));
    if (!ref.mounted) return;
    state = refreshed;
  }

  Future<void> loadNext({required bool history}) async {
    final current = state.requireValue;
    final project = current.project;
    final request = history ? current.historyNextPage : current.openNextPage;
    if (project == null ||
        request == null ||
        current.isLoadingMore ||
        current.isMutating) {
      return;
    }
    state = AsyncData<CapturesState>(current.copyWith(isLoadingMore: true));
    try {
      final repository = await ref.read(captureRepositoryProvider.future);
      if (!ref.mounted) return;
      final page = await repository.list(
        CaptureDraftQuery(
          projectId: project.id,
          statuses: history
              ? const <CaptureDraftStatus>[CaptureDraftStatus.classified]
              : const <CaptureDraftStatus>[
                  CaptureDraftStatus.needsReview,
                  CaptureDraftStatus.ready,
                ],
        ),
        request,
      );
      if (!ref.mounted) return;
      state = AsyncData<CapturesState>(
        current.copyWith(
          open: history
              ? current.open
              : <CaptureDraft>[...current.open, ...page.items],
          history: history
              ? <CaptureDraft>[...current.history, ...page.items]
              : current.history,
          openNextPage: history ? current.openNextPage : page.nextRequest,
          historyNextPage: history ? page.nextRequest : current.historyNextPage,
          clearOpenNextPage: !history && page.nextRequest == null,
          clearHistoryNextPage: history && page.nextRequest == null,
          isLoadingMore: false,
        ),
      );
    } on Object catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = AsyncError<CapturesState>(error, stackTrace);
    }
  }

  Future<CaptureDraft?> pickAttachment(CaptureDraftType type) {
    return _mutate<CaptureDraft?>(() async {
      final project = state.requireValue.project;
      if (project == null) return null;
      final selected = await ref
          .read(captureAttachmentPickerProvider)
          .pick(type);
      if (selected == null) return null;
      final stager = await ref.read(captureAttachmentStagerProvider.future);
      final attachment = await stager.stage(
        projectId: project.id,
        pickedFile: selected,
      );
      try {
        final title = p.basenameWithoutExtension(attachment.displayName);
        return await (await ref.read(captureRepositoryProvider.future)).create(
          CaptureDraftInput(
            projectId: project.id,
            type: type,
            title: title,
            attachmentIds: <String>[attachment.id],
          ),
        );
      } on Object {
        await stager.discardIfUnlinked(
          projectId: project.id,
          attachmentId: attachment.id,
        );
        rethrow;
      }
    });
  }

  Future<CaptureDraft?> create(CaptureDraftInput input) {
    return _mutate<CaptureDraft?>(() async {
      final project = state.requireValue.project;
      if (project == null || project.id != input.projectId) return null;
      return (await ref.read(captureRepositoryProvider.future)).create(input);
    });
  }

  Future<CaptureDraft?> updateCapture(
    String captureId,
    CaptureDraftInput input,
  ) {
    return _mutate<CaptureDraft?>(() async {
      final project = state.requireValue.project;
      if (project == null || project.id != input.projectId) return null;
      return (await ref.read(
        captureRepositoryProvider.future,
      )).update(projectId: project.id, captureId: captureId, input: input);
    });
  }

  Future<CaptureDraft?> classify(String captureId) {
    return _mutate<CaptureDraft?>(() async {
      final project = state.requireValue.project;
      if (project == null) return null;
      final result = await (await ref.read(captureRepositoryProvider.future))
          .classify(
            projectId: project.id,
            captureId: captureId,
            currencyCode: project.currencyCode,
          );
      _invalidateTarget(result.targetType!);
      return result;
    });
  }

  Future<CaptureDraft?> merge(String retainedId, String mergedId) {
    return _mutate<CaptureDraft?>(() async {
      final project = state.requireValue.project;
      if (project == null) return null;
      return (await ref.read(captureRepositoryProvider.future)).merge(
        projectId: project.id,
        retainedCaptureId: retainedId,
        mergedCaptureId: mergedId,
      );
    });
  }

  Future<void> reject(String captureId) {
    return _mutate<void>(() async {
      final project = state.requireValue.project;
      if (project == null) return;
      final attachments = await (await ref.read(
        captureRepositoryProvider.future,
      )).reject(projectId: project.id, captureId: captureId);
      final stager = await ref.read(captureAttachmentStagerProvider.future);
      for (final attachmentId in attachments) {
        await stager.discardIfUnlinked(
          projectId: project.id,
          attachmentId: attachmentId,
        );
      }
    });
  }

  Future<T> _mutate<T>(Future<T> Function() action) {
    late T result;
    final mutation = _mutationQueue.then<void>((_) async {
      final current = state.requireValue;
      state = AsyncData<CapturesState>(current.copyWith(isMutating: true));
      try {
        result = await action();
        if (!ref.mounted) return;
        ref.invalidate(dashboardControllerProvider);
        final project = current.project;
        final refreshed = project == null
            ? CapturesState.noProject()
            : await _load(project);
        if (!ref.mounted) return;
        state = AsyncData<CapturesState>(refreshed);
      } on Object catch (error, stackTrace) {
        if (ref.mounted) {
          state = AsyncData<CapturesState>(current);
        }
        Error.throwWithStackTrace(error, stackTrace);
      }
    });
    _mutationQueue = mutation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return mutation.then<T>((_) => result);
  }

  Future<CapturesState> _load(Project project) async {
    final repository = await ref.read(captureRepositoryProvider.future);
    final results = await Future.wait<Page<CaptureDraft>>(
      <Future<Page<CaptureDraft>>>[
        repository.list(
          CaptureDraftQuery(projectId: project.id),
          PageRequest(limit: pageSize),
        ),
        repository.list(
          CaptureDraftQuery(
            projectId: project.id,
            statuses: const <CaptureDraftStatus>[CaptureDraftStatus.classified],
          ),
          PageRequest(limit: pageSize),
        ),
      ],
    );
    return CapturesState(
      project: project,
      open: results[0].items,
      history: results[1].items,
      openTotal: results[0].totalCount,
      historyTotal: results[1].totalCount,
      openNextPage: results[0].nextRequest,
      historyNextPage: results[1].nextRequest,
    );
  }

  void _invalidateTarget(CaptureTargetType target) {
    switch (target) {
      case CaptureTargetType.document:
        ref.invalidate(documentsControllerProvider);
      case CaptureTargetType.costDraft:
        ref.invalidate(costRepositoryProvider);
      case CaptureTargetType.scheduleTask:
        ref.invalidate(schedulePlanControllerProvider);
      case CaptureTargetType.note ||
          CaptureTargetType.decision ||
          CaptureTargetType.defect:
        ref.invalidate(journalControllerProvider);
        break;
    }
  }
}
