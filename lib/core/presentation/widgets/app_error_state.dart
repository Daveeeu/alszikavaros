import 'package:flutter/material.dart';

import 'design/error_banner.dart';
import 'design/secondary_button.dart';

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    required this.message,
    this.title = 'Hiba történt',
    this.retryLabel = 'Újrapróbálás',
    this.onRetry,
    super.key,
  });

  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ErrorBanner(message: message),
              if (onRetry != null) ...[
                const SizedBox(height: 14),
                SecondaryButton(
                  label: retryLabel,
                  icon: Icons.refresh,
                  onPressed: onRetry,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
