import 'package:budowapro/features/documents/domain/project_document.dart';
import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import 'document_editor_gateway.dart';
import 'document_ui_text.dart';

class DocumentFormScreen extends ConsumerWidget {
  const DocumentFormScreen({
    required this.projectId,
    required this.documentId,
    this.isNew = false,
    super.key,
  });

  final String projectId;
  final String documentId;
  final bool isNew;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gateway = ref.watch(documentEditorGatewayProvider);
    final title = isNew
        ? AppLocalizations.of(context).documentNewTitle
        : AppLocalizations.of(context).documentEditTitle;
    return gateway.when(
      loading: () => _DocumentFormScaffold(
        title: title,
        child: AppLoadingState(label: title),
      ),
      error: (error, stackTrace) => _DocumentFormScaffold(
        title: title,
        child: AppErrorState(
          title: AppLocalizations.of(context).documentLoadError,
          retryLabel: AppLocalizations.of(context).retryAction,
          onRetry: () => ref.invalidate(documentEditorGatewayProvider),
        ),
      ),
      data: (value) => _DocumentFormLoader(
        key: ValueKey('$projectId/$documentId/$isNew'),
        gateway: value,
        projectId: projectId,
        documentId: documentId,
        isNew: isNew,
      ),
    );
  }
}

class _DocumentFormLoader extends StatefulWidget {
  const _DocumentFormLoader({
    required this.gateway,
    required this.projectId,
    required this.documentId,
    required this.isNew,
    super.key,
  });

  final DocumentEditorGateway gateway;
  final String projectId;
  final String documentId;
  final bool isNew;

  @override
  State<_DocumentFormLoader> createState() => _DocumentFormLoaderState();
}

class _DocumentFormLoaderState extends State<_DocumentFormLoader> {
  late Future<DocumentEditorData> _load;

  @override
  void initState() {
    super.initState();
    _load = _request();
  }

  Future<DocumentEditorData> _request() => widget.gateway.load(
    projectId: widget.projectId,
    documentId: widget.documentId,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = widget.isNew ? l10n.documentNewTitle : l10n.documentEditTitle;
    return FutureBuilder<DocumentEditorData>(
      future: _load,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _DocumentFormScaffold(
            title: title,
            child: AppLoadingState(label: title),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return _DocumentFormScaffold(
            title: title,
            child: AppErrorState(
              title: snapshot.error is DocumentEditorNotFoundException
                  ? l10n.documentNotFoundTitle
                  : l10n.documentLoadError,
              retryLabel: l10n.retryAction,
              onRetry: () => setState(() => _load = _request()),
            ),
          );
        }
        return _DocumentForm(
          gateway: widget.gateway,
          data: snapshot.data!,
          isNew: widget.isNew,
        );
      },
    );
  }
}

class _DocumentForm extends StatefulWidget {
  const _DocumentForm({
    required this.gateway,
    required this.data,
    required this.isNew,
  });

  final DocumentEditorGateway gateway;
  final DocumentEditorData data;
  final bool isNew;

  @override
  State<_DocumentForm> createState() => _DocumentFormState();
}

