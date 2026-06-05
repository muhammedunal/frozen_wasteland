import 'package:flutter/material.dart';

// ============================================================
// FROZEN WASTELAND — Design System
// Converted from ds.css + wasteland.css
// ============================================================

// ---- COLORS ------------------------------------------------

class AppColors {
  AppColors._();

  // Primary · Icy Blue
  static const Color primary100 = Color(0xFFDCEBF5);
  static const Color primary300 = Color(0xFFA7CFE6);
  static const Color primary500 = Color(0xFF6FAAD2);
  static const Color primary700 = Color(0xFF3D7BAC);
  static const Color primary900 = Color(0xFF21506F);

  // Secondary · Earth Brown
  static const Color secondary100 = Color(0xFFEBDDCC);
  static const Color secondary300 = Color(0xFFCFA87F);
  static const Color secondary500 = Color(0xFFA4744A);
  static const Color secondary700 = Color(0xFF7B5230);
  static const Color secondary900 = Color(0xFF4D331F);

  // Accent · Ember Red
  static const Color accent300 = Color(0xFFF3A89F);
  static const Color accent500 = Color(0xFFE14A3B);
  static const Color accent700 = Color(0xFFB12B1F);

  // Neutral · Snow & Ice
  static const Color snowWhite = Color(0xFFFFFFFF);
  static const Color snow50    = Color(0xFFF5F9FC);
  static const Color ice100    = Color(0xFFE6EEF3);
  static const Color ice200    = Color(0xFFCDDAE2);
  static const Color ice400    = Color(0xFF9BABB6);
  static const Color ice600    = Color(0xFF647682);

  // Text
  static const Color textStrong  = Color(0xFF16242C);
  static const Color textBody    = Color(0xFF51616B);
  static const Color textMuted   = Color(0xFF8B99A2);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Functional · resource & status (ds.css)
  static const Color gold500   = Color(0xFFF2B33C); // coins / fire
  static const Color gold700   = Color(0xFFC98916);
  static const Color cash500   = Color(0xFF4FAE5A); // cash / wood-leaf
  static const Color frostGlow = Color(0xFFBFE6FF); // ui glow / selection

  // Wasteland · Snow / Sky
  static const Color snow    = Color(0xFFF5F7FA);
  static const Color snow2   = Color(0xFFE8EEF4);
  static const Color snow3   = Color(0xFFD7E2EC);
  static const Color sky1    = Color(0xFFE4EEF7);
  static const Color sky2    = Color(0xFFC7DCEE);

  // Wasteland · Warm Browns / Wood / Dirt
  static const Color brown   = Color(0xFF8B6F47);
  static const Color brownD  = Color(0xFF6E5638);
  static const Color brownL  = Color(0xFFA98A5C);
  static const Color dirt    = Color(0xFFB98D55);
  static const Color dirtD   = Color(0xFF9A6F3E);
  static const Color dirtL   = Color(0xFFCDA26B);
  static const Color wood    = Color(0xFFA9744B);
  static const Color woodD   = Color(0xFF7E5230);
  static const Color woodL   = Color(0xFFC08A5C);

  // Wasteland · Cool Blues
  static const Color blue    = Color(0xFF4A90E2);
  static const Color blue2   = Color(0xFF5DADE2);
  static const Color blueD   = Color(0xFF2C6BB8);
  static const Color blueL   = Color(0xFF8FC3EE);

  // Wasteland · Fire
  static const Color fire    = Color(0xFFFF6B35);
  static const Color fire2   = Color(0xFFFF8C42);
  static const Color flame   = Color(0xFFFFB23E);
  static const Color ember   = Color(0xFFFFE08A);

  // Wasteland · Gold / Cash
  static const Color gold    = Color(0xFFFFD700);
  static const Color goldD   = Color(0xFFE0A92E);
  static const Color goldL   = Color(0xFFFFE873);
  static const Color cash    = Color(0xFF4FB06A);
  static const Color cashD   = Color(0xFF3C9455);
  static const Color cashL   = Color(0xFF7FCB93);

  // Wasteland · Ink / Status
  static const Color ink     = Color(0xFF2C3E50);
  static const Color ink2    = Color(0xFF46586B);
  static const Color ink3    = Color(0xFF73849A);
  static const Color danger  = Color(0xFFE5443B);
  static const Color good    = Color(0xFF3FB45A);
  static const Color warn    = Color(0xFFF2A33C);
}

