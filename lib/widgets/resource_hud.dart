import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/constants.dart';
import '../models/resource.dart';
import '../providers/game_state_provider.dart';

/// Compact 5-resource bar shown at the top of every game screen.
/// Mirrors the `.resbar.compact` component from wasteland.css.
class ResourceHud extends ConsumerWidget {
  const ResourceHud({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ref.watch(gameStateProvider).resources;

    // Map existing resource model → mockup display order
    // food=Meat, wood=Wood, stone=Iron, coin=Gold, happiness=Cash(%)
    final items = [
      _ResItem(
        color1: const Color(0xFFF2796F),
        color2: const Color(0xFFD6453F),
        icon: _meatPath,
        value: '${r.food}',
      ),
      _ResItem(
        color1: AppColors.woodL,
        color2: AppColors.woodD,
        icon: _woodPath,
        value: '${r.wood}',
      ),
      _ResItem(
        color1: const Color(0xFFA9B6C4),
        color2: const Color(0xFF76869A),
        icon: _ironPath,
        value: '${r.stone}',
      ),
      _ResItem(
        color1: AppColors.goldL,
        color2: AppColors.goldD,
        icon: _goldPath,
        value: '${r.coin}',
      ),
      _ResItem(
        color1: AppColors.cashL,
        color2: AppColors.cashD,
        icon: _cashPath,
        value: '${r.happiness}',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        boxShadow: AppShadows.sh1,
      ),
      padding: const EdgeInsets.all(AppSizes.sp1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items
            .map((item) => _ResCell(item: item))
            .toList(),
      ),
    );
  }
}

class _ResItem {
  final Color color1;
  final Color color2;
  final String icon;
  final String value;
  const _ResItem({
    required this.color1,
    required this.color2,
    required this.icon,
    required this.value,
  });
}

class _ResCell extends StatelessWidget {
  final _ResItem item;
  const _ResCell({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // circular icon badge
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [item.color1, item.color2],
              ),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F000000),
                  offset: Offset(0, -2),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: CustomPaint(
                size: const Size(14, 14),
                painter: _SvgPainter(item.icon),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            item.value,
            style: AppTextStyles.hudValueSm.copyWith(color: AppColors.ink),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// Minimal path-based icon painter for the resource icons.
// For production replace with flutter_svg assets.
class _SvgPainter extends CustomPainter {
  final String pathData;
  const _SvgPainter(this.pathData);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    // Draw a simple circle placeholder; real icons come from SVG assets.
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.36,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Icon path constants (currently unused; replace _SvgPainter with svg asset).
const _meatPath = 'meat';
const _woodPath  = 'wood';
const _ironPath  = 'iron';
const _goldPath  = 'gold';
const _cashPath  = 'cash';


// ---------------------------------------------------------------------------
// Reusable resource icon widget (used in cook/sales/gate screens)
// ---------------------------------------------------------------------------

/// A round resource badge matching `.ric` from wasteland.css.
class ResourceIcon extends StatelessWidget {
  final ResourceKind kind;
  final double size;
  const ResourceIcon({super.key, required this.kind, this.size = 28});

  @override
  Widget build(BuildContext context) {
    final (c1, c2) = _colors(kind);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c1, c2],
        ),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            offset: Offset(0, -2),
            blurRadius: 0,
          ),
          BoxShadow(
            color: Color(0x59FFFFFF),
            offset: Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: const Icon(Icons.circle, size: 0), // replace with svg asset
    );
  }

  (Color, Color) _colors(ResourceKind k) {
    switch (k) {
      case ResourceKind.meat:
        return (const Color(0xFFF2796F), const Color(0xFFD6453F));
      case ResourceKind.wood:
        return (AppColors.woodL, AppColors.woodD);
      case ResourceKind.iron:
        return (const Color(0xFFA9B6C4), const Color(0xFF76869A));
      case ResourceKind.gold:
        return (AppColors.goldL, AppColors.goldD);
      case ResourceKind.cash:
        return (AppColors.cashL, AppColors.cashD);
    }
  }
}

enum ResourceKind { meat, wood, iron, gold, cash }
