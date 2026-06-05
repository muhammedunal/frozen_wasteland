import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/constants.dart';
import '../../../models/resource.dart';

/// In-world HUD pinned to the top-left of the viewport, showing the core
/// resource readout: Food x/max, Population x/max, Happiness x%, plus wood/stone.
class GameUi extends PositionComponent {
  Resources resources;

  GameUi({required this.resources})
      : super(priority: 1000, position: Vector2.zero());

  late final TextPaint _textPaint = TextPaint(
    style: const TextStyle(
      color: GameConstants.uiTextColor,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
  );

  final Paint _panelPaint = Paint()..color = GameConstants.uiPanelColor;

  void updateResources(Resources newResources) {
    resources = newResources;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    const panelW = 150.0;
    const panelH = 92.0;
    final rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(8, 8, panelW, panelH),
      const Radius.circular(8),
    );
    canvas.drawRRect(rrect, _panelPaint);

    final lines = <String>[
      'Food: ${resources.food}/${resources.maxFood}',
      'Population: ${resources.population}/${resources.maxPopulation}',
      'Happiness: ${resources.happiness}%',
      'Wood: ${resources.wood}   Stone: ${resources.stone}',
    ];

    var y = 16.0;
    for (final line in lines) {
      _textPaint.render(canvas, line, Vector2(16, y));
      y += 20;
    }
  }
}