// ---- SPACING (8px base) ------------------------------------

class AppSizes {
  AppSizes._();

  // Spacing scale
  static const double sp1 = 4.0;
  static const double sp2 = 8.0;
  static const double sp3 = 16.0;
  static const double sp4 = 24.0;
  static const double sp5 = 32.0;
  static const double sp6 = 40.0;
  static const double sp7 = 48.0;

  // Semantic aliases
  static const double paddingXS  = sp1; // 4
  static const double paddingS   = sp2; // 8
  static const double paddingM   = sp3; // 16
  static const double paddingL   = sp4; // 24
  static const double paddingXL  = sp5; // 32
  static const double padding2XL = sp6; // 40
  static const double padding3XL = sp7; // 48

  // Border radii — ds.css design system
  static const double radiusSm   = 8.0;
  static const double radiusMd   = 12.0;
  static const double radiusLg   = 16.0;
  static const double radiusXl   = 22.0;
  static const double radiusPill = 999.0;

  // Border radii — wasteland.css in-game UI (slightly larger)
  static const double wRadiusSm  = 8.0;
  static const double wRadiusMd  = 13.0;
  static const double wRadiusLg  = 18.0;
  static const double wRadiusXl  = 24.0;
}

// ---- SHADOWS -----------------------------------------------

class AppShadows {
  AppShadows._();

  // ds.css
  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x1416242C), blurRadius: 2,  offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0F16242C), blurRadius: 6,  offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x1A16242C), blurRadius: 10, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x1A16242C), blurRadius: 28, offset: Offset(0, 12)),
  ];
  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x2E16242C), blurRadius: 50, offset: Offset(0, 18)),
  ];
  static const List<BoxShadow> frost = [
    BoxShadow(color: Color(0x8CBFE6FF), blurRadius: 0, spreadRadius: 4),
  ];

  // wasteland.css
  static const List<BoxShadow> sh1 = [
    BoxShadow(color: Color(0x241C2C40), blurRadius: 6,  offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> sh2 = [
    BoxShadow(color: Color(0x2E1C2C40), blurRadius: 18, offset: Offset(0, 6)),
  ];
  static const List<BoxShadow> sh3 = [
    BoxShadow(color: Color(0x42142030), blurRadius: 36, offset: Offset(0, 14)),
  ];
}

// ---- TEXT STYLES -------------------------------------------
// Fonts: 'Fredoka' (display/UI) · 'Nunito' (body)

class AppTextStyles {
  AppTextStyles._();

  // Display — Fredoka
  static const TextStyle displayXl = TextStyle(
    fontFamily: 'Fredoka',
    fontWeight: FontWeight.w700,
    fontSize: 66,
    height: 0.98,
    letterSpacing: -1.32, // -.02em
  );
  static const TextStyle displayLg = TextStyle(
    fontFamily: 'Fredoka',
    fontWeight: FontWeight.w700,
    fontSize: 50,
    letterSpacing: -0.5, // -.01em
  );
  static const TextStyle displayMd = TextStyle(
    fontFamily: 'Fredoka',
    fontWeight: FontWeight.w700,
    fontSize: 30,
    height: 1.1,
    letterSpacing: -0.3,
  );
  static const TextStyle displaySm = TextStyle(
    fontFamily: 'Fredoka',
    fontWeight: FontWeight.w600,
    fontSize: 26,
    height: 1.15,
  );

  // UI titles — Fredoka (panel headers, sheet titles)
  static const TextStyle titleLg = TextStyle(
    fontFamily: 'Fredoka',
    fontWeight: FontWeight.w600,
    fontSize: 20,
    height: 1.05,
  );
  static const TextStyle titleMd = TextStyle(
    fontFamily: 'Fredoka',
    fontWeight: FontWeight.w600,
    fontSize: 18,
  );
  static const TextStyle titleSm = TextStyle(
    fontFamily: 'Fredoka',
    fontWeight: FontWeight.w600,
    fontSize: 15,
  );

  // Stat / numeric values — Fredoka
  static const TextStyle statXl = TextStyle(
    fontFamily: 'Fredoka',
    fontWeight: FontWeight.w600,
    fontSize: 24,
  );
  static const TextStyle statLg = TextStyle(
    fontFamily: 'Fredoka',
    fontWeight: FontWeight.w600,
    fontSize: 20,
  );
  static const TextStyle statMd = TextStyle(
    fontFamily: 'Fredoka',
    fontWeight: FontWeight.w600,
    fontSize: 19,
  );

  // HUD resource values — Fredoka
  static const TextStyle hudValue = TextStyle(
    fontFamily: 'Fredoka',
    fontWeight: FontWeight.w600,
    fontSize: 15,
  );
  static const TextStyle hudValueSm = TextStyle(
    fontFamily: 'Fredoka',
    fontWeight: FontWeight.w600,
    fontSize: 13,
  );

  // Buttons — Fredoka
  static const TextStyle btnLg = TextStyle(
    fontFamily: 'Fredoka',
    fontWeight: FontWeight.w600,
    fontSize: 18,
    letterSpacing: 0.18,
  );
  static const TextStyle btnMd = TextStyle(
    fontFamily: 'Fredoka',
    fontWeight: FontWeight.w600,
    fontSize: 17,
    letterSpacing: 0.17,
  );
  static const TextStyle btnSm = TextStyle(
    fontFamily: 'Fredoka',
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );

  // Body — Nunito
  static const TextStyle bodyLg = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w600,
    fontSize: 17,
    height: 1.6,
  );
  static const TextStyle bodyMd = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.55,
  );
  static const TextStyle bodySm = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w600,
    fontSize: 15,
    height: 1.55,
  );
  static const TextStyle bodyXs = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.5,
  );

  // Captions / labels — Nunito
  static const TextStyle caption = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w600,
    fontSize: 13,
  );
  static const TextStyle overline = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w800,
    fontSize: 11,
    height: 1.0,
    letterSpacing: 1.54, // .14em
  );
  static const TextStyle label = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w800,
    fontSize: 12,
    letterSpacing: 1.44, // .12em
  );
  static const TextStyle micro = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w800,
    fontSize: 9,
    letterSpacing: 0.72, // .08em
  );
}

