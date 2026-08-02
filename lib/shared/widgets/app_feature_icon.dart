import 'package:flutter/material.dart';

class AppMenuIcon extends StatelessWidget {
  const AppMenuIcon(this.icon, {super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 24, color: colors.primary),
    );
  }
}

class AppQuickActionIcon extends StatelessWidget {
  const AppQuickActionIcon({
    required this.icon,
    required this.accentIcon,
    super.key,
  });

  final IconData icon;
  final IconData accentIcon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox.square(
      dimension: 32,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 1,
            child: Icon(icon, size: 26, color: colors.onSurfaceVariant),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: Icon(accentIcon, size: 14, color: colors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
