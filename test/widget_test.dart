import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:frozen_wasteland/main.dart';

void main() {
  testWidgets('App boots and shows loading screen', (WidgetTester tester) async {
    // Build the app wrapped in a ProviderScope (Riverpod requirement).
    await tester.pumpWidget(const ProviderScope(child: FrozenWastelandApp()));

    // The bootstrap loading screen shows the game title + spinner.
    expect(find.text('Frozen Wasteland'), findsOneWidget);
    expect(find.byIcon(Icons.ac_unit), findsOneWidget);

    // Advance past the bootstrap delay so the menu is shown and no timers
    // remain pending when the tree is torn down.
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Frozen Wasteland'), findsOneWidget);
  });
}
