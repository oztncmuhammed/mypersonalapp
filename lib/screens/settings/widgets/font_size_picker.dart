import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';

class FontSizePicker extends StatelessWidget {
  const FontSizePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.font_download),
      title: const Text('Font Boyutu'),
      trailing: DropdownButton<AppFontSize>(
        value: AppFontSize.values[
            Provider.of<ThemeNotifier>(context, listen: false).fontSize <= 14
                ? 0
                : Provider.of<ThemeNotifier>(context, listen: false).fontSize <=
                        16
                    ? 1
                    : 2],
        onChanged: (AppFontSize? newValue) {
          if (newValue != null) {
            Provider.of<ThemeNotifier>(context, listen: false).setFontSize(
                Provider.of<ThemeNotifier>(context, listen: false)
                    .getFontSize(newValue));
          }
        },
        items: AppFontSize.values.map((AppFontSize size) {
          return DropdownMenuItem<AppFontSize>(
            value: size,
            child: Text(_getFontSizeText(size)),
          );
        }).toList(),
      ),
    );
  }

  String _getFontSizeText(AppFontSize size) {
    switch (size) {
      case AppFontSize.small:
        return 'Küçük';
      case AppFontSize.medium:
        return 'Orta';
      case AppFontSize.large:
        return 'Büyük';
    }
  }
}
