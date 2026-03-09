import 'package:flutter/material.dart';

import 'design/loading_indicator.dart';

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({
    super.key,
    this.message = 'Betöltés...',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LoadingIndicator(),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
