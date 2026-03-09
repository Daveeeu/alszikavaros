import 'package:flutter/material.dart';

class DiscussionScreen extends StatelessWidget {
  const DiscussionScreen({required this.gameId, super.key});

  final String gameId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Megbeszélés')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Discussion skeleton.'),
      ),
    );
  }
}