class _DocumentFormState extends State<_DocumentForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _roomController = TextEditingController();

  late ProjectDocumentType _type;
  DateTime? _documentDate;
  String? _stageId;
  String? _contactId;
  var _hasWarranty = false;
  DateTime? _warrantyStart;
  DateTime? _warrantyEnd;
  DateTime? _warrantyReminder;
  var _isDirty = false;
  var _isSubmitting = false;
  var _allowPop = false;
  String? _error;

  ProjectDocument get _document => widget.data.document;

  @override
  void initState() {
    super.initState();
    final metadata = _document.metadata;
    _titleController.text = metadata.title;
    _descriptionController.text = metadata.description ?? '';
    _type = widget.isNew && metadata.type == ProjectDocumentType.other
        ? _suggestedType(_document.displayName, _document.mediaType)
        : metadata.type;
    _documentDate = metadata.documentDateUtc?.toLocal();
    _hasWarranty = metadata.warrantyEndsAtUtc != null;
    _warrantyStart = metadata.warrantyStartsAtUtc?.toLocal();
    _warrantyEnd = metadata.warrantyEndsAtUtc?.toLocal();
    _warrantyReminder = metadata.warrantyReminderAtUtc?.toLocal();
    if (widget.isNew &&
        _type == ProjectDocumentType.warranty &&
        !_hasWarranty) {
      _enableWarranty();
    }
    for (final relation in _document.relations) {
      switch (relation.type) {
        case DocumentRelationType.stage:
          _stageId = relation.targetId;
        case DocumentRelationType.contact:
          _contactId = relation.targetId;
        case DocumentRelationType.room:
          _roomController.text = relation.label;
        default:
          break;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _DocumentFormScaffold(
      title: widget.isNew ? l10n.documentNewTitle : l10n.documentEditTitle,
      child: PopScope<bool>(
        canPop: _allowPop || !_isDirty,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _confirmDiscard();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isSubmitting) const LinearProgressIndicator(),
                if (_error != null) ...[
                  Material(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(_error!),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  key: const ValueKey('documentTitleField'),
                  controller: _titleController,
                  enabled: !_isSubmitting,
                  maxLength: 160,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.documentTitleLabel,
                    prefixIcon: const Icon(Icons.description_outlined),
                  ),
                  onChanged: (_) => _markDirty(),
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<ProjectDocumentType>(
                  key: ValueKey('documentType-${_type.name}'),
                  initialValue: _type,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.documentTypeLabel,
                    prefixIcon: const Icon(Icons.category_outlined),
                  ),
                  items: ProjectDocumentType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(documentTypeLabel(l10n, type)),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          if (value == null) return;
                          _change(() {
                            _type = value;
                            if (value == ProjectDocumentType.warranty &&
                                !_hasWarranty) {
                              _enableWarranty();
                            }
                          });
                        },
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const ValueKey('documentDescriptionField'),
                  controller: _descriptionController,
                  enabled: !_isSubmitting,
                  maxLength: 2000,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: l10n.documentDescriptionLabel,
                    alignLabelWithHint: true,
                  ),
                  onChanged: (_) => _markDirty(),
                ),
                const SizedBox(height: 12),
                _DateInput(
                  label: l10n.documentDateLabel,
                  value: _documentDate,
                  enabled: !_isSubmitting,
                  onChanged: (value) => _change(() => _documentDate = value),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.documentRelationsHeading,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String?>(
                  key: ValueKey('documentStage-${_stageId ?? 'none'}'),
                  initialValue: _stageId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.documentStageLabel,
                    prefixIcon: const Icon(Icons.account_tree_outlined),
                  ),
                  items: <DropdownMenuItem<String?>>[
                    DropdownMenuItem(
                      value: null,
                      child: Text(l10n.documentNoStage),
                    ),
                    ...widget.data.stages.map(
                      (stage) => DropdownMenuItem(
                        value: stage.id,
                        child: Text(
                          stageName(l10n, stage),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: _isSubmitting
                      ? null
                      : (value) => _change(() => _stageId = value),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const ValueKey('documentRoomField'),
                  controller: _roomController,
                  enabled: !_isSubmitting,
                  maxLength: 160,
                  decoration: InputDecoration(
                    labelText: l10n.documentRoomLabel,
                    prefixIcon: const Icon(Icons.meeting_room_outlined),
                  ),
                  onChanged: (_) => _markDirty(),
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<String?>(
                  key: ValueKey('documentContact-${_contactId ?? 'none'}'),
                  initialValue: _contactId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.documentContactLabel,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  items: <DropdownMenuItem<String?>>[
                    DropdownMenuItem(
                      value: null,
                      child: Text(l10n.documentNoContact),
                    ),
                    ...widget.data.contacts.map(
                      (contact) => DropdownMenuItem(
                        value: contact.id,
                        child: Text(
                          contact.displayName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: _isSubmitting
                      ? null
                      : (value) => _change(() => _contactId = value),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.documentWarrantySection,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.documentWarrantyEnabledLabel),
                  value: _hasWarranty,
                  onChanged: _isSubmitting
                      ? null
                      : (value) => _change(() {
                          if (value) {
                            _enableWarranty();
                          } else {
                            _hasWarranty = false;
                            _warrantyStart = null;
                            _warrantyEnd = null;
                            _warrantyReminder = null;
                          }
                        }),
                ),
                if (_hasWarranty) ...[
                  const SizedBox(height: 4),
                  _DateInput(
                    label: l10n.documentWarrantyStartLabel,
                    value: _warrantyStart,
                    enabled: !_isSubmitting,
                    requiredField: true,
                    onChanged: (value) => _change(() => _warrantyStart = value),
                  ),
                  const SizedBox(height: 12),
                  _DateInput(
                    label: l10n.documentWarrantyEndLabel,
                    value: _warrantyEnd,
                    enabled: !_isSubmitting,
                    requiredField: true,
                    onChanged: (value) => _change(() {
                      _warrantyEnd = value;
                      if (value != null &&
                          (_warrantyReminder == null ||
                              _warrantyReminder!.isAfter(value))) {
                        _warrantyReminder = value.subtract(
                          const Duration(days: 30),
                        );
                      }
                    }),
                  ),
                  const SizedBox(height: 12),
                  _DateInput(
                    label: l10n.documentWarrantyReminderLabel,
                    value: _warrantyReminder,
                    enabled: !_isSubmitting,
                    onChanged: (value) =>
                        _change(() => _warrantyReminder = value),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.documentWarrantyReminderHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 28),
                FilledButton.icon(
                  key: const ValueKey('saveDocumentButton'),
                  onPressed: _isSubmitting ? null : _submit,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(l10n.saveAction),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _enableWarranty() {
    final start = _documentDate ?? DateTime.now();
    _hasWarranty = true;
    _warrantyStart ??= start;
    _warrantyEnd ??= DateTime(start.year + 2, start.month, start.day);
    _warrantyReminder ??= _warrantyEnd!.subtract(const Duration(days: 30));
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  void _change(VoidCallback change) {
    setState(() {
      change();
      _isDirty = true;
      _error = null;
    });
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_titleController.text.trim().isEmpty) {
      setState(() => _error = l10n.documentRequiredFieldsError);
      return;
    }
    if (_hasWarranty &&
        (_warrantyStart == null ||
            _warrantyEnd == null ||
            _warrantyEnd!.isBefore(_warrantyStart!) ||
            (_warrantyReminder?.isAfter(_warrantyEnd!) ?? false))) {
      setState(() => _error = l10n.documentWarrantyDatesError);
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await widget.gateway.save(
        projectId: _document.projectId,
        documentId: _document.id,
        metadata: DocumentMetadata(
          title: _titleController.text,
          type: _type,
          description: _descriptionController.text,
          documentDate: _documentDate,
          warrantyStartsAt: _hasWarranty ? _warrantyStart : null,
          warrantyEndsAt: _hasWarranty
              ? _inclusiveEndOfDay(_warrantyEnd!)
              : null,
          warrantyReminderAt: _hasWarranty ? _warrantyReminder : null,
        ),
        contextLinks: _contextLinks(l10n),
      );
      if (mounted) {
        _allowPop = true;
        Navigator.pop(context, true);
      }
    } on Object {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _error = l10n.documentSaveError;
        });
      }
    }
  }

  List<DocumentRelation> _contextLinks(AppLocalizations l10n) {
    final links = <DocumentRelation>[];
    final stageId = _stageId;
    if (stageId != null) {
      final stage = widget.data.stages.firstWhere(
        (candidate) => candidate.id == stageId,
      );
      links.add(
        DocumentRelation(
          type: DocumentRelationType.stage,
          targetId: stageId,
          label: stageName(l10n, stage),
        ),
      );
    }
    final room = _roomController.text.trim();
    if (room.isNotEmpty) {
      links.add(
        DocumentRelation(
          type: DocumentRelationType.room,
          targetId: normalizedRoomId(room),
          label: room,
        ),
      );
    }
    final contactId = _contactId;
    if (contactId != null) {
      final contact = widget.data.contacts.firstWhere(
        (candidate) => candidate.id == contactId,
      );
      links.add(
        DocumentRelation(
          type: DocumentRelationType.contact,
          targetId: contactId,
          label: contact.displayName,
        ),
      );
    }
    return links;
  }

  Future<void> _confirmDiscard() async {
    final l10n = AppLocalizations.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.unsavedChangesTitle),
        content: Text(l10n.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.discardChangesAction),
          ),
        ],
      ),
    );
    if (discard == true && mounted) {
      _allowPop = true;
      Navigator.pop(context, false);
    }
  }
}

class _DateInput extends StatelessWidget {
  const _DateInput({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.requiredField = false,
  });

  final String label;
  final DateTime? value;
  final bool enabled;
  final bool requiredField;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: enabled ? () => _pick(context) : null,
    borderRadius: BorderRadius.circular(6),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: requiredField ? '$label *' : label,
        prefixIcon: const Icon(Icons.event_outlined),
        suffixIcon: value == null || !enabled
            ? null
            : IconButton(
                tooltip: AppLocalizations.of(context).clearAction,
                onPressed: () => onChanged(null),
                icon: const Icon(Icons.clear),
              ),
      ),
      child: Text(value == null ? ' ' : DateFormat.yMd('pl').format(value!)),
    ),
  );

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 30),
    );
    if (selected != null) onChanged(selected);
  }
}

