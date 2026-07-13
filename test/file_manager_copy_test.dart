import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/flavor_config.dart';

import 'utils/test_mock_channel_handlers.dart';

void main() {
  group('FileManager.copyFile:', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupMockPathProvider();
    FlavorConfig.setup();

    setUpAll(() async {
      await FileManager.init();
      final testDir = Directory('${FileManager.documentsDirectory}/copy-test');
      if (testDir.existsSync()) testDir.deleteSync(recursive: true);
    });

    Uint8List bytes(int seed, int length) =>
        Uint8List.fromList(List.generate(length, (i) => (seed + i) % 256));

    test('copies a note with its assets and preview identically', () async {
      const path = '/copy-test/note';
      final noteBytes = bytes(1, 100);
      final asset0Bytes = bytes(2, 5000);
      final asset1Bytes = bytes(3, 300);
      final previewBytes = bytes(4, 200);

      await FileManager.writeFile('$path.sbn2', noteBytes, awaitWrite: true);
      await FileManager.writeFile(
        '$path.sbn2.0',
        asset0Bytes,
        awaitWrite: true,
      );
      await FileManager.writeFile(
        '$path.sbn2.1',
        asset1Bytes,
        awaitWrite: true,
      );
      await FileManager.writeFile(
        '$path.sbn2.p',
        previewBytes,
        awaitWrite: true,
      );

      final copiedPath = await FileManager.copyFile('$path.sbn2', '$path.sbn2');

      expect(copiedPath, '/copy-test/note (2).sbn2');
      expect(await FileManager.readFile(copiedPath), noteBytes);
      expect(await FileManager.readFile('$copiedPath.0'), asset0Bytes);
      expect(await FileManager.readFile('$copiedPath.1'), asset1Bytes);
      expect(await FileManager.readFile('$copiedPath.p'), previewBytes);

      // the original files are untouched
      expect(await FileManager.readFile('$path.sbn2'), noteBytes);
      expect(await FileManager.readFile('$path.sbn2.0'), asset0Bytes);

      // copying again picks the next free suffix
      final copiedAgain = await FileManager.copyFile(
        '$path.sbn2',
        '$path.sbn2',
      );
      expect(copiedAgain, '/copy-test/note (3).sbn2');
    });

    test('copies a note without assets', () async {
      const path = '/copy-test/plain';
      final noteBytes = bytes(5, 50);
      await FileManager.writeFile('$path.sbn2', noteBytes, awaitWrite: true);

      final copiedPath = await FileManager.copyFile('$path.sbn2', '$path.sbn2');

      expect(copiedPath, '/copy-test/plain (2).sbn2');
      expect(await FileManager.readFile(copiedPath), noteBytes);
      expect(FileManager.doesFileExist('$copiedPath.0'), isFalse);
      expect(FileManager.doesFileExist('$copiedPath.p'), isFalse);
    });
  });
}
