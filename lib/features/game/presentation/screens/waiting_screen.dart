import 'package:flutter/material.dart';

class WaitingScreen extends StatelessWidget {
  const WaitingScreen({required this.gameId, super.key});

  final String gameId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Várakozás')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Waiting screen skeleton.'),
      ),
    );
  }
}
