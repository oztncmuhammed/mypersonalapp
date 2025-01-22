import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home/home_page.dart';
import 'utils/theme_utils.dart';

void main() {
  initializeDateFormatting('tr_TR', null).then((_) => runApp(
        ChangeNotifierProvider(
          create: (_) => ThemeNotifier(),
          child: const MyApp(),
        ),
      ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, _) {
        return MaterialApp(
          title: 'Görev Takip',
          debugShowCheckedModeBanner: false,
          themeMode: themeNotifier.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
            textTheme: buildTextTheme(themeNotifier.fontSize),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              selectedLabelStyle: TextStyle(fontSize: themeNotifier.fontSize),
              unselectedLabelStyle: TextStyle(fontSize: themeNotifier.fontSize),
            ),
            cardTheme: CardTheme(
              elevation: 4,
              margin: const EdgeInsets.all(8),
            ),
            dialogTheme: DialogTheme(
              titleTextStyle: TextStyle(fontSize: themeNotifier.fontSize + 4),
              contentTextStyle: TextStyle(fontSize: themeNotifier.fontSize),
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            textTheme: buildTextTheme(themeNotifier.fontSize),
          ),
          home: const HomePage(),
        );
      },
    );
  }
}
