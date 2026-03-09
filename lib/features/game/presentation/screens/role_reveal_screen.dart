import 'package:flutter/material.dart';

class RoleRevealScreen extends StatelessWidget {
  const RoleRevealScreen({required this.gameId, super.key});

  final String gameId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Szereped')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Role reveal skeleton. Implementation in Step 7.'),
      ),
    );
  }
}
