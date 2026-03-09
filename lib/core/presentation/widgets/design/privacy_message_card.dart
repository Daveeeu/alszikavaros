import 'package:flutter/material.dart';

class PrivacyMessageCard extends StatelessWidget {
  const PrivacyMessageCard({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blueGrey.withValues(alpha: 0.26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility_off_outlined, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
