import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/assets.dart';
import '../config/constants.dart';
import '../game/frozen_wasteland_game.dart';
import '../models/building.dart';
import '../providers/building_provider.dart';
import '../providers/game_state_provider.dart';
import '../widgets/action_bar.dart';
import '../widgets/resource_hud.dart';
import 'cook_screen.dart';
import 'gate_screen.dart';
import 'sales_screen.dart';
import 'settings_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late final FrozenWastelandGame _game;

  @override
  void initState() {
    super.initState();
    _game = FrozenWastelandGame(
      onStateChanged: (resources) =>
          ref.read(gameStateProvider.notifier).syncResources(resources),
      onPlacementFeedback: _showPlacementFeedback,
    );
  }

  void _showPlacementFeedback(String message, bool success) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 1200),
          backgroundColor: success ? AppColors.good : AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          ),
        ),
      );
  }

  void _syncSelectionToGame() {
    final placing = ref.read(placementModeProvider);
    final selected = ref.read(selectedBuildingProvider);
    _game.selectBuilding(placing ? selected : null);
  }

  void _onAction(ActionItem item) {
    switch (item) {
      case ActionItem.hunt:
        _showGateSheet();
      case ActionItem.chop:
        _showGateSheet();
      case ActionItem.mine:
        _showGateSheet();
      case ActionItem.cook:
        _showCookSheet();
      case ActionItem.sell:
        _showSalesSheet();
      case ActionItem.upgrade:
        _openBuildingSelector();
    }
  }

  void _showCookSheet() => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const CookScreen(),
      );

  void _showSalesSheet() => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const SalesScreen(),
      );

  void _showGateSheet() => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const GateScreen(),
      );

  void _openBuildingSelector() => showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => const _BuildingSelector(),
      );

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(pausedProvider, (_, paused) {
      if (paused) {
        _game.pauseEngine();
      } else {
        _game.resumeEngine();
      }
    });

    ref.listen<bool>(placementModeProvider, (_, __) => _syncSelectionToGame());
    ref.listen<BuildingType?>(
        selectedBuildingProvider, (_, __) => _syncSelectionToGame());

    final paused = ref.watch(pausedProvider);

    return Scaffold(
      backgroundColor: AppColors.sky1,
      body: Stack(
        children: [
          // ── Flame game world ──────────────────────────────────────
          Positioned.fill(child: GameWidget(game: _game)),

          // ── Status bar area (safe area padding) ───────────────────
          const _StatusBar(),

          // ── Top HUD ───────────────────────────────────────────────
          Positioned(
            top: 46,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: night timer + level pill
                Row(
                  children: [
                    _TimerPill(label: 'Night 04'),
                    const SizedBox(width: 8),
                    _LevelPill(level: 7, name: 'Frosthold'),
                  ],
                ),
                const SizedBox(height: 8),
                // Row 2: 5-resource compact bar
                const ResourceHud(),
              ],
            ),
          ),

          // ── Corner buttons (settings + minimap) ───────────────────
          Positioned(
            top: 46,
            right: 12,
            child: Column(
              children: [
                _CornerBtn(
                  icon: Icons.settings,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
                const SizedBox(height: 8),
                const _Minimap(),
              ],
            ),
          ),

          // ── Wall integrity badge ───────────────────────────────────
          const Positioned(
            top: 108,
            left: 0,
            right: 0,
            child: Center(child: _WallIntegrityBadge(percent: 0.64)),
          ),

          // ── Toast area ────────────────────────────────────────────
          const Positioned(
            top: 128,
            left: 0,
            right: 0,
            child: _ToastArea(),
          ),

          // ── Player HP (bottom-left of game area) ──────────────────
          const Positioned(
            left: 14,
            bottom: 130,
            child: _PlayerHp(level: 7, hpPercent: 0.78),
          ),

          // ── Paused dimmer ─────────────────────────────────────────
          if (paused)
            Positioned.fill(
              child: Container(
                color: const Color(0x80162130),
                alignment: Alignment.center,
                child: Text(
                  'PAUSED',
                  style: AppTextStyles.displayMd.copyWith(
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ),

          // ── Bottom action bar ─────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ActionBar(
              primaryItem: ActionItem.hunt,
              badges: const {
                ActionItem.hunt: 0, // 0 = "!" badge
                ActionItem.cook: 4,
              },
              onTap: _onAction,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Status Bar
// ============================================================

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 42,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '22:03',
              style: AppTextStyles.hudValue.copyWith(color: AppColors.ink),
            ),
            Row(
              children: [
                Icon(Icons.signal_cellular_alt, size: 16, color: AppColors.ink),
                const SizedBox(width: 6),
                Icon(Icons.battery_full, size: 16, color: AppColors.ink),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Timer Pill
// ============================================================

class _TimerPill extends StatelessWidget {
  final String label;
  const _TimerPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 5, 12, 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF4685E), Color(0xFFE5443B)],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFB5302A),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
          ...AppShadows.sh1,
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.nightlight_round, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.hudValue.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Level Pill
// ============================================================

class _LevelPill extends StatelessWidget {
  final int level;
  final String name;
  const _LevelPill({required this.level, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        boxShadow: AppShadows.sh1,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // level badge
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFD27A), AppColors.goldD],
              ),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x24000000),
                  offset: Offset(0, -2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$level',
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 7),
          Text(
            name,
            style: AppTextStyles.hudValue.copyWith(color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Corner button
// ============================================================

class _CornerBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CornerBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.86),
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadows.sh1,
        ),
        child: Icon(icon, color: AppColors.ink2, size: 21),
      ),
    );
  }
}