class _DocumentFormScaffold extends StatelessWidget {
  const _DocumentFormScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: child,
  );
}

ProjectDocumentType _suggestedType(String fileName, String? mediaType) {
  final value = p.basenameWithoutExtension(fileName).toLowerCase();
  if (value.contains('paragon')) return ProjectDocumentType.receipt;
  if (value.contains('faktura')) return ProjectDocumentType.invoice;
  if (value.contains('oferta')) return ProjectDocumentType.quote;
  if (value.contains('umowa')) return ProjectDocumentType.contract;
  if (RegExp(r'(^|[^a-z])wz([^a-z]|$)').hasMatch(value)) {
    return ProjectDocumentType.deliveryNote;
  }
  if (value.contains('protok')) return ProjectDocumentType.protocol;
  if (value.contains('gwaranc')) return ProjectDocumentType.warranty;
  if (value.contains('instruk')) return ProjectDocumentType.instruction;
  if (value.contains('mapa') || value.contains('rzut')) {
    return ProjectDocumentType.map;
  }
  if (mediaType?.startsWith('image/') ?? false) {
    return ProjectDocumentType.photo;
  }
  return ProjectDocumentType.other;
}

DateTime _inclusiveEndOfDay(DateTime value) =>
    DateTime(value.year, value.month, value.day, 23, 59, 59, 999);
