import 'package:flutter/material.dart';
import 'package:personal_expense_tracker_app/core/constants/app_sizes.dart';
import 'package:personal_expense_tracker_app/core/theme/app_text_styles.dart';

class AppGap extends StatelessWidget {
  const AppGap.height(this.height, {super.key});

  /// Predefined small gap ([AppSizes.spaceXs]).
  const AppGap.sm({super.key}) : height = AppSizes.spaceXs;

  /// Predefined medium gap ([AppSizes.spaceSm]).
  const AppGap.md({super.key}) : height = AppSizes.spaceSm;

  /// Predefined large gap ([AppSizes.spaceMd]).
  const AppGap.lg({super.key}) : height = AppSizes.spaceMd;

  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}

/// Standard outlined field used on forms for consistent borders and padding.
class AppOutlinedTextField extends StatelessWidget {
  const AppOutlinedTextField({
    required this.controller,
    super.key,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSm)),
      ),
    );
  }
}

/// Empty placeholder with icon, title, and optional subtitle (e.g., no expenses).
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.icon,
    required this.title,
    super.key,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppSizes.iconEmptyState, color: colorScheme.outline),
          AppGap.md(),
          Text(title, style: AppTextStyles.emptyStateTitle(theme.textTheme)),
          if (subtitle != null) ...[
            AppGap.sm(),
            Text(subtitle!, style: AppTextStyles.emptyStateBody(theme.textTheme), textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

/// Short note that storage is local / offline-capable (offline-first UX hint).
// class OfflineFirstBanner extends StatelessWidget {
//   const OfflineFirstBanner({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     return Material(
//       color: scheme.surfaceContainerHighest,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceSm, vertical: AppSizes.spaceXs),
//         child: Row(
//           children: [
//             Icon(Icons.smartphone_outlined, size: 20, color: scheme.primary),
//             const SizedBox(width: AppSizes.spaceXs),
//             Expanded(
//               child: Text(
//                 'Saved on this device — works fully offline.',
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

/// Summary row with total for the visible (filtered) list.
class ExpenseSummaryCard extends StatelessWidget {
  const ExpenseSummaryCard({
    required this.total,
    required this.visibleCount,
    required this.animationKey,
    super.key,
    this.headerLabel = 'Total (filtered)',
    this.countSingular = 'item',
    this.countPlural = 'items',
    this.icon = Icons.calculate_outlined,
    this.iconColor,
  });

  final double total;
  final int visibleCount;
  final String animationKey;
  final String headerLabel;
  final String countSingular;
  final String countPlural;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ic = iconColor ?? scheme.primary;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: ScaleTransition(scale: Tween<double>(begin: 0.98, end: 1).animate(animation), child: child)),
      child: Card(
        key: ValueKey<String>(animationKey),
        margin: const EdgeInsets.fromLTRB(AppSizes.spaceSm, AppSizes.spaceXs, AppSizes.spaceSm, AppSizes.spaceXs),
        elevation: 0,
        color: scheme.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceSm),
          child: Row(
            children: [
              Icon(icon, color: ic),
              const SizedBox(width: AppSizes.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(headerLabel, style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
                    Text(
                      total.toStringAsFixed(2),
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$visibleCount ${visibleCount == 1 ? countSingular : countPlural}',
                      style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
