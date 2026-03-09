import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/domain/enums/role.dart';
import '../../../../core/domain/types/id_types.dart';

part 'final_role_entry.freezed.dart';
part 'final_role_entry.g.dart';

@freezed
class FinalRoleEntry with _$FinalRoleEntry {
  const factory FinalRoleEntry({
    required PlayerId playerId,
    required String playerName,
    required Role role,
    required bool isAlive,
  }) = _FinalRoleEntry;

  factory FinalRoleEntry.fromJson(Map<String, dynamic> json) =>
      _$FinalRoleEntryFromJson(json);
}
