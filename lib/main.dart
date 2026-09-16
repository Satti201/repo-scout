import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: RepoScoutApp(),
    ),
  );
}

class RepoScoutApp extends StatelessWidget {
  const RepoScoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RepoScout',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('RepoScout - GitHub Explorer'),
        ),
      ),
    );
  }
}
