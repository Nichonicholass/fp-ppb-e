import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fintell/main.dart';
import 'package:fintell/shared/providers/nav_provider.dart';

void main() {
  testWidgets('Fintell app launches and shows bottom nav', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => NavProvider(),
        child: const FintellApp(),
      ),
    );

    expect(find.text('Market'), findsOneWidget);
    expect(find.text('Portfolio'), findsOneWidget);
  });
}
