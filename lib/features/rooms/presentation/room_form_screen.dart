import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/presentation/cost_form_model.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/features/rooms/data/room_providers.dart';
import 'package:budowapro/features/rooms/domain/room.dart';
import 'package:budowapro/features/rooms/domain/room_repository.dart';
import 'package:budowapro/features/rooms/presentation/room_ui_text.dart';
import 'package:budowapro/features/rooms/presentation/rooms_controller.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoomFormScreen extends ConsumerStatefulWidget {
  const RoomFormScreen({required this.projectId, this.roomId, super.key});

  final String projectId;
  final String? roomId;

  @override
  ConsumerState<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends ConsumerState<RoomFormScreen> {
  late Future<_RoomEditorData> _load;

  @override
  void initState() {
    super.initState();
    _load = _request();
  }

  Future<_RoomEditorData> _request() async {
    final projects = await ref.read(projectsControllerProvider.future);
    Project? project;
    for (final candidate in projects.projects) {
      if (candidate.id == widget.projectId) {
        project = candidate;
        break;
      }
    }
    if (project == null) throw const RoomNotFoundException();
    final repository = await ref.read(roomRepositoryProvider.future);
    final roomId = widget.roomId;
    final room = roomId == null
        ? null
        : await repository.findRoom(
            projectId: widget.projectId,
            roomId: roomId,
          );
    if (roomId != null && room == null) throw const RoomNotFoundException();
    return _RoomEditorData(
      project: project,
      repository: repository,
      room: room,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = widget.roomId == null
        ? l10n.roomNewTitle
        : l10n.roomEditTitle;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<_RoomEditorData>(
        future: _load,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return AppLoadingState(label: title);
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return AppErrorState(
              title: snapshot.error is RoomNotFoundException
                  ? l10n.roomNotFound
                  : l10n.roomsLoadError,
              retryLabel: l10n.retryAction,
              onRetry: () => setState(() {
                _load = _request();
              }),
            );
          }
          return _RoomForm(
            key: ValueKey('${widget.projectId}/${widget.roomId}'),
            data: snapshot.data!,
            onSaved: () {
              ref.invalidate(roomsControllerProvider);
              if (context.mounted) Navigator.of(context).pop(true);
            },
          );
        },
      ),
    );
  }
}

final class _RoomEditorData {
  const _RoomEditorData({
    required this.project,
    required this.repository,
    required this.room,
  });

  final Project project;
  final RoomRepository repository;
  final Room? room;
}

class _RoomForm extends StatefulWidget {
  const _RoomForm({required this.data, required this.onSaved, super.key});

  final _RoomEditorData data;
  final VoidCallback onSaved;

  @override
  State<_RoomForm> createState() => _RoomFormState();
}

