import 'package:flutter_test/flutter_test.dart';
import 'package:bell_pepper_collector/main.dart';

void main() {
  testWidgets('App load smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(BellPepperApp());

    // Verify that the home screen loads with the correct title.
    expect(find.text('Bell Pepper Data Collector'), findsOneWidget);
    
    // Verify that the main buttons are present.
    expect(find.text('ADD NEW SAMPLE'), findsOneWidget);
    expect(find.text('VIEW ALL RECORDS'), findsOneWidget);
  });
}
