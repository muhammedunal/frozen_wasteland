import 'package:flutter/material.dart';

import '../models/animal.dart';
import '../models/building.dart';

/// Centralized asset path references for sprites, tiles and audio, plus the
/// winter-theme color palette used for placeholder rendering.
///
/// Place real files under `assets/images/...` and declare them in
/// `pubspec.yaml` under `flutter: assets:` before loading.
class Assets {
  Assets._();

  // Base folders (relative to the `assets/images/` root used by Flame).
  static const String _tiles = 'tiles';
  static const String _buildings = 'buildings';
  static const String _animals = 'animals';
  static const String _ui = 'ui';

  // ---------------------------------------------------------------------------
  // Tiles
  // ---------------------------------------------------------------------------
  static const String tileSnow = '$_tiles/snow.png';
  static const String tileIce = '$_tiles/ice.png';
  static const String tileRock = '$_tiles/rock.png';

  // ---------------------------------------------------------------------------
  // Building sprites (keyed lookup below)
  // ---------------------------------------------------------------------------
  static const String buildingWall = '$_buildings/wall.png';
  static const String buildingDoor = '$_buildings/door.png';
  static const String buildingHouse = '$_buildings/house.png';
  static const String buildingBarn = '$_buildings/barn.png';
  static const String buildingFence = '$_buildings/fence.png';
  static const String buildingTree = '$_buildings/tree.png';

  /// Sprite path for a given building type.
  static String buildingSprite(BuildingType type) {
    switch (type) {
      case BuildingType.wall:
        return buildingWall;
      case BuildingType.door:
        return buildingDoor;
      case BuildingType.house:
        return buildingHouse;
      case BuildingType.barn:
        return buildingBarn;
      case BuildingType.fence:
        return buildingFence;
      case BuildingType.tree:
        return buildingTree;
    }
  }

  /// Icon path used in selector UI (falls back to sprite path).
  static String buildingIcon(BuildingType type) =>
      '$_ui/icon_${type.id}.png';

  // ---------------------------------------------------------------------------
  // Animals
  // ---------------------------------------------------------------------------
  // Each animal has a sprite atlas laid out as a grid of:
  //   rows  = directions (down, left, right, up)
  //   cols  = animation frames per direction
  static const String animalBear = '$_animals/bear_atlas.png';
  static const String animalReindeer = '$_animals/reindeer_atlas.png';
  static const String animalWolf = '$_animals/wolf_atlas.png';
  static const String animalElk = '$_animals/elk_atlas.png';
  static const String animalFox = '$_animals/fox_atlas.png';

  /// Sprite atlas path for a given animal type.
  static String animalAtlas(AnimalType type) {
    switch (type) {
      case AnimalType.bear:
        return animalBear;
      case AnimalType.reindeer:
        return animalReindeer;
      case AnimalType.wolf:
        return animalWolf;
      case AnimalType.elk:
        return animalElk;
      case AnimalType.fox:
        return animalFox;
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  static const String uiButton = '$_ui/button.png';
  static const String uiPanel = '$_ui/panel.png';

  /// Every image asset for batch preloading.
  static List<String> get all => [
        tileSnow,
        tileIce,
        tileRock,
        buildingWall,
        buildingDoor,
        buildingHouse,
        buildingBarn,
        buildingFence,
        buildingTree,
        animalBear,
        animalReindeer,
        animalWolf,
        animalElk,
        animalFox,
        uiButton,
        uiPanel,
      ];
}

/// Sprite-sheet layout + animation timing for animals.
class AnimalAnimations {
  AnimalAnimations._();

  /// Pixel size of a single frame in the atlas.
  static const double frameWidth = 32.0;
  static const double frameHeight = 32.0;

  /// Frames per direction (walk cycle).
  static const int walkFrames = 4;

  /// Frames for the idle animation.
  static const int idleFrames = 2;

  /// Seconds per frame while walking.
  static const double walkStepTime = 0.15;

  /// Seconds per frame while idle.
  static const double idleStepTime = 0.5;

  /// Atlas row index per facing direction.
  static const int rowDown = 0;
  static const int rowLeft = 1;
  static const int rowRight = 2;
  static const int rowUp = 3;
}

/// Winter-theme color palette for placeholder rendering and UI accents.
class WinterPalette {
  WinterPalette._();

  static const Color snow = Color(0xFFF5F9FC);
  static const Color ice = Color(0xFFCfE6F0);
  static const Color deepIce = Color(0xFF7FB6CC);
  static const Color frostBlue = Color(0xFF4A90D9);
  static const Color pineGreen = Color(0xFF2E5E4E);
  static const Color barkBrown = Color(0xFF5D4037);
  static const Color stoneGray = Color(0xFF8C99A3);
  static const Color woodTan = Color(0xFFA9805A);
  static const Color warmFire = Color(0xFFFF8F00);

  /// Placeholder fill color per building type.
  static Color forBuilding(BuildingType type) {
    switch (type) {
      case BuildingType.wall:
        return stoneGray;
      case BuildingType.door:
        return woodTan;
      case BuildingType.house:
        return barkBrown;
      case BuildingType.barn:
        return const Color(0xFFB23A48);
      case BuildingType.fence:
        return const Color(0xFF8D6E63);
      case BuildingType.tree:
        return pineGreen;
    }
  }
}
