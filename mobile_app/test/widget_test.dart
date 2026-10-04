import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';

void main() {
  testWidgets('DoSJE Smart Inspection app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const DosjeApp());

    expect(find.text('DoSJE Smart Inspection'), findsOneWidget);
    expect(find.text('Official Login'), findsOneWidget);
    expect(find.text('Inspector Login'), findsOneWidget);
  });
}