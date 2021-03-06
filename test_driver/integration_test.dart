import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String screenshotName, List<int> screenshotBytes) async {
      final File image = File('screenshots/$screenshotName.png');
      image.writeAsBytesSync(screenshotBytes);
      return true;
    });
}
