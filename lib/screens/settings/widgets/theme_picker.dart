import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';

class ThemePicker extends StatelessWidget {
  const ThemePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.palette),
      title: const Text('Tema'),
      trailing: DropdownButton<AppThemeMode>(
        value: AppThemeMode
            .values[Theme.of(context).brightness == Brightness.light ? 0 : 1],
        onChanged: (AppThemeMode? newValue) {
          if (newValue != null) {
            Provider.of<ThemeNotifier>(context, listen: false).setThemeMode(
                newValue == AppThemeMode.light
                    ? ThemeMode.light
                    : ThemeMode.dark);
          }
        },
        items: AppThemeMode.values.map((AppThemeMode mode) {
          return DropdownMenuItem<AppThemeMode>(
            value: mode,
            child: Text(mode == AppThemeMode.light ? 'Açık' : 'Koyu'),
          );
        }).toList(),
      ),
    );
  }
}