class _RoomFormState extends State<_RoomForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _floor = TextEditingController();
  final _length = TextEditingController();
  final _width = TextEditingController();
  final _height = TextEditingController();
  final _budget = TextEditingController();
  final _note = TextEditingController();
  late RoomStandard _standard;
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final room = widget.data.room;
    _name.text = room?.name ?? '';
    _floor.text = room?.floorLabel ?? '';
    _length.text = _dimensionText(room?.dimensions?.lengthMillimeters);
    _width.text = _dimensionText(room?.dimensions?.widthMillimeters);
    _height.text = _dimensionText(room?.dimensions?.heightMillimeters);
    _budget.text = room?.plannedBudget == null
        ? ''
        : formatMinorUnitsForInput(room!.plannedBudget!.minorUnits);
    _note.text = room?.note ?? '';
    _standard = room?.standard ?? RoomStandard.standard;
  }

  @override
  void dispose() {
    for (final controller in <TextEditingController>[
      _name,
      _floor,
      _length,
      _width,
      _height,
      _budget,
      _note,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          TextFormField(
            key: const ValueKey('roomNameField'),
            controller: _name,
            maxLength: RoomFieldLimits.name,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: l10n.roomNameLabel),
            validator: (value) => value == null || value.trim().isEmpty
                ? l10n.requiredFieldError
                : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _floor,
            maxLength: RoomFieldLimits.floor,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: l10n.roomFloorLabel),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<RoomStandard>(
            initialValue: _standard,
            decoration: InputDecoration(labelText: l10n.roomStandardLabel),
            items: RoomStandard.values
                .map(
                  (value) => DropdownMenuItem<RoomStandard>(
                    value: value,
                    child: Text(roomStandardLabel(l10n, value)),
                  ),
                )
                .toList(growable: false),
            onChanged: _saving
                ? null
                : (value) => setState(() => _standard = value ?? _standard),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.roomDimensionsTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final fields = <Widget>[
                _DimensionField(
                  controller: _length,
                  label: l10n.roomLengthLabel,
                ),
                _DimensionField(controller: _width, label: l10n.roomWidthLabel),
                _DimensionField(
                  controller: _height,
                  label: l10n.roomHeightLabel,
                ),
              ];
              if (constraints.maxWidth < 430) {
                return Column(
                  children: fields
                      .map(
                        (field) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: field,
                        ),
                      )
                      .toList(growable: false),
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: fields
                    .map(
                      (field) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: field,
                        ),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: const ValueKey('roomBudgetField'),
            controller: _budget,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.\s]')),
            ],
            decoration: InputDecoration(
              labelText: l10n.roomBudgetLabel,
              suffixText: widget.data.project.currencyCode,
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? null
                : _parseMinorUnits(value) == null
                ? l10n.invalidAmountError
                : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _note,
            minLines: 3,
            maxLines: 6,
            maxLength: RoomFieldLimits.note,
            decoration: InputDecoration(labelText: l10n.roomNoteLabel),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const ValueKey('roomSaveButton'),
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(l10n.roomSaveAction),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final length = _parseMillimeters(_length.text);
      final width = _parseMillimeters(_width.text);
      final height = _parseMillimeters(_height.text);
      final budgetMinor = _parseMinorUnits(_budget.text);
      final input = RoomInput(
        projectId: widget.data.project.id,
        name: _name.text,
        floorLabel: _floor.text,
        standard: _standard,
        dimensions: length == null && width == null && height == null
            ? null
            : RoomDimensions(
                lengthMillimeters: length,
                widthMillimeters: width,
                heightMillimeters: height,
              ),
        plannedBudget: budgetMinor == null
            ? null
            : Money(
                minorUnits: budgetMinor,
                currencyCode: widget.data.project.currencyCode,
              ),
        note: _note.text,
      );
      final existing = widget.data.room;
      if (existing == null) {
        await widget.data.repository.createRoom(input);
      } else {
        await widget.data.repository.updateRoom(
          projectId: existing.projectId,
          roomId: existing.id,
          input: input,
        );
      }
      widget.onSaved();
    } on RoomConflictException {
      if (mounted) setState(() => _error = l10n.roomConflictError);
    } on Object {
      if (mounted) setState(() => _error = l10n.roomSaveError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _DimensionField extends StatelessWidget {
  const _DimensionField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        suffixText: l10n.roomMetersSuffix,
      ),
      validator: (value) => value == null || value.trim().isEmpty
          ? null
          : _parseMillimeters(value) == null
          ? l10n.invalidNumberError
          : null,
    );
  }
}

int? _parseMinorUnits(String source) {
  final normalized = source.replaceAll(RegExp(r'[\s\u00A0]'), '');
  if (normalized.isEmpty) return null;
  if (!RegExp(r'^\d+(?:[,.]\d{1,2})?$').hasMatch(normalized)) return null;
  final parts = normalized.replaceAll(',', '.').split('.');
  final fraction = parts.length == 1 ? '00' : parts[1].padRight(2, '0');
  final value =
      BigInt.parse(parts[0]) * BigInt.from(100) + BigInt.parse(fraction);
  if (value > BigInt.from(Money.maximumMinorUnits)) return null;
  return value.toInt();
}

int? _parseMillimeters(String source) {
  final normalized = source.trim().replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  if (!RegExp(r'^\d{1,3}(?:\.\d{1,3})?$').hasMatch(normalized)) return null;
  final parts = normalized.split('.');
  final fraction = parts.length == 1 ? '000' : parts[1].padRight(3, '0');
  final value = int.parse(parts[0]) * 1000 + int.parse(fraction);
  return value > 0 && value <= 1000000 ? value : null;
}

String _dimensionText(int? value) =>
    value == null ? '' : formatRoomDimension(value);