// ============================================================
// Minimap
// ============================================================

class _Minimap extends StatelessWidget {
  const _Minimap();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFBFD6EA), Color(0xFF9CBBD6)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.6),
          width: 2,
        ),
        boxShadow: AppShadows.sh1,
      ),
      child: Stack(
        children: [
          // isometric floor diamond
          Center(
            child: Transform.rotate(
              angle: 0.785, // 45 deg
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.dirt,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.dirtD, width: 2),
                ),
              ),
            ),
          ),
          // dots
          Positioned(
            left: 30,
            top: 34,
            child: _MinimapDot(color: AppColors.blue),
          ),
          Positioned(
            left: 40,
            top: 24,
            child: _MinimapDot(color: AppColors.danger),
          ),
          Positioned(
            left: 22,
            top: 28,
            child: _MinimapDot(color: AppColors.fire2),
          ),
        ],
      ),
    );
  }
}

class _MinimapDot extends StatelessWidget {
  final Color color;
  const _MinimapDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}

// ============================================================
// Wall integrity badge
// ============================================================

class _WallIntegrityBadge extends StatelessWidget {
  final double percent; // 0.0–1.0
  const _WallIntegrityBadge({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3C4A5A), Color(0xFF27323F)],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        boxShadow: AppShadows.sh2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shield_outlined, color: Colors.white, size: 14),
          const SizedBox(width: 7),
          Text(
            'Wall',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(width: 7),
          // progress track
          Container(
            width: 54,
            height: 7,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
            clipBehavior: Clip.hardEdge,
            child: FractionallySizedBox(
              widthFactor: percent,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.flame, AppColors.danger],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Toast area
// ============================================================

class _ToastArea extends StatelessWidget {
  const _ToastArea();

  @override
  Widget build(BuildContext context) {
    // Demo: single danger toast. In production feed from a Riverpod stream.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _Toast(
            type: _ToastType.danger,
            message: 'A wild bear is attacking!',
          ),
        ],
      ),
    );
  }
}

enum _ToastType { good, warn, danger, info }

class _Toast extends StatelessWidget {
  final _ToastType type;
  final String message;
  const _Toast({required this.type, required this.message});

  @override
  Widget build(BuildContext context) {
    final (c1, c2) = _colors(type);
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 16, 9),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c1, c2],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        boxShadow: AppShadows.sh2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon(type), color: Colors.white, size: 15),
          ),
          const SizedBox(width: 9),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _colors(_ToastType t) {
    switch (t) {
      case _ToastType.good:
        return (const Color(0xFF52C06E), AppColors.cashD);
      case _ToastType.warn:
        return (AppColors.flame, const Color(0xFFF0892E));
      case _ToastType.danger:
        return (const Color(0xFFF4685E), AppColors.danger);
      case _ToastType.info:
        return (const Color(0xFF5DA0E8), AppColors.blueD);
    }
  }

  IconData _icon(_ToastType t) {
    switch (t) {
      case _ToastType.good:    return Icons.check;
      case _ToastType.warn:    return Icons.warning_amber_rounded;
      case _ToastType.danger:  return Icons.warning_rounded;
      case _ToastType.info:    return Icons.info_outline;
    }
  }
}

// ============================================================
// Player HP
// ============================================================

class _PlayerHp extends StatelessWidget {
  final int level;
  final double hpPercent;
  const _PlayerHp({required this.level, required this.hpPercent});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // avatar
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF5DA0E8), AppColors.blueD],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: AppShadows.sh1,
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'HUNTER · LV $level',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                fontSize: 9,
                letterSpacing: 0.4,
                color: AppColors.ink,
                shadows: [
                  Shadow(
                    color: Colors.white.withOpacity(0.6),
                    offset: const Offset(0, 1),
                    blurRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            Container(
              width: 96,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                boxShadow: AppShadows.sh1,
              ),
              clipBehavior: Clip.hardEdge,
              child: FractionallySizedBox(
                widthFactor: hpPercent,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6FCB87), AppColors.good],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================
// Building selector (unchanged logic, restyled)
// ============================================================

class _BuildingSelector extends ConsumerWidget {
  const _BuildingSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedBuildingProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // grip
          Container(
            width: 42,
            height: 5,
            margin: const EdgeInsets.only(top: 10, bottom: 14),
            decoration: BoxDecoration(
              color: AppColors.snow3,
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
          ),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFB0855A), AppColors.woodD],
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.add_home_work, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Build', style: AppTextStyles.titleLg.copyWith(color: AppColors.ink)),
                    Text(
                      'Tap to place a building',
                      style: AppTextStyles.caption.copyWith(color: AppColors.ink3),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
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
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: BuildingType.values.length,
            itemBuilder: (ctx, i) {
              final type = BuildingType.values[i];
              final isSel = type == selected;
              return GestureDetector(
                onTap: () {
                  ref.read(selectedBuildingProvider.notifier).state = type;
                  ref.read(placementModeProvider.notifier).state = true;
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.primary100 : AppColors.snow2,
                    borderRadius: BorderRadius.circular(AppSizes.wRadiusMd),
                    border: Border.all(
                      color: isSel ? AppColors.primary500 : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: WinterPalette.forBuilding(type),
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        type.displayName,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
