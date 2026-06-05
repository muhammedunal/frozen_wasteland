import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../widgets/game_sheet.dart';

/// Gate / expedition portal selection sheet.
/// Mirrors screen 02 from the Frozen Wasteland UI v2 mockup.
class GateScreen extends StatefulWidget {
  const GateScreen({super.key});

  @override
  State<GateScreen> createState() => _GateScreenState();
}

class _GateScreenState extends State<GateScreen> {
  int _selected = 0;

  static const _destinations = [
    _Destination(
      name: 'Hunting Grounds',
      yields: 'Meat',
      time: '2:30',
      gradientColors: [Color(0xFF6FA8C7), Color(0xFF3E6F8C)],
      locked: false,
    ),
    _Destination(
      name: 'Pine Forest',
      yields: 'Wood',
      time: '1:45',
      gradientColors: [Color(0xFF8FB57A), Color(0xFF5C7F47)],
      locked: false,
    ),
    _Destination(
      name: 'Iron Mine',
      yields: 'Iron',
      time: null,
      unlockLabel: 'unlocks Lv 9',
      gradientColors: [Color(0xFF9CA9B7), Color(0xFF5E6B7A)],
      locked: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GameSheet(
      height: 336,
      header: SheetHeader(
        iconGradient: const [Color(0xFFB0855A), AppColors.woodD],
        iconWidget: const Icon(Icons.door_front_door_outlined,
            color: Colors.white, size: 22),
        title: 'Choose a Gate',
        subtitle: 'Send the hunter out to gather',
        onClose: () => Navigator.of(context).pop(),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ..._destinations.asMap().entries.map((entry) {
            return _DestCard(
              dest: entry.value,
              active: entry.key == _selected,
              onTap: entry.value.locked
                  ? null
                  : () => setState(() => _selected = entry.key),
            );
          }),
          const SizedBox(height: 12),
          CtaButton(
            gradient: const [Color(0xFF52C06E), AppColors.cashD],
            shadowColor: const Color(0xFF2C7A43),
            icon: Icons.arrow_forward,
            label: 'Go to ${_destinations[_selected].name}',
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Destination data + card
// ============================================================

class _Destination {
  final String name;
  final String? yields;
  final String? time;
  final String? unlockLabel;
  final List<Color> gradientColors;
  final bool locked;

  const _Destination({
    required this.name,
    this.yields,
    this.time,
    this.unlockLabel,
    required this.gradientColors,
    required this.locked,
  });
}

class _DestCard extends StatelessWidget {
  final _Destination dest;
  final bool active;
  final VoidCallback? onTap;

  const _DestCard({
    super.key,
    required this.dest,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: dest.locked ? 0.85 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.wRadiusLg),
            border: Border.all(
              color: active ? AppColors.blue : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              if (active)
                BoxShadow(
                  color: AppColors.blue.withOpacity(0.18),
                  blurRadius: 0,
                  spreadRadius: 3,
                ),
              ...AppShadows.sh1,
            ],
          ),
          child: Row(
            children: [
              // thumbnail
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: dest.gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x24000000),
                      offset: Offset(0, -3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  dest.locked ? Icons.lock_outline : Icons.forest,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 13),
              // meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dest.name,
                      style: AppTextStyles.hudValue
                          .copyWith(fontSize: 15.5, color: AppColors.ink),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (dest.yields != null) ...[
                          Icon(_yieldIcon(dest.yields!),
                              size: 13, color: AppColors.ink3),
                          const SizedBox(width: 3),
                          Text(
                            dest.yields!,
                            style: AppTextStyles.micro.copyWith(
                                fontSize: 11.5, color: AppColors.ink3),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (dest.time != null) ...[
                          const Icon(Icons.access_time,
                              size: 13, color: AppColors.ink3),
                          const SizedBox(width: 3),
                          Text(
                            dest.time!,
                            style: AppTextStyles.micro.copyWith(
                                fontSize: 11.5, color: AppColors.ink3),
                          ),
                        ],
                        if (dest.unlockLabel != null)
                          Text(
                            dest.unlockLabel!,
                            style: AppTextStyles.micro.copyWith(
                                fontSize: 11.5, color: AppColors.ink3),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // go / lock button
              if (!dest.locked)
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF52C06E), AppColors.cashD],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0xFF2C7A43),
                          offset: Offset(0, 4),
                          blurRadius: 0),
                    ],
                  ),
                  child: const Icon(Icons.chevron_right,
                      color: Colors.white, size: 22),
                )
              else
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0CC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.lock_outline,
                      color: Color(0xFF9C6F12), size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _yieldIcon(String yields) {
    switch (yields.toLowerCase()) {
      case 'meat': return Icons.lunch_dining;
      case 'wood': return Icons.forest;
      case 'iron': return Icons.hardware;
      default:     return Icons.inventory_2_outlined;
    }
  }
}
