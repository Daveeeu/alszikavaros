import 'package:flutter/material.dart';

class PlayerListItem extends StatelessWidget {
  const PlayerListItem({
    required this.name,
    this.isHost = false,
    this.isAlive = true,
    this.trailing,
    super.key,
  });

  final String name;
  final bool isHost;
  final bool isAlive;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: textTheme.titleSmall,
                      ),
                    ),
                    if (isHost)
                      const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isAlive ? 'Él' : 'Kiesett',
                  style: textTheme.bodySmall?.copyWith(
                    color: isAlive ? Colors.greenAccent.shade100 : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
