import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/features/technical_photos/domain/technical_photo.dart';
import 'package:budowapro/features/technical_photos/presentation/technical_photo_editor_gateway.dart';
import 'package:budowapro/features/technical_photos/presentation/technical_photo_ui_text.dart';
import 'package:budowapro/features/technical_photos/presentation/technical_photos_controller.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TechnicalPhotoFormScreen extends ConsumerWidget {
  const TechnicalPhotoFormScreen({
    required this.projectId,
    required this.attachmentId,
    required this.isNew,
    super.key,
  });

  final String projectId;
  final String attachmentId;
  final bool isNew;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final target = (projectId: projectId, attachmentId: attachmentId);
    final data = ref.watch(technicalPhotoEditorDataProvider(target));
    return data.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text(
            isNew ? l10n.technicalPhotoNewTitle : l10n.technicalPhotoEditTitle,
          ),
        ),
        body: AppLoadingState(label: l10n.technicalPhotosLoading),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: Text(l10n.technicalPhotoEditTitle)),
        body: AppErrorState(
          title: l10n.technicalPhotoNotFound,
          retryLabel: l10n.retryAction,
          onRetry: () =>
              ref.invalidate(technicalPhotoEditorDataProvider(target)),
        ),
      ),
      data: (value) =>
          _TechnicalPhotoForm(data: value, isNew: isNew, target: target),
    );
  }
}

class _TechnicalPhotoForm extends ConsumerStatefulWidget {
  const _TechnicalPhotoForm({
    required this.data,
    required this.isNew,
    required this.target,
  });

  final TechnicalPhotoEditorData data;
  final bool isNew;
  final TechnicalPhotoEditorTarget target;

  @override
  ConsumerState<_TechnicalPhotoForm> createState() =>
      _TechnicalPhotoFormState();
}

