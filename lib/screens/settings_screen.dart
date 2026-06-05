import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/constants.dart';

/// Simple toggle-based settings for sound and music.
///
/// Backed by local providers; wire these to Hive persistence as needed.
final soundEnabledProvider = StateProvider<bool>((ref) => true);
final musicEnabledProvider = StateProvider<bool>((ref) => true);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sound = ref.watch(soundEnabledProvider);
    final music = ref.watch(musicEnabledProvider);

    return Scaffold(
      backgroundColor: GameConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: GameConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Sound Effects'),
            value: sound,
            activeColor: GameConstants.primaryColor,
            onChanged: (v) =>
                ref.read(soundEnabledProvider.notifier).state = v,
          ),
          SwitchListTile(
            title: const Text('Music'),
            value: music,
            activeColor: GameConstants.primaryColor,
            onChanged: (v) =>
                ref.read(musicEnabledProvider.notifier).state = v,
          ),
          const Divider(),
          const ListTile(
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}
