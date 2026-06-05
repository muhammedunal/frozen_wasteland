import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/constants.dart';
import '../widgets/game_sheet.dart';

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final soundEnabledProvider = StateProvider<bool>((ref) => true);
final musicEnabledProvider = StateProvider<bool>((ref) => false);
final difficultyProvider   = StateProvider<int>((ref) => 1); // 0=Easy 1=Normal 2=Hard

// ---------------------------------------------------------------------------
// Settings screen  (screen 07 — bottom sheet overlay over dimmed camp)
// ---------------------------------------------------------------------------

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sound = ref.watch(soundEnabledProvider);
    final music = ref.watch(musicEnabledProvider);
    final diff  = ref.watch(difficultyProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // frosted dim backdrop — tap to dismiss
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: const Color(0x80162130)),
          ),
          // sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GameSheet(
              height: 444,
              header: SheetHeader(
                iconGradient: const [Color(0xFF5DA0E8), AppColors.blueD],
                iconWidget:
                    const Icon(Icons.settings, color: Colors.white, size: 22),
                title: 'Settings',
                subtitle: '',
                onClose: () => Navigator.of(context).pop(),
              ),
              body: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SetRow(
                    iconGradient: const [Color(0xFF5DA0E8), AppColors.blueD],
                    icon: Icons.volume_up_outlined,
                    title: 'Sound effects',
                    subtitle: 'Hunts, builds & wildlife',
                    trailing: _Toggle(
                      value: sound,
                      onChanged: (v) =>
                          ref.read(soundEnabledProvider.notifier).state = v,
                    ),
                  ),
                  _SetRow(
                    iconGradient: const [Color(0xFF5DA0E8), AppColors.blueD],
                    icon: Icons.music_note_outlined,
                    title: 'Music',
                    subtitle: 'Ambient winter score',
                    trailing: _Toggle(
                      value: music,
                      onChanged: (v) =>
                          ref.read(musicEnabledProvider.notifier).state = v,
                    ),
                  ),
                  _SetRow(
                    iconGradient: const [Color(0xFFFFD27A), AppColors.goldD],
                    icon: Icons.star_outline,
                    title: 'Difficulty',
                    subtitle: '',
                    trailing: _Segmented(
                      labels: const ['Easy', 'Normal', 'Hard'],
                      selected: diff,
                      onSelect: (i) =>
                          ref.read(difficultyProvider.notifier).state = i,
                    ),
                  ),
                  _SetRow(
                    iconGradient: const [AppColors.snow2, AppColors.snow3],
                    icon: Icons.info_outline,
                    iconColor: AppColors.ink2,
                    title: 'About',
                    subtitle: 'Version 1.0.0 · credits',
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.ink3, size: 22),
                    onTap: () => _showAbout(context),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CtaButton(
                          gradient: const [Color(0xFFFFCF5E), AppColors.goldD],
                          shadowColor: const Color(0xFFB5851F),
                          icon: Icons.save_outlined,
                          label: 'Save',
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CtaButton(
                          gradient: const [Color(0xFF5DA0E8), AppColors.blueD],
                          shadowColor: const Color(0xFF205089),
                          icon: Icons.download_outlined,
                          label: 'Load',
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.snow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.wRadiusXl),
        ),
        title: Text('Frozen Wasteland',
            style: AppTextStyles.titleLg.copyWith(color: AppColors.ink)),
        content: Text(
          'Version 1.0.0\nHunt · Cook · Sell · Expand',
          style: AppTextStyles.bodyXs.copyWith(color: AppColors.ink2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close',
                style: TextStyle(color: AppColors.primary700)),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Settings row
// ============================================================

class _SetRow extends StatelessWidget {
  final List<Color> iconGradient;
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SetRow({
    required this.iconGradient,
    required this.icon,
    this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(color: AppColors.snow2, width: 1)),
        ),
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
                      color: Color(0x24000000),
                      offset: Offset(0, -2),
                      blurRadius: 0),
                ],
              ),
              child: Icon(icon, color: iconColor ?? Colors.white, size: 20),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.hudValue.copyWith(
                      fontFamily: 'Fredoka',
                      fontSize: 15.5,
                      color: AppColors.ink,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(subtitle,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.ink3)),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Animated toggle
// ============================================================

class _Toggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _Toggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 54,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: value
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF52C06E), AppColors.cashD],
                )
              : null,
          color: value ? null : AppColors.snow3,
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          alignment:
              value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppShadows.sh1,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Segmented control
// ============================================================

class _Segmented extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  const _Segmented({
    required this.labels,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.snow2,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: labels.asMap().entries.map((e) {
          final isOn = e.key == selected;
          return GestureDetector(
            onTap: () => onSelect(e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isOn ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                boxShadow: isOn ? AppShadows.sh1 : null,
              ),
              child: Text(
                e.value,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isOn ? AppColors.ink : AppColors.ink3,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
