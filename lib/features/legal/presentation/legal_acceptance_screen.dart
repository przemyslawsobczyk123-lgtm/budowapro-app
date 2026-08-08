import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class LegalAcceptanceScreen extends StatefulWidget {
  const LegalAcceptanceScreen({
    required this.onAccept,
    required this.onOpenTerms,
    required this.onOpenPrivacy,
    super.key,
  });

  final Future<void> Function() onAccept;
  final Future<bool> Function() onOpenTerms;
  final Future<bool> Function() onOpenPrivacy;

  @override
  State<LegalAcceptanceScreen> createState() => _LegalAcceptanceScreenState();
}

class _LegalAcceptanceScreenState extends State<LegalAcceptanceScreen> {
  var _confirmed = false;
  var _saving = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.gavel_rounded, size: 40),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.legalAcceptanceTitle,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.legalAcceptanceIntro,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  _LegalLinkButton(
                    icon: Icons.description_outlined,
                    label: l10n.legalAcceptanceOpenTerms,
                    onPressed: () => _open(widget.onOpenTerms),
                  ),
                  const SizedBox(height: 8),
                  _LegalLinkButton(
                    icon: Icons.privacy_tip_outlined,
                    label: l10n.legalAcceptanceOpenPrivacy,
                    onPressed: () => _open(widget.onOpenPrivacy),
                  ),
                  const SizedBox(height: 20),
                  Material(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    child: CheckboxListTile(
                      value: _confirmed,
                      onChanged: _saving
                          ? null
                          : (value) {
                              setState(() => _confirmed = value ?? false);
                            },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      title: Text(l10n.legalAcceptanceCheckbox),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.legalAcceptanceLocalNotice,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _confirmed && !_saving ? _accept : null,
                    icon: _saving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(
                      _saving
                          ? l10n.legalAcceptanceSaving
                          : l10n.legalAcceptanceContinue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _open(Future<bool> Function() action) async {
    var opened = false;
    try {
      opened = await action();
    } on Object {
      opened = false;
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).legalOpenLinkError),
        ),
      );
    }
  }

  Future<void> _accept() async {
    setState(() => _saving = true);
    try {
      await widget.onAccept();
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).legalAcceptanceSaveError,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _LegalLinkButton extends StatelessWidget {
  const _LegalLinkButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
