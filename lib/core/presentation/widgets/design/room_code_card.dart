import 'package:flutter/material.dart';

class RoomCodeCard extends StatelessWidget {
  const RoomCodeCard({required this.roomCode, super.key});

  final String roomCode;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Szobakód', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            SelectableText(
              roomCode,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 2.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
