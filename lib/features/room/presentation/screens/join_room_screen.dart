import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/app_scaffold.dart';
import '../../../../core/presentation/widgets/design/error_banner.dart';
import '../../../../core/presentation/widgets/design/phase_header.dart';
import '../../../../core/presentation/widgets/design/primary_button.dart';
import '../../../../core/presentation/widgets/design/privacy_message_card.dart';
import '../../../room/application/room_entry_controller.dart';

class JoinRoomScreen extends ConsumerStatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  ConsumerState<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = ref.watch(roomEntryControllerProvider);

    if (_nameController.text != entry.playerName) {
      _nameController.text = entry.playerName;
    }

    if (_codeController.text != entry.roomCode) {
      _codeController.text = entry.roomCode;
    }

    return AppScaffold(
      title: 'Csatlakozás',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PhaseHeader(
            title: 'Belépés szobába',
            subtitle: 'Add meg a neved és a szobakódot.',
          ),
          const SizedBox(height: 12),
          const PrivacyMessageCard(
            message: 'A telefonod képernyőjén csak a saját titkos információid jelennek meg.',
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            onChanged:
                ref.read(roomEntryControllerProvider.notifier).updatePlayerName,
            decoration: const InputDecoration(labelText: 'Játékosnév'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            maxLength: 6,
            onChanged:
                ref.read(roomEntryControllerProvider.notifier).updateRoomCode,
            decoration: const InputDecoration(labelText: 'Szobakód'),
          ),
          if (entry.errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ErrorBanner(message: entry.errorMessage),
            ),
          const Spacer(),
          PrimaryButton(
            label: 'Belépés a szobába',
            icon: Icons.meeting_room_outlined,
            isLoading: entry.isSubmitting,
            onPressed: entry.isSubmitting
                ? null
                : () async {
                    final target = await ref
                        .read(roomEntryControllerProvider.notifier)
                        .joinRoom();

                    if (target != null && context.mounted) {
                      context.go(target);
                    }
                  },
          ),
        ],
      ),
    );
  }
}
