// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // await tester.pumpWidget(const MyApp());
    //
    // // Verify that our counter starts at 0.
    // expect(find.text('0'), findsOneWidget);
    // expect(find.text('1'), findsNothing);
    //
    // // Tap the '+' icon and trigger a frame.
    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pump();
    //https://th.wallhaven.cc/orig/x8/x8x7dz.jpg
    //https://w.wallhaven.cc/full/x8/wallhaven-x8x7dz.jpg
    //https://w.wallhaven.cc/full/x8/wallhevan-x8x7dz.jpg
    //https://w.wallhaven.cc/full/8o/wallhaven-8o25xo.png
    //https://w.wallhaven.cc/full/8o/wallhaven-8o25xo.jpg
    // String src = 'https://th.wallhaven.cc/orig/x8/x8x7dz.jpg';
    // List<String> fullSrc = src.replaceAll('/th.wallhaven.cc/orig/', '/w.wallhaven.cc/full/').split('/');
    // fullSrc[fullSrc.length-1] = "wallhaven-${fullSrc[fullSrc.length-1]}";
    // debugPrint(fullSrc.join('/'));
    String name = 'remember_web1';
    print(name.contains('remember_web'));
    // Verify that our counter has incremented.
    // expect(find.text('0'), findsNothing);
    // expect(find.text('1'), findsOneWidget);
  });
}
