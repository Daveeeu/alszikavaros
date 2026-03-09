import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/app_scaffold.dart';
import '../../../../core/presentation/widgets/design/error_banner.dart';
import '../../../../core/presentation/widgets/design/phase_header.dart';
import '../../../../core/presentation/widgets/design/primary_button.dart';
import '../../../../core/presentation/widgets/design/privacy_message_card.dart';
import '../../../../core/presentation/widgets/design/secondary_button.dart';
import '../../../../core/router/route_paths.dart';
import '../../../room/application/room_entry_controller.dart';

class CreateOrJoinRoomScreen extends ConsumerStatefulWidget {
  const CreateOrJoinRoomScreen({super.key});

  @override
  ConsumerState<CreateOrJoinRoomScreen> createState() =>
      _CreateOrJoinRoomScreenState();
}

class _CreateOrJoinRoomScreenState
    extends ConsumerState<CreateOrJoinRoomScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entryState = ref.watch(roomEntryControllerProvider);

    return AppScaffold(
      title: 'Szoba',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PhaseHeader(
            title: 'Szobakezelés',
            subtitle: 'Adj meg egy nevet, majd válassz műveletet.',
          ),
          const SizedBox(height: 14),
          const PrivacyMessageCard(
            message: 'A képernyődön csak a saját titkos információid jelennek meg.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            textInputAction: TextInputAction.done,
            onChanged:
                ref.read(roomEntryControllerProvider.notifier).updatePlayerName,
            decoration: const InputDecoration(
              labelText: 'Játékosnév',
              hintText: 'pl. Dávid',
            ),
          ),
          const SizedBox(height: 12),
          if (entryState.errorMessage.isNotEmpty)
            ErrorBanner(message: entryState.errorMessage),
          const Spacer(),
          PrimaryButton(
            label: 'Új szoba létrehozása',
            icon: Icons.add_circle_outline,
            isLoading: entryState.isSubmitting,
            onPressed: entryState.isSubmitting
                ? null
                : () async {
                    final target = await ref
                        .read(roomEntryControllerProvider.notifier)
                        .createRoom();

                    if (target != null && context.mounted) {
                      context.go(target);
                    }
                  },
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Csatlakozás meglévő szobához',
            icon: Icons.login_rounded,
            onPressed: entryState.isSubmitting
                ? null
                : () {
                    ref
                        .read(roomEntryControllerProvider.notifier)
                        .updatePlayerName(_nameController.text);
                    context.push(RoutePaths.join);
                  },
          ),
        ],
      ),
    );
  }
}
