import 'dart:io';

import 'package:unused_assets_removal/src/asset_reporter.dart';
import 'package:unused_assets_removal/src/asset_scanner.dart';
import 'package:unused_assets_removal/src/reference_scanner.dart';
import 'package:test/test.dart';

void main() {
  group('AssetScanner', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('flutter_project_');
      final assetsDir = Directory('${tempDir.path}/assets/images')..createSync(recursive: true);
      final imageFile = File('${assetsDir.path}/photo.png');
      await imageFile.writeAsBytes([0, 1, 2, 3]);
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('scan returns a set of assets', () async {
      final assetScanner = AssetScanner(tempDir.path);
      final assets = await assetScanner.scan();
      expect(assets.contains('assets/images/photo.png'), true);
    });
  });

  group('ReferenceScanner', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('flutter_project_');
      final libDir = Directory('${tempDir.path}/lib')..createSync(recursive: true);
      final dartFile = File('${libDir.path}/unused_assets_removal.dart');
      await dartFile.writeAsString('''
        import 'package:flutter/widgets.dart';
        void main() {
          var image = Image.asset('assets/images/photo.png');
        }
      ''');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('scan returns a set of used assets', () async {
      final referenceScanner = ReferenceScanner(tempDir.path);
      final usedAssets = await referenceScanner.scan();

      expect(usedAssets.contains('assets/images/photo.png'), true);
    });
  });

  group('AssetReporter', () {
    test('report prints unused assets', () {
      final unusedAssets = <String>{'assets/images/photo.png'};
      final reporter = AssetReporter('test_project_path');

      reporter.report(unusedAssets);
    });
  });
}
