import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../lib/main.dart';
import '../lib/state.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
    as IntegrationTestWidgetsFlutterBinding;

  testWidgets('screenshot', (WidgetTester tester) async {
    appMain(persistent: false, debugShowCheckedModeBanner: false);
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();

    final DocsView view = tester.firstWidget(find.byType(DocsView));
    final todos = await Todos.createList(view.sdk, 'shopping list');
    todos.create('milk');
    todos.create('bread');
    todos.create('butter');
    await tester.pumpAndSettle();
    await binding.takeScreenshot('screenshot-docs');

    final item = find.byType(DocTile);
    await tester.tap(item);
    await tester.pumpAndSettle();
    await binding.takeScreenshot('screenshot-shopping-list');
  });
}