// ============================================================
// GAME CONSTANTS (existing)
// ============================================================

/// Global constants for the Frozen Wasteland game.
class GameConstants {
  GameConstants._();

  // ---------------------------------------------------------------------------
  // Screen / Viewport
  // ---------------------------------------------------------------------------
  /// Fixed logical resolution used by the game viewport.
  static const double viewportWidth = 384.0;
  static const double viewportHeight = 832.0;

  // ---------------------------------------------------------------------------
  // Isometric tile dimensions
  // ---------------------------------------------------------------------------
  /// Width of a single isometric tile in pixels.
  static const double tileWidth = 64.0;

  /// Height of a single isometric tile in pixels (typically half the width).
  static const double tileHeight = 32.0;

  /// Number of tiles along one edge of the square grid.
  static const int gridSize = 16;

  /// Whether to draw per-tile coordinate debug text on the grid.
  static const bool showGridDebugCoords = false;

  // ---------------------------------------------------------------------------
  // Alternating grid (checkerboard) colors
  // ---------------------------------------------------------------------------
  /// Even-parity tile fill (lighter ice).
  static const Color tileColorA = Color(0xFFE8EEF2);

  /// Odd-parity tile fill (slightly darker ice) for the alternating pattern.
  static const Color tileColorB = Color(0xFFD4E2EA);

  // ---------------------------------------------------------------------------
  // Colors
  // ---------------------------------------------------------------------------
  /// Background color of the game world (light gray).
  static const Color backgroundColor = Color(0xFFF5F5F5);

  /// Primary accent color (frozen blue).
  static const Color primaryColor = Color(0xFF4A90D9);

  /// Secondary accent color (ice teal).
  static const Color secondaryColor = Color(0xFF7FD3E0);

  /// Grid line color.
  static const Color gridLineColor = Color(0xFFBDC9D1);

  /// Grid tile fill color.
  static const Color tileFillColor = Color(0xFFE8EEF2);

  /// Highlighted tile color (selection).
  static const Color tileHighlightColor = Color(0xFFA8D8EA);

  /// UI panel background.
  static const Color uiPanelColor = Color(0xCC1B2A3A);

  /// UI text color.
  static const Color uiTextColor = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // Gameplay
  // ---------------------------------------------------------------------------
  /// Default movement speed of animals (pixels per second).
  static const double animalSpeed = 40.0;

  /// Maximum priority value used by pathfinding heuristics.
  static const double maxPathCost = 1e9;
}
