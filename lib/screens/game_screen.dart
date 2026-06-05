import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/assets.dart';
import '../config/constants.dart';
import '../game/frozen_wasteland_game.dart';
import '../models/building.dart';
import '../models/resource.dart';
import '../providers/building_provider.dart';
import '../providers/game_state_provider.dart';
import 'settings_screen.dart';

/// Hosts the Flame [GameWidget] and the Flutter UI overlay
/// (ResourceHUD + BottomMenu + BuildingSelector), all driven by Riverpod.
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
          backgroundColor: success ? WinterPalette.pineGreen : Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  /// Pushes the current selection + placement mode into the Flame game.
  void _syncSelectionToGame() {
    final placing = ref.read(placementModeProvider);
    final selected = ref.read(selectedBuildingProvider);
    _game.selectBuilding(placing ? selected : null);
  }

  @override
  Widget build(BuildContext context) {
    // Pause / resume the Flame engine when the paused flag changes.
    ref.listen<bool>(pausedProvider, (_, paused) {
      if (paused) {
        _game.pauseEngine();
      } else {
        _game.resumeEngine();
      }
    });

    // Keep the game's active building in sync with UI state.
    ref.listen<bool>(placementModeProvider, (_, __) => _syncSelectionToGame());
    ref.listen<BuildingType?>(
        selectedBuildingProvider, (_, __) => _syncSelectionToGame());

    final paused = ref.watch(pausedProvider);

    return Scaffold(
      backgroundColor: GameConstants.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: GameWidget(game: _game)),

            // Top-left resource HUD.
            const Positioned(top: 8, left: 8, child: ResourceHUD()),

            // Top-right controls (pause / settings / home).
            Positioned(
              top: 8,
              right: 8,
              child: _TopControls(
                paused: paused,
                onPause: () => ref
                    .read(pausedProvider.notifier)
                    .update((p) => !p),
                onSettings: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
                onHome: () {
                  ref.read(gameStateProvider.notifier).toMenu();
                  Navigator.of(context).pop();
                },
              ),
            ),

            // Paused dimmer.
            if (paused)
              Positioned.fill(
                child: Container(
                  color: Colors.black38,
                  alignment: Alignment.center,
                  child: const Text(
                    'PAUSED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),

            // Bottom menu bar.
            const Align(
              alignment: Alignment.bottomCenter,
              child: BottomMenu(),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// ResourceHUD
// ===========================================================================
/// Top-left HUD showing Food / Population / Happiness with live Riverpod data.
class ResourceHUD extends ConsumerWidget {
  const ResourceHUD({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ref.watch(gameStateProvider).resources;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: GameConstants.uiPanelColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WinterPalette.frostBlue, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _HudRow(
            icon: Icons.restaurant,
            color: WinterPalette.warmFire,
            label: 'Food',
            value: '${r.food}/${r.maxFood}',
          ),
          _HudRow(
            icon: Icons.people,
            color: WinterPalette.frostBlue,
            label: 'Population',
            value: '${r.population}/${r.maxPopulation}',
          ),
          _HudRow(
            icon: Icons.sentiment_satisfied,
            color: WinterPalette.pineGreen,
            label: 'Happiness',
            value: '${r.happiness}%',
          ),
          const SizedBox(height: 2),
          _HudRow(
            icon: Icons.forest,
            color: WinterPalette.woodTan,
            label: 'Wood',
            value: '${r.wood}   🪨 ${r.stone}',
          ),
        ],
      ),
    );
  }
}

class _HudRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _HudRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Top controls
// ===========================================================================
class _TopControls extends StatelessWidget {
  final bool paused;
  final VoidCallback onPause;
  final VoidCallback onSettings;
  final VoidCallback onHome;

  const _TopControls({
    required this.paused,
    required this.onPause,
    required this.onSettings,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _circle(paused ? Icons.play_arrow : Icons.pause, onPause),
        const SizedBox(width: 8),
        _circle(Icons.settings, onSettings),
        const SizedBox(width: 8),
        _circle(Icons.home, onHome),
      ],
    );
  }

  Widget _circle(IconData icon, VoidCallback onTap) {
    return Material(
      color: WinterPalette.frostBlue,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

// ===========================================================================
// BottomMenu
// ===========================================================================
/// Bottom bar: active building preview + a "Build" entry that opens the
/// [BuildingSelector], plus a quick-toggle for placement mode.
class BottomMenu extends ConsumerWidget {
  const BottomMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placing = ref.watch(placementModeProvider);
    final selected = ref.watch(selectedBuildingProvider);

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: GameConstants.uiPanelColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: WinterPalette.deepIce, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active building preview.
          _ActivePreview(type: selected, active: placing),
          const SizedBox(width: 10),

          // Placement mode toggle.
          _MenuButton(
            icon: placing ? Icons.touch_app : Icons.pan_tool,
            label: placing ? 'Placing' : 'Move',
            highlighted: placing,
            onTap: () =>
                ref.read(placementModeProvider.notifier).update((p) => !p),
          ),
          const SizedBox(width: 8),

          // Open building selector.
          _MenuButton(
            icon: Icons.add_home_work,
            label: 'Build',
            highlighted: false,
            onTap: () => _openSelector(context, ref),
          ),
        ],
      ),
    );
  }

  void _openSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const BuildingSelector(),
    );
  }
}

class _ActivePreview extends StatelessWidget {
  final BuildingType? type;
  final bool active;

  const _ActivePreview({required this.type, required this.active});

  @override
  Widget build(BuildContext context) {
    final t = type;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? WinterPalette.frostBlue : Colors.white12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: t == null
                  ? Colors.grey
                  : WinterPalette.forBuilding(t),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            t?.displayName ?? 'None',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlighted;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.highlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: highlighted ? WinterPalette.pineGreen : Colors.white24,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// BuildingSelector (modal popup)
// ===========================================================================
/// Modal grid of available buildings with cost display. Selecting one sets the
/// active building, enables placement mode, and closes the sheet.
class BuildingSelector extends ConsumerWidget {
  const BuildingSelector({super.key});

  static String formatCost(Map<ResourceType, int> cost) {
    if (cost.isEmpty) return 'Free';
    return cost.entries.map((e) => '${e.value} ${e.key.label}').join(', ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedBuildingProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1B2A3A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Select a Building',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.82,
            children: BuildingType.values.map((type) {
              final isSelected = type == selected;
              return _BuildingCard(
                type: type,
                selected: isSelected,
                onTap: () {
                  ref.read(selectedBuildingProvider.notifier).state = type;
                  ref.read(placementModeProvider.notifier).state = true;
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        ],
        ),
      ),
    );
  }
}

class _BuildingCard extends StatelessWidget {
  final BuildingType type;
  final bool selected;
  final VoidCallback onTap;

  const _BuildingCard({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? WinterPalette.frostBlue : Colors.white10,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.white : Colors.white24,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: WinterPalette.forBuilding(type),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              type.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${type.dimensions.x.toInt()}x${type.dimensions.y.toInt()}',
              style: const TextStyle(color: Colors.white54, fontSize: 9),
            ),
            const SizedBox(height: 2),
            Text(
              BuildingSelector.formatCost(type.cost),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: WinterPalette.ice,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
