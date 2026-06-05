import 'package:flutter/material.dart';

import '../config/constants.dart';

// ============================================================
// Shared bottom-sheet scaffold used by Cook, Sales, Gate,
// Settings screens.
// Mirrors the .sheet component from wasteland.css.
// ============================================================

class GameSheet extends StatelessWidget {
  final double height;
  final SheetHeader header;
  final Widget body;

  const GameSheet({
    super.key,
    required this.height,
    required this.header,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Color(0x38142030),
            offset: Offset(0, -10),
            blurRadius: 30,
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 5,
            margin: const EdgeInsets.only(top: 10, bottom: 2),
            decoration: BoxDecoration(
              color: AppColors.snow3,
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
          ),
          header,
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
              child: body,
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Sheet badge chip --------------------------------------------------

class SheetBadge {
  final String label;
  final Color color;
  final Color textColor;
  const SheetBadge({
    required this.label,
    required this.color,
    required this.textColor,
  });
}

// ---- Sheet header row --------------------------------------------------

class SheetHeader extends StatelessWidget {
  final List<Color> iconGradient;
  final Widget iconWidget;
  final String title;
  final String subtitle;
  final SheetBadge? badge;
  final VoidCallback onClose;

  const SheetHeader({
    super.key,
    required this.iconGradient,
    required this.iconWidget,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: iconGradient,
              ),
              borderRadius: BorderRadius.circular(13),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x29000000),
                  offset: Offset(0, -2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: iconWidget,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppColors.ink3,
                    ),
                  ),
              ],
            ),
          ),
          if (badge != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: badge!.color,
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              ),
              child: Text(
                badge!.label,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  color: badge!.textColor,
                ),
              ),
            ),
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.snow2,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(Icons.close, color: AppColors.ink2, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Full-width CTA button (3D game style) -----------------------------

class CtaButton extends StatelessWidget {
  final List<Color> gradient;
  final Color shadowColor;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const CtaButton({
    super.key,
    required this.gradient,
    required this.shadowColor,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: disabled ? 0.5 : 1.0,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(AppSizes.wRadiusLg),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                offset: const Offset(0, 6),
                blurRadius: 0,
              ),
              ...AppShadows.sh1,
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 9),
              Text(label, style: AppTextStyles.btnLg),
            ],
          ),
        ),
      ),
    );
  }
}
