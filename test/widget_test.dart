import 'package:alszik_a_varos/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('app boots', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AlszikAVarosApp()));
    expect(find.text('Alszik a Város'), findsOneWidget);
  });
}
