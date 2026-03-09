import 'package:alszik_a_varos/features/room/application/room_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RoomNotifier', () {
    test('updates room state when setting current room', () {
      final notifier = RoomNotifier();

      notifier.setCurrentRoom(roomCode: 'ABC123', isHost: true);

      expect(notifier.state.currentRoomCode, 'ABC123');
      expect(notifier.state.isHost, true);
    });

    test('clears room state', () {
      final notifier = RoomNotifier();
      notifier.setCurrentRoom(roomCode: 'ABC123', isHost: true);

      notifier.clearCurrentRoom();

      expect(notifier.state.currentRoomCode, isNull);
      expect(notifier.state.isHost, false);
    });

    test('generates room code with expected format', () {
      final notifier = RoomNotifier();

      final code = notifier.generateRoomCode();

      expect(code.length, 6);
      expect(RegExp(r'^[A-Z2-9]{6}$').hasMatch(code), isTrue);
      expect(code.contains('I'), isFalse);
      expect(code.contains('O'), isFalse);
      expect(code.contains('0'), isFalse);
      expect(code.contains('1'), isFalse);
    });
  });
}
