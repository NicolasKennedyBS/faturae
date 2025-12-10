import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  await Hive.openBox('receipts');
  var settingsBox = await Hive.openBox('settings');

  bool initialDarkMode = settingsBox.get('isDarkMode', defaultValue: false);

  runApp(FaturaeApp(initialDarkMode: initialDarkMode));
}

class FaturaeApp extends StatelessWidget {
  final bool initialDarkMode;

  const FaturaeApp({super.key, required this.initialDarkMode});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, Box box, widget) {

        final isDark = box.get('isDarkMode', defaultValue: initialDarkMode);

        return MaterialApp(
          title: 'Faturaê',
          debugShowCheckedModeBanner: false,

          locale: const Locale('pt', 'BR'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('pt', 'BR'),
          ],

          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4C86D9),
              brightness: Brightness.light,
              background: const Color(0xFFF5F7FA),
              surface: Colors.white,
            ),
            useMaterial3: true,
            fontFamily: 'Roboto',
            scaffoldBackgroundColor: const Color(0xFFF5F7FA),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF5F7FA),
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            cardTheme: const CardThemeData(
              color: Colors.white,
            ),
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4C86D9),
              brightness: Brightness.dark,
              background: const Color(0xFF121212),
              surface: const Color(0xFF1E1E1E),
            ),
            useMaterial3: true,
            fontFamily: 'Roboto',
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF121212),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            cardTheme: const CardThemeData(
              color: Color(0xFF1E1E1E),
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF1E1E1E),
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: const Color(0xFF1E1E1E),
              indicatorColor: const Color(0xFF4C86D9).withOpacity(0.5),
              iconTheme: MaterialStateProperty.all(const IconThemeData(color: Colors.white)),
              labelTextStyle: MaterialStateProperty.all(const TextStyle(color: Colors.white)),
            ),
          ),

          home: const HomePage(),
        );
      },
    );
  }
}