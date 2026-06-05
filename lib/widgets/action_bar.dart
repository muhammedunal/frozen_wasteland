import 'package:flutter/material.dart';

import '../config/constants.dart';

/// Callback types for each action.
typedef ActionCallback = void Function(ActionItem item);

enum ActionItem { hunt, chop, mine, cook, sell, upgrade }

extension ActionItemX on ActionItem {
  String get label {
    switch (this) {
      case ActionItem.hunt:    return 'Hunt';
      case ActionItem.chop:    return 'Chop';
      case ActionItem.mine:    return 'Mine';
      case ActionItem.cook:    return 'Cook';
      case ActionItem.sell:    return 'Sell';
      case ActionItem.upgrade: return 'Upgrade';
    }
  }

  (Color, Color) get gradient {
    switch (this) {
      case ActionItem.hunt:
        return (const Color(0xFFF2796F), const Color(0xFFD6453F));
      case ActionItem.chop:
        return (AppColors.woodL, AppColors.woodD);
      case ActionItem.mine:
        return (const Color(0xFFA9B6C4), const Color(0xFF76869A));
      case ActionItem.cook:
        return (AppColors.fire2, const Color(0xFFF0682A));
      case ActionItem.sell:
        return (AppColors.cashL, AppColors.cashD);
      case ActionItem.upgrade:
        return (const Color(0xFFFFD27A), AppColors.goldD);
    }
  }

  IconData get icon {
    switch (this) {
      case ActionItem.hunt:    return Icons.sports_martial_arts;
      case ActionItem.chop:    return Icons.hardware;
      case ActionItem.mine:    return Icons.construction;
      case ActionItem.cook:    return Icons.local_fire_department;
      case ActionItem.sell:    return Icons.sell;
      case ActionItem.upgrade: return Icons.arrow_upward;
    }
  }

  Color get iconColor {
    return this == ActionItem.upgrade ? const Color(0xFF7A4A00) : Colors.white;
  }
}

/// Horizontally scrollable action disc bar at the bottom of the game screen.
/// Mirrors the `.actionbar` + `.ab-item` / `.ab-disc` structure from wasteland.css.
class ActionBar extends StatelessWidget {
  final ActionItem? primaryItem;
  final Map<ActionItem, int?> badges; // null = no badge
  final ActionCallback onTap;

  const ActionBar({
    super.key,
    this.primaryItem = ActionItem.hunt,
    this.badges = const {},
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.36, 1.0],
          colors: [
            Color(0x00F5F8FA),
            Color(0xDBEEF3F8),
            Color(0xFFEAF1F8),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 18),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          children: ActionItem.values.map((item) {
            final isPrimary = item == primaryItem;
            final badge = badges[item];
            return _ActionDisc(
              item: item,
              isPrimary: isPrimary,
              badge: badge,
              onTap: () => onTap(item),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ActionDisc extends StatelessWidget {
  final ActionItem item;
  final bool isPrimary;
  final int? badge;
  final VoidCallback onTap;

  const _ActionDisc({
    required this.item,
    required this.isPrimary,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final discSize = isPrimary ? 66.0 : 58.0;
    final itemWidth = isPrimary ? 70.0 : 62.0;
    final (c1, c2) = item.gradient;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: itemWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // disc
                Container(
                  width: discSize,
                  height: discSize,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [c1, c2],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: c2.withOpacity(0.4),
                        offset: const Offset(0, 6),
                        blurRadius: 0,
                        spreadRadius: 0,
                      ),
                      ...AppShadows.sh2,
                    ],
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 28),
                ),
                // badge
                if (badge != null)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: badge == 0
                            ? AppColors.good
                            : AppColors.danger,
                        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          badge == 0 ? '!' : '$badge',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              style: AppTextStyles.hudValueSm.copyWith(
                fontSize: 11.5,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
