import 'package:flutter/material.dart';

class VotingScreen extends StatelessWidget {
  const VotingScreen({required this.gameId, super.key});

  final String gameId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Szavazás')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Voting skeleton. Implementation in Step 9.'),
      ),
    );
  }
}
