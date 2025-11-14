import 'package:flutter_test/flutter_test.dart';
import 'package:dtune/main.dart';

void main() {
  testWidgets('App renders login screen by default', (tester) async {
    await tester.pumpWidget(const DTuneApp());

    expect(find.text('Sign in to your Navidrome server'), findsOneWidget);
  });
}
