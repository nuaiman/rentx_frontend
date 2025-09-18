import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/init/screens/init_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: Color(0xFFffffff),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFffffff),
          surfaceTintColor: Color(0xFFffffff),
        ),
      ),
      // home: AuthScreen(),
      // home: HomeScreen(),
      home: InitScreen(),
    );
  }
}
