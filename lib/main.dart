import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicia o Hive (DATABASE)
  await Hive.initFlutter();

  // Abre uma tabela para guardar os recibos
  await Hive.openBox('receipts');
  await Hive.openBox('settings');

  runApp(const FaturaeApp());
}

class FaturaeApp extends StatelessWidget {
  const FaturaeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Faturaê',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4C86D9),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}