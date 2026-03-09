import 'package:flutter/material.dart';

class DayResultScreen extends StatelessWidget {
  const DayResultScreen({required this.gameId, super.key});

  final String gameId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nappali eredmény')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Day result skeleton.'),
      ),
    );
  }
}
