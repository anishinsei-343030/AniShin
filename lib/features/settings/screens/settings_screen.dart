import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../services/storage_service.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final storage = ref.watch(storageServiceProvider);
    final saved = storage.getString('themeMode', 'dark');
    return _parseThemeMode(saved);
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'amoled':
        return ThemeMode.values.firstWhere(
          (t) => t.name == 'amoled',
          orElse: () => ThemeMode.dark,
        );
      default:
        return ThemeMode.dark;
    }
  }

  void setMode(ThemeMode mode) {
    state = mode;
    final storage = ref.read(storageServiceProvider);
    storage.setString('themeMode', mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle dark theme'),
            value: themeMode == ThemeMode.dark,
            onChanged: (value) {
              ref.read(themeModeProvider.notifier).setMode(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
            },
          ),
          ListTile(
            leading: const Icon(Icons.theater_comedy),
            title: const Text('AMOLED Mode'),
            subtitle: const Text('True black for OLED screens'),
            trailing: Switch(
              value: themeMode == ThemeMode.values.firstWhere(
                (t) => t.name == 'amoled',
                orElse: () => ThemeMode.dark,
              ),
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).setMode(
                      value
                          ? ThemeMode.values.firstWhere((t) => t.name == 'amoled')
                          : ThemeMode.dark,
                    );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text('Version ${snapshot.data!.version}');
                }
                return const Text('Loading...');
              },
            ),
          ),
        ],
      ),
    );
  }
}
