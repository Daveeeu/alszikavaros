import 'package:flutter/material.dart';

class NightActionScreen extends StatelessWidget {
  const NightActionScreen({required this.gameId, super.key});

  final String gameId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Éjszakai akció')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Night action skeleton. Implementation in Step 8.'),
      ),
    );
  }
}
