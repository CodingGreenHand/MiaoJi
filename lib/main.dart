import 'package:flutter/material.dart';
import 'package:miao_ji/services/word_memorizing_system.dart';
import 'package:miao_ji/screens/home_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await WordMemorizingSystem().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Miao Ji',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}