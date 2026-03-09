import '../../../../core/presentation/widgets/design/player_list_item.dart';

class PlayerTile extends PlayerListItem {
  const PlayerTile({
    required super.name,
    super.isHost,
    super.isAlive,
    super.key,
  });
}
