import 'package:budowapro/features/captures/domain/capture_draft.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/schedule/data/schedule_providers.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'captures_controller.dart';

class CapturesScreen extends ConsumerStatefulWidget {
  const CapturesScreen({super.key});

  @override
  ConsumerState<CapturesScreen> createState() => _CapturesScreenState();
}

class _CapturesScreenState extends ConsumerState<CapturesScreen> {
  var _showHistory = false;
  CaptureDraftType? _type;

  @override
  Widget build(BuildContext context) {
    final inbox = ref.watch(capturesControllerProvider);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.captureInboxTitle)),
      floatingActionButton: inbox.value?.project == null
          ? null
          : FloatingActionButton(
              key: const ValueKey('captureAddButton'),
              tooltip: l10n.captureAddTooltip,
              onPressed: inbox.value?.isMutating == true
                  ? null
                  : () => showCaptureComposer(context, ref),
              child: const Icon(Icons.add_rounded),
            ),
      body: SafeArea(
        top: false,
        child: inbox.when(
          loading: () => AppLoadingState(label: l10n.captureInboxTitle),
          error: (error, stackTrace) => AppErrorState(
            title: l10n.captureInboxLoadError,
            retryLabel: l10n.retryAction,
            onRetry: () =>
                ref.read(capturesControllerProvider.notifier).refresh(),
          ),
          data: (state) {
            if (state.project == null) {
              return AppEmptyState(
                icon: Icons.inbox_outlined,
                title: l10n.captureInboxNoProjectTitle,
                message: l10n.captureInboxNoProjectMessage,
              );
            }
            final source = _showHistory ? state.history : state.open;
            final nextPage = _showHistory
                ? state.historyNextPage
                : state.openNextPage;
            final visible = _type == null
                ? source
                : source
                      .where((draft) => draft.type == _type)
                      .toList(growable: false);
            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(capturesControllerProvider.notifier).refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: _InboxControls(
                        showHistory: _showHistory,
                        type: _type,
                        openCount: state.openTotal,
                        historyCount: state.historyTotal,
                        onHistoryChanged: (value) {
                          setState(() => _showHistory = value);
                        },
                        onTypeChanged: (value) {
                          setState(() => _type = value);
                        },
                      ),
                    ),
                  ),
                  if (state.isMutating)
                    const SliverToBoxAdapter(
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  if (visible.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppEmptyState(
                        icon: _showHistory
                            ? Icons.history_rounded
                            : Icons.inbox_outlined,
                        title: _showHistory
                            ? l10n.captureInboxHistoryEmptyTitle
                            : l10n.captureInboxEmptyTitle,
                        message: _showHistory
                            ? l10n.captureInboxHistoryEmptyMessage
                            : l10n.captureInboxEmptyMessage,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
                      sliver: SliverList.separated(
                        itemCount: visible.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        itemBuilder: (context, index) => _CaptureRow(
                          draft: visible[index],
                          allOpenDrafts: state.open,
                          project: state.project!,
                          enabled: !state.isMutating,
                        ),
                      ),
                    ),
                  if (nextPage != null)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                      sliver: SliverToBoxAdapter(
                        child: OutlinedButton.icon(
                          key: const ValueKey('captureLoadMoreButton'),
                          onPressed: state.isLoadingMore
                              ? null
                              : () => ref
                                    .read(capturesControllerProvider.notifier)
                                    .loadNext(history: _showHistory),
                          icon: state.isLoadingMore
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.expand_more_rounded),
                          label: Text(
                            state.isLoadingMore
                                ? l10n.captureLoadingMore
                                : l10n.captureLoadMoreAction,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InboxControls extends StatelessWidget {
  const _InboxControls({
    required this.showHistory,
    required this.type,
    required this.openCount,
    required this.historyCount,
    required this.onHistoryChanged,
    required this.onTypeChanged,
  });

  final bool showHistory;
  final CaptureDraftType? type;
  final int openCount;
  final int historyCount;
  final ValueChanged<bool> onHistoryChanged;
  final ValueChanged<CaptureDraftType?> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<bool>(
          key: const ValueKey('captureStatusSegments'),
          segments: <ButtonSegment<bool>>[
            ButtonSegment<bool>(
              value: false,
              label: Text(l10n.captureInboxOpenTab(openCount)),
            ),
            ButtonSegment<bool>(
              value: true,
              label: Text(l10n.captureInboxHistoryTab(historyCount)),
            ),
          ],
          selected: <bool>{showHistory},
          showSelectedIcon: false,
          onSelectionChanged: (value) => onHistoryChanged(value.single),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              ChoiceChip(
                label: Text(l10n.captureTypeAll),
                selected: type == null,
                onSelected: (_) => onTypeChanged(null),
              ),
              const SizedBox(width: 6),
              ...CaptureDraftType.values.map(
                (value) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    avatar: Icon(captureTypeIcon(value), size: 18),
                    label: Text(captureTypeLabel(l10n, value)),
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

class _CaptureRow extends ConsumerWidget {
  const _CaptureRow({
    required this.draft,
    required this.allOpenDrafts,
    required this.project,
    required this.enabled,
  });

  final CaptureDraft draft;
  final List<CaptureDraft> allOpenDrafts;
  final Project project;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final isReady = draft.status == CaptureDraftStatus.ready;
    final statusColor = draft.status == CaptureDraftStatus.classified
        ? colors.tertiary
        : isReady
        ? colors.primary
        : colors.error;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(captureTypeIcon(draft.type), color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      draft.title ?? captureTypeLabel(l10n, draft.type),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _captureStatusText(l10n, draft),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: statusColor),
                    ),
                    if (draft.content != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        draft.content!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                DateFormat('dd.MM', 'pl_PL').format(draft.createdAtUtc),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          if (draft.isOpen) ...[
            const SizedBox(height: 9),
            Wrap(
              spacing: 2,
              runSpacing: 2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                IconButton(
                  tooltip: l10n.captureEditTooltip,
                  onPressed: enabled
                      ? () => showCaptureEditor(
                          context,
                          ref,
                          project: project,
                          draft: draft,
                        )
                      : null,
                  icon: const Icon(Icons.edit_outlined),
                ),
                if (_canMergeType(draft.type))
                  IconButton(
                    tooltip: l10n.captureMergeTooltip,
                    onPressed: enabled
                        ? () => _showMergePicker(
                            context,
                            ref,
                            retained: draft,
                            candidates: allOpenDrafts
                                .where(
                                  (item) =>
                                      item.id != draft.id &&
                                      item.type == draft.type,
                                )
                                .toList(growable: false),
                          )
                        : null,
                    icon: const Icon(Icons.merge_rounded),
                  ),
                IconButton(
                  tooltip: l10n.captureRejectTooltip,
                  onPressed: enabled
                      ? () => _confirmReject(context, ref, draft)
                      : null,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
                if (draft.canClassify)
                  FilledButton.icon(
                    onPressed: enabled
                        ? () => _classify(context, ref, draft.id)
                        : null,
                    icon: const Icon(Icons.check_rounded),
                    label: Text(l10n.captureApproveTooltip),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

Future<void> showCaptureComposer(BuildContext context, WidgetRef ref) async {
  CapturesState state;
  try {
    state = await ref.read(capturesControllerProvider.future);
  } on Object {
    if (context.mounted) {
      _message(context, AppLocalizations.of(context).captureActionError);
    }
    return;
  }
  final project = state.project;
  if (project == null || state.isMutating || !context.mounted) return;
  final choice = await _selectCaptureType(context);
  if (choice == null || !context.mounted) return;
  if (choice == _CaptureComposerAction.receipt) {
    await context.push(
      '/projects/${Uri.encodeComponent(project.id)}/receipt-scans/new',
    );
    return;
  }
  final type = choice.captureType!;
  if (_isAttachmentType(type)) {
    try {
      final created = await ref
          .read(capturesControllerProvider.notifier)
          .pickAttachment(type);
      if (context.mounted && created != null) {
        _message(context, AppLocalizations.of(context).captureSavedMessage);
      }
    } on Object {
      if (context.mounted) {
        _message(context, AppLocalizations.of(context).captureActionError);
      }
    }
    return;
  }
  await showCaptureEditor(context, ref, project: project, type: type);
}

Future<void> showCaptureEditor(
  BuildContext context,
  WidgetRef ref, {
  required Project project,
  CaptureDraft? draft,
  CaptureDraftType? type,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => _CaptureEditorSheet(
      project: project,
      type: draft?.type ?? type!,
      draft: draft,
    ),
  );
}

class _CaptureEditorSheet extends ConsumerStatefulWidget {
  const _CaptureEditorSheet({
    required this.project,
    required this.type,
    required this.draft,
  });

  final Project project;
  final CaptureDraftType type;
  final CaptureDraft? draft;

  @override
  ConsumerState<_CaptureEditorSheet> createState() =>
      _CaptureEditorSheetState();
}

class _CaptureEditorSheetState extends ConsumerState<_CaptureEditorSheet> {
  late final TextEditingController _title;
  late final TextEditingController _content;
  late final TextEditingController _gross;
  int? _vatRate;
  DateTime? _date;
  TimeOfDay? _time;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final input = widget.draft?.input;
    _title = TextEditingController(text: input?.title);
    _content = TextEditingController(text: input?.content);
    _gross = TextEditingController(
      text: input?.grossAmountMinorUnits == null
          ? ''
          : _minorUnitsText(input!.grossAmountMinorUnits!),
    );
    _vatRate = input?.vatRateBasisPoints ?? 2300;
    final scheduled = input?.scheduledAtUtc?.toLocal();
    _date = scheduled == null
        ? null
        : DateTime(scheduled.year, scheduled.month, scheduled.day);
    _time = scheduled == null
        ? null
        : TimeOfDay(hour: scheduled.hour, minute: scheduled.minute);
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    _gross.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
            child: Row(
              children: [
                Icon(captureTypeIcon(widget.type)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.draft == null
                        ? l10n.captureEditorNewTitle
                        : l10n.captureEditorEditTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                20 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              children: [
                TextField(
                  key: const ValueKey('captureTitleField'),
                  controller: _title,
                  maxLength: 120,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.captureTitleLabel,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  key: const ValueKey('captureContentField'),
                  controller: _content,
                  maxLength: 2000,
                  minLines: 3,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: l10n.captureContentLabel,
                    alignLabelWithHint: true,
                  ),
                ),
                if (widget.type == CaptureDraftType.cost) ...[
                  const SizedBox(height: 8),
                  TextField(
                    key: const ValueKey('captureGrossField'),
                    controller: _gross,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.captureGrossAmountLabel(
                        widget.project.currencyCode,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int?>(
                    initialValue: _vatRate,
                    decoration: InputDecoration(
                      labelText: l10n.captureVatRateLabel,
                    ),
                    items: const <DropdownMenuItem<int?>>[
                      DropdownMenuItem<int?>(value: null, child: Text('—')),
                      DropdownMenuItem<int?>(value: 0, child: Text('0%')),
                      DropdownMenuItem<int?>(value: 800, child: Text('8%')),
                      DropdownMenuItem<int?>(value: 2300, child: Text('23%')),
                    ],
                    onChanged: (value) => setState(() => _vatRate = value),
                  ),
                  const SizedBox(height: 12),
                  _Notice(
                    icon: Icons.account_balance_wallet_outlined,
                    text: l10n.captureCostDraftNotice,
                  ),
                ],
                if (widget.type == CaptureDraftType.task) ...[
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        key: const ValueKey('captureDateButton'),
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: Text(
                          _date == null
                              ? l10n.captureChooseDateAction
                              : DateFormat(
                                  'dd.MM.yyyy',
                                  'pl_PL',
                                ).format(_date!),
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        key: const ValueKey('captureTimeButton'),
                        onPressed: _pickTime,
                        icon: const Icon(Icons.schedule_outlined),
                        label: Text(
                          _time == null
                              ? l10n.captureChooseTimeAction
                              : _time!.format(context),
                        ),
                      ),
                    ],
                  ),
                ],
                if (widget.type == CaptureDraftType.voice) ...[
                  const SizedBox(height: 12),
                  _Notice(
                    icon: Icons.mic_none_rounded,
                    text: l10n.captureVoiceNotice,
                  ),
                ],
                if (_isAttachmentType(widget.type)) ...[
                  const SizedBox(height: 12),
                  _Notice(
                    icon: Icons.lock_outline_rounded,
                    text: l10n.captureFileNotice,
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton.icon(
                  key: const ValueKey('captureSaveButton'),
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    widget.draft == null
                        ? l10n.captureSaveDraftAction
                        : l10n.captureUpdateAction,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (result != null) setState(() => _date = result);
  }

  Future<void> _pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (result != null) setState(() => _time = result);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final schedule = await _scheduleValue();
      final input = CaptureDraftInput(
        projectId: widget.project.id,
        type: widget.type,
        title: _title.text,
        content: _content.text,
        attachmentIds: widget.draft?.attachmentIds ?? const <String>[],
        grossAmountMinorUnits: widget.type == CaptureDraftType.cost
            ? _parseMinorUnits(_gross.text)
            : null,
        vatRateBasisPoints: widget.type == CaptureDraftType.cost
            ? _vatRate
            : null,
        scheduledAt: schedule?.instant,
        timeZoneId: schedule?.timeZoneId,
      );
      final controller = ref.read(capturesControllerProvider.notifier);
      if (widget.draft == null) {
        await controller.create(input);
      } else {
        await controller.updateCapture(widget.draft!.id, input);
      }
      if (mounted) Navigator.pop(context);
    } on Object {
      if (mounted) {
        _message(context, AppLocalizations.of(context).captureActionError);
        setState(() => _saving = false);
      }
    }
  }

  Future<({DateTime instant, String timeZoneId})?> _scheduleValue() async {
    if (widget.type != CaptureDraftType.task ||
        _date == null ||
        _time == null) {
      return null;
    }
    final gateway = ref.read(scheduleNotificationGatewayProvider);
    String timeZoneId;
    try {
      timeZoneId = await gateway.currentTimeZoneId();
    } on Object {
      timeZoneId = 'Etc/UTC';
    }
    final wallTime = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );
    return (
      instant: gateway.fromWallTime(wallTime, timeZoneId),
      timeZoneId: timeZoneId,
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 9),
        Expanded(child: Text(text)),
      ],
    );
  }
}

enum _CaptureComposerAction {
  receipt,
  photo,
  document,
  note,
  voice,
  cost,
  task,
  decision,
  defect;

  CaptureDraftType? get captureType => switch (this) {
    _CaptureComposerAction.receipt => null,
    _CaptureComposerAction.photo => CaptureDraftType.photo,
    _CaptureComposerAction.document => CaptureDraftType.document,
    _CaptureComposerAction.note => CaptureDraftType.note,
    _CaptureComposerAction.voice => CaptureDraftType.voice,
    _CaptureComposerAction.cost => CaptureDraftType.cost,
    _CaptureComposerAction.task => CaptureDraftType.task,
    _CaptureComposerAction.decision => CaptureDraftType.decision,
    _CaptureComposerAction.defect => CaptureDraftType.defect,
  };
}

Future<_CaptureComposerAction?> _selectCaptureType(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<_CaptureComposerAction>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.82,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.captureAddTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final textScale =
                      MediaQuery.textScalerOf(context).scale(14) / 14;
                  final itemHeight =
                      124.0 + ((textScale - 1).clamp(0.0, 2.0) * 60.0);
                  return GridView.builder(
                    key: const ValueKey('captureTypeGrid'),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: constraints.maxWidth >= 520 ? 4 : 2,
                      mainAxisExtent: itemHeight,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                    ),
                    itemCount: _CaptureComposerAction.values.length,
                    itemBuilder: (context, index) {
                      final action = _CaptureComposerAction.values[index];
                      final type = action.captureType;
                      return InkWell(
                        key: ValueKey('captureType-${action.name}'),
                        onTap: () => Navigator.pop(context, action),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                type == null
                                    ? Icons.document_scanner_outlined
                                    : captureTypeIcon(type),
                                size: 27,
                              ),
                              const SizedBox(height: 7),
                              Text(
                                type == null
                                    ? l10n.captureTypeReceiptInvoice
                                    : captureTypeLabel(l10n, type),
                                maxLines: 3,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _showMergePicker(
  BuildContext context,
  WidgetRef ref, {
  required CaptureDraft retained,
  required List<CaptureDraft> candidates,
}) async {
  final l10n = AppLocalizations.of(context);
  final mergedId = await showModalBottomSheet<String>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.65,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              l10n.captureMergeTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (candidates.isEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(l10n.captureMergeEmpty),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: candidates.length,
                itemBuilder: (context, index) {
                  final candidate = candidates[index];
                  return ListTile(
                    leading: Icon(captureTypeIcon(candidate.type)),
                    title: Text(
                      candidate.title ?? captureTypeLabel(l10n, candidate.type),
                    ),
                    subtitle: candidate.content == null
                        ? null
                        : Text(
                            candidate.content!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    onTap: () => Navigator.pop(context, candidate.id),
                  );
                },
              ),
            ),
        ],
      ),
    ),
  );
  if (mergedId == null || !context.mounted) return;
  try {
    await ref
        .read(capturesControllerProvider.notifier)
        .merge(retained.id, mergedId);
  } on Object {
    if (context.mounted) _message(context, l10n.captureActionError);
  }
}

Future<void> _confirmReject(
  BuildContext context,
  WidgetRef ref,
  CaptureDraft draft,
) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.captureRejectTitle),
      content: Text(l10n.captureRejectMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancelAction),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.deleteAction),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  try {
    await ref.read(capturesControllerProvider.notifier).reject(draft.id);
  } on Object {
    if (context.mounted) _message(context, l10n.captureActionError);
  }
}

Future<void> _classify(
  BuildContext context,
  WidgetRef ref,
  String captureId,
) async {
  final l10n = AppLocalizations.of(context);
  try {
    await ref.read(capturesControllerProvider.notifier).classify(captureId);
    if (context.mounted) _message(context, l10n.captureApprovedMessage);
  } on Object {
    if (context.mounted) _message(context, l10n.captureActionError);
  }
}

String _captureStatusText(AppLocalizations l10n, CaptureDraft draft) {
  if (draft.status == CaptureDraftStatus.classified) {
    return switch (draft.targetType!) {
      CaptureTargetType.document => l10n.captureClassifiedDocument,
      CaptureTargetType.costDraft => l10n.captureClassifiedCost,
      CaptureTargetType.scheduleTask => l10n.captureClassifiedTask,
      CaptureTargetType.note => l10n.captureClassifiedNote,
      CaptureTargetType.decision => l10n.captureClassifiedDecision,
      CaptureTargetType.defect => l10n.captureClassifiedDefect,
    };
  }
  if (draft.status == CaptureDraftStatus.ready) {
    return l10n.captureStatusReady;
  }
  return l10n.captureMissingFields(
    draft.missingContext
        .map((value) => _missingContextLabel(l10n, value))
        .join(', '),
  );
}

String _missingContextLabel(
  AppLocalizations l10n,
  CaptureMissingContext value,
) => switch (value) {
  CaptureMissingContext.title => l10n.captureMissingTitle,
  CaptureMissingContext.content => l10n.captureMissingContent,
  CaptureMissingContext.attachment => l10n.captureMissingAttachment,
  CaptureMissingContext.grossAmount => l10n.captureMissingGrossAmount,
  CaptureMissingContext.vatRate => l10n.captureMissingVatRate,
  CaptureMissingContext.scheduledAt => l10n.captureMissingScheduledAt,
};

String captureTypeLabel(AppLocalizations l10n, CaptureDraftType type) =>
    switch (type) {
      CaptureDraftType.photo => l10n.captureTypePhoto,
      CaptureDraftType.document => l10n.captureTypeDocument,
      CaptureDraftType.note => l10n.captureTypeNote,
      CaptureDraftType.voice => l10n.captureTypeVoice,
      CaptureDraftType.cost => l10n.captureTypeCost,
      CaptureDraftType.task => l10n.captureTypeTask,
      CaptureDraftType.decision => l10n.captureTypeDecision,
      CaptureDraftType.defect => l10n.captureTypeDefect,
    };

IconData captureTypeIcon(CaptureDraftType type) => switch (type) {
  CaptureDraftType.photo => Icons.photo_camera_outlined,
  CaptureDraftType.document => Icons.description_outlined,
  CaptureDraftType.note => Icons.sticky_note_2_outlined,
  CaptureDraftType.voice => Icons.mic_none_rounded,
  CaptureDraftType.cost => Icons.payments_outlined,
  CaptureDraftType.task => Icons.event_outlined,
  CaptureDraftType.decision => Icons.rule_folder_outlined,
  CaptureDraftType.defect => Icons.report_problem_outlined,
};

bool _isAttachmentType(CaptureDraftType type) =>
    type == CaptureDraftType.photo ||
    type == CaptureDraftType.document ||
    type == CaptureDraftType.voice;

bool _canMergeType(CaptureDraftType type) =>
    type != CaptureDraftType.cost && type != CaptureDraftType.task;

String _minorUnitsText(int value) {
  final whole = value ~/ 100;
  final fraction = (value % 100).abs().toString().padLeft(2, '0');
  return '$whole,$fraction';
}

int? _parseMinorUnits(String raw) {
  final normalized = raw
      .trim()
      .replaceAll(RegExp(r'\s'), '')
      .replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(normalized)) {
    throw const FormatException('Invalid amount');
  }
  final parts = normalized.split('.');
  final fraction = parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0'));
  final result = int.parse(parts[0]) * 100 + fraction;
  if (result <= 0) throw const FormatException('Invalid amount');
  return result;
}

void _message(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}