class _TechnicalPhotoFormState extends ConsumerState<_TechnicalPhotoForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _zone;
  late final TextEditingController _description;
  late final TextEditingController _tags;
  late String? _albumId;
  late String? _stageId;
  late String? _contactId;
  late String? _checklistItemId;
  late List<TechnicalPhotoLink> _links;
  late TechnicalInstallationType _installationType;
  late DateTime _capturedAt;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final photo = widget.data.photo;
    _albumId = photo?.albumId ?? widget.data.albums.firstOrNull?.album.id;
    final initialAlbum = _selectedAlbum(_albumId);
    _stageId = photo?.stageId ?? initialAlbum?.stageId;
    _contactId = photo?.contractorContactId;
    _checklistItemId = photo?.checklistItemId;
    _links = photo?.links.toList() ?? <TechnicalPhotoLink>[];
    _installationType =
        photo?.installationType ?? TechnicalInstallationType.other;
    _capturedAt = (photo?.capturedAtUtc ?? widget.data.attachment.importedAtUtc)
        .toLocal();
    _title = TextEditingController(
      text: photo?.title ?? _fileStem(widget.data.attachment.displayName),
    );
    _zone = TextEditingController(text: photo?.zoneLabel);
    _description = TextEditingController(text: photo?.description);
    _tags = TextEditingController(text: photo?.tags.join(', '));
  }

  @override
  void dispose() {
    _title.dispose();
    _zone.dispose();
    _description.dispose();
    _tags.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final checklistItems = widget.data.checklistItems
        .where((item) => _stageId == null || item.stageId == _stageId)
        .toList(growable: false);
    return Scaffold(
      key: const ValueKey('technicalPhotoFormScreen'),
      appBar: AppBar(
        title: Text(
          widget.isNew
              ? l10n.technicalPhotoNewTitle
              : l10n.technicalPhotoEditTitle,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            _preview(context),
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('technicalPhotoTitleField'),
              controller: _title,
              maxLength: 160,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.technicalPhotoTitleLabel,
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? l10n.technicalPhotoSaveError
                  : null,
            ),
            DropdownButtonFormField<String>(
              initialValue: _albumId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.technicalFilterAlbumLabel,
              ),
              items: widget.data.albums
                  .map(
                    (overview) => DropdownMenuItem<String>(
                      value: overview.album.id,
                      child: Text(
                        overview.album.title,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(growable: false),
              validator: (value) =>
                  value == null ? l10n.technicalAlbumRequiredError : null,
              onChanged: _saving
                  ? null
                  : (value) {
                      final album = _selectedAlbum(value);
                      setState(() {
                        _albumId = value;
                        if (album?.stageId != null) {
                          _stageId = album!.stageId;
                          if (!_checklistBelongsToStage(
                            _checklistItemId,
                            _stageId,
                          )) {
                            _checklistItemId = null;
                          }
                        }
                      });
                    },
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(l10n.technicalPhotoDateLabel),
              subtitle: Text(
                DateFormat('dd.MM.yyyy', 'pl_PL').format(_capturedAt),
              ),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: _saving ? null : _pickDate,
            ),
            DropdownButtonFormField<TechnicalInstallationType>(
              initialValue: _installationType,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.technicalFilterInstallationLabel,
              ),
              items: TechnicalInstallationType.values
                  .map(
                    (type) => DropdownMenuItem<TechnicalInstallationType>(
                      value: type,
                      child: Text(
                        technicalInstallationLabel(l10n, type),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: _saving
                  ? null
                  : (value) => setState(
                      () => _installationType = value ?? _installationType,
                    ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _stageId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.technicalFilterStageLabel,
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(l10n.technicalPhotoNoStage),
                ),
                ...widget.data.stages.map(
                  (stage) => DropdownMenuItem<String?>(
                    value: stage.id,
                    child: Text(
                      stageName(l10n, stage),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: _saving
                  ? null
                  : (value) => setState(() {
                      _stageId = value;
                      if (!_checklistBelongsToStage(
                        _checklistItemId,
                        _stageId,
                      )) {
                        _checklistItemId = null;
                      }
                    }),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _zone,
              maxLength: 120,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.technicalPhotoZoneLabel,
              ),
            ),
            DropdownButtonFormField<String?>(
              initialValue: _contactId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.technicalPhotoContractorLabel,
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(l10n.technicalPhotoNoContact),
                ),
                ...widget.data.contacts.map(_contactItem),
              ],
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _contactId = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: ValueKey<String?>('technicalPhotoChecklist-$_stageId'),
              initialValue:
                  checklistItems.any((item) => item.id == _checklistItemId)
                  ? _checklistItemId
                  : null,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.technicalPhotoChecklistLabel,
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(l10n.technicalPhotoNoChecklist),
                ),
                ...checklistItems.map(
                  (item) => DropdownMenuItem<String?>(
                    value: item.id,
                    child: Text(
                      checklistTitle(l10n, item),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _checklistItemId = value),
            ),
            const SizedBox(height: 12),
            ExpansionTile(
              key: const ValueKey('technicalPhotoLinksSection'),
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              leading: const Icon(Icons.link_rounded),
              title: Text(l10n.technicalPhotoLinksTitle),
              children: TechnicalPhotoLinkType.values
                  .map((type) => _linkField(context, type))
                  .toList(growable: false),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              minLines: 3,
              maxLines: 7,
              maxLength: 2000,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.technicalPhotoDescriptionLabel,
              ),
            ),
            TextFormField(
              controller: _tags,
              maxLength: 395,
              decoration: InputDecoration(
                labelText: l10n.technicalPhotoTagsLabel,
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              key: const ValueKey('technicalPhotoSaveButton'),
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(l10n.technicalPhotoSaveAction),
            ),
          ],
        ),
      ),
    );
  }

  Widget _preview(BuildContext context) {
    final file = widget.data.previewFile ?? widget.data.originalFile;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: file == null
            ? ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.broken_image_outlined),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(
                          context,
                        ).technicalPhotosMissingPreview,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            : Image.file(
                file,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.broken_image_outlined)),
              ),
      ),
    );
  }

  DropdownMenuItem<String?> _contactItem(Contact contact) {
    return DropdownMenuItem<String?>(
      value: contact.id,
      child: Text(contact.displayName, overflow: TextOverflow.ellipsis),
    );
  }

  TechnicalAlbum? _selectedAlbum(String? albumId) {
    return widget.data.albums
        .where((overview) => overview.album.id == albumId)
        .firstOrNull
        ?.album;
  }

  bool _checklistBelongsToStage(String? checklistId, String? stageId) {
    if (checklistId == null) return true;
    return widget.data.checklistItems.any(
      (item) =>
          item.id == checklistId &&
          (stageId == null || item.stageId == stageId),
    );
  }

  Widget _linkField(BuildContext context, TechnicalPhotoLinkType type) {
    final l10n = AppLocalizations.of(context);
    final options = widget.data.linkOptions
        .where((option) => option.type == type)
        .toList(growable: false);
    final selected = _links.where((link) => link.type == type).firstOrNull;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String?>(
        key: ValueKey('technicalPhotoLink-${type.name}'),
        initialValue:
            options.any((option) => option.targetId == selected?.targetId)
            ? selected?.targetId
            : null,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: technicalPhotoLinkTypeLabel(l10n, type),
        ),
        items: [
          DropdownMenuItem<String?>(
            value: null,
            child: Text(l10n.technicalPhotoNoLink),
          ),
          ...options.map(
            (option) => DropdownMenuItem<String?>(
              value: option.targetId,
              child: Text(option.label, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
        onChanged: _saving
            ? null
            : (value) => setState(() {
                _links.removeWhere((link) => link.type == type);
                if (value != null) {
                  _links.add(TechnicalPhotoLink(type: type, targetId: value));
                }
              }),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _capturedAt,
      helpText: AppLocalizations.of(context).technicalPhotoDateLabel,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _capturedAt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _capturedAt.hour,
        _capturedAt.minute,
      );
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final input = TechnicalPhotoInput(
        projectId: widget.data.project.id,
        attachmentId: widget.data.attachment.id,
        albumId: _albumId!,
        title: _title.text,
        capturedAt: _capturedAt,
        installationType: _installationType,
        stageId: _stageId,
        zoneLabel: _zone.text,
        contractorContactId: _contactId,
        checklistItemId: _checklistItemId,
        description: _description.text,
        tags: _tags.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty),
        links: _links,
      );
      await (await ref.read(
        technicalPhotoEditorGatewayProvider.future,
      )).save(input, isNew: widget.isNew);
      ref.invalidate(technicalPhotoEditorDataProvider(widget.target));
      ref.invalidate(technicalPhotoProvider(widget.target));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.technicalPhotoSavedMessage)));
      Navigator.of(context).pop(true);
    } on Object {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.technicalPhotoSaveError)));
    }
  }
}

String _fileStem(String value) {
  final dot = value.lastIndexOf('.');
  return dot <= 0 ? value : value.substring(0, dot);
}
