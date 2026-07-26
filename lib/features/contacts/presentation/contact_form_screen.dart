import 'package:budowapro/features/contacts/data/contact_providers.dart';
import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/contacts/presentation/contact_details_provider.dart';
import 'package:budowapro/features/contacts/presentation/contact_ui_text.dart';
import 'package:budowapro/features/contacts/presentation/contacts_controller.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactFormScreen extends ConsumerStatefulWidget {
  const ContactFormScreen({required this.projectId, this.contactId, super.key});

  final String projectId;
  final String? contactId;

  @override
  ConsumerState<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends ConsumerState<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _noteController = TextEditingController();
  ContactKind _kind = ContactKind.person;
  Set<ContactRole> _roles = <ContactRole>{};
  Set<String> _stageIds = <String>{};
  int? _rating;
  bool _saving = false;
  bool _importingContact = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _taxIdController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final project = _project(
      ref.watch(projectsControllerProvider).value?.projects,
    );
    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.contactNewTitle)),
        body: AppEmptyState(
          icon: Icons.folder_off_outlined,
          title: l10n.contactsNoProjectTitle,
          message: l10n.contactsNoProjectMessage,
        ),
      );
    }
    final stages = ref.watch(projectStagesProvider(project));
    final contactId = widget.contactId;
    if (contactId == null) {
      _initialized = true;
      return _scaffold(l10n, stages.value ?? const <ProjectStage>[]);
    }
    final contact = ref.watch(
      contactByIdProvider((projectId: widget.projectId, contactId: contactId)),
    );
    return contact.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.contactEditTitle)),
        body: AppLoadingState(label: l10n.projectsLoading),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: Text(l10n.contactEditTitle)),
        body: AppErrorState(
          title: l10n.contactLoadError,
          retryLabel: l10n.retryAction,
          onRetry: () => ref.invalidate(
            contactByIdProvider((
              projectId: widget.projectId,
              contactId: contactId,
            )),
          ),
        ),
      ),
      data: (contact) {
        if (contact == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.contactEditTitle)),
            body: AppEmptyState(
              icon: Icons.person_off_outlined,
              title: l10n.contactNotFoundTitle,
              message: l10n.contactNotFoundMessage,
            ),
          );
        }
        _initialize(contact);
        return _scaffold(l10n, stages.value ?? const <ProjectStage>[]);
      },
    );
  }

  Scaffold _scaffold(AppLocalizations l10n, List<ProjectStage> stages) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.contactId == null
              ? l10n.contactNewTitle
              : l10n.contactEditTitle,
        ),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            children: [
              if (widget.contactId == null) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    key: const ValueKey('contactImportButton'),
                    onPressed: _saving || _importingContact
                        ? null
                        : _importFromPhone,
                    icon: _importingContact
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.contact_phone_outlined),
                    label: Text(l10n.contactImportFromPhoneAction),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                key: const ValueKey('contactNameField'),
                controller: _nameController,
                maxLength: ContactFieldLimits.displayName,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.contactNameLabel,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.contactNameRequiredError
                    : null,
              ),
              const SizedBox(height: 8),
              SegmentedButton<ContactKind>(
                segments: ContactKind.values
                    .map(
                      (kind) => ButtonSegment(
                        value: kind,
                        icon: Icon(
                          kind == ContactKind.person
                              ? Icons.person_outline_rounded
                              : Icons.business_outlined,
                        ),
                        label: Text(contactKindLabel(l10n, kind)),
                      ),
                    )
                    .toList(growable: false),
                selected: <ContactKind>{_kind},
                onSelectionChanged: _saving
                    ? null
                    : (value) => setState(() => _kind = value.single),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.contactRolesHeading,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: ContactRole.values
                    .map(
                      (role) => FilterChip(
                        avatar: Icon(contactRoleIcon(role), size: 18),
                        label: Text(contactRoleLabel(l10n, role)),
                        selected: _roles.contains(role),
                        onSelected: _saving
                            ? null
                            : (selected) => setState(() {
                                if (selected) {
                                  _roles.add(role);
                                } else {
                                  _roles.remove(role);
                                }
                              }),
                      ),
                    )
                    .toList(growable: false),
              ),
              if (_roles.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    l10n.contactRoleRequiredError,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                l10n.contactStagesHeading,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (stages.isEmpty)
                Text(l10n.contactNoStagesAvailable)
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: stages
                      .map(
                        (stage) => FilterChip(
                          label: Text(stageName(l10n, stage)),
                          selected: _stageIds.contains(stage.id),
                          onSelected: _saving
                              ? null
                              : (selected) => setState(() {
                                  if (selected) {
                                    _stageIds.add(stage.id);
                                  } else {
                                    _stageIds.remove(stage.id);
                                  }
                                }),
                        ),
                      )
                      .toList(growable: false),
                ),
              const Divider(height: 32),
              TextFormField(
                key: const ValueKey('contactPhoneField'),
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: ContactFieldLimits.phone,
                decoration: InputDecoration(
                  labelText: l10n.contactPhoneLabel,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                maxLength: 254,
                decoration: InputDecoration(
                  labelText: l10n.contactEmailLabel,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  final normalized = value?.trim() ?? '';
                  if (normalized.isEmpty) return null;
                  return RegExp(
                        r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                      ).hasMatch(normalized)
                      ? null
                      : l10n.contactEmailInvalidError;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _taxIdController,
                maxLength: 24,
                decoration: InputDecoration(
                  labelText: l10n.contactTaxIdLabel,
                  prefixIcon: const Icon(Icons.receipt_long_outlined),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int?>(
                initialValue: _rating,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.contactRatingLabel,
                  prefixIcon: const Icon(Icons.star_outline_rounded),
                ),
                items: <DropdownMenuItem<int?>>[
                  DropdownMenuItem(
                    value: null,
                    child: Text(l10n.contactNoRating),
                  ),
                  ...List<int>.generate(5, (index) => index + 1).map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text('${'★' * value}${'☆' * (5 - value)}'),
                    ),
                  ),
                ],
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _rating = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                maxLength: 2000,
                minLines: 3,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: l10n.contactNoteLabel,
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(Icons.notes_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton.icon(
            key: const ValueKey('contactSaveButton'),
            onPressed: _saving || _importingContact ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(l10n.saveAction),
          ),
        ),
      ),
    );
  }

  Project? _project(List<Project>? projects) {
    if (projects == null) return null;
    for (final project in projects) {
      if (project.id == widget.projectId) return project;
    }
    return null;
  }

  void _initialize(Contact contact) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = contact.displayName;
    _phoneController.text = contact.phone ?? '';
    _emailController.text = contact.email ?? '';
    _taxIdController.text = contact.taxId ?? '';
    _noteController.text = contact.note ?? '';
    _kind = contact.kind;
    _roles = contact.roles.toSet();
    _stageIds = contact.stageIds.toSet();
    _rating = contact.rating;
  }

  Future<void> _importFromPhone() async {
    FocusScope.of(context).unfocus();
    setState(() => _importingContact = true);
    try {
      final selection = await ref.read(deviceContactPickerProvider).pick();
      if (!mounted || selection == null) return;
      _nameController.text = selection.displayName;
      _phoneController.text = selection.phone;
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).contactImportFromPhoneError,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _importingContact = false);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_roles.isEmpty) {
      setState(() {});
      return;
    }
    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(contactsControllerProvider.notifier)
          .saveContact(
            ContactDraft(
              displayName: _nameController.text,
              kind: _kind,
              roles: _roles,
              stageIds: _stageIds,
              phone: _phoneController.text,
              email: _emailController.text,
              taxId: _taxIdController.text,
              note: _noteController.text,
              rating: _rating,
            ),
            contactId: widget.contactId,
          );
      if (mounted) Navigator.pop(context, true);
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.contactSaveError)));
      setState(() => _saving = false);
    }
  }
}
