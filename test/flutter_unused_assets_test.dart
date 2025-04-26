import 'dart:io';
import 'package:test/test.dart';
import 'package:unused_assets_removal/unused_assets_remover.dart';

void main() {
  late Directory tempDir;
  late Directory assetsDir;
  late File usedAsset;
  late File unusedAsset;
  late File dartFile;

  setUp(() async {
    // Create temporary test project
    tempDir = Directory.systemTemp.createTempSync('test_project_');

    // Create assets directory
    assetsDir = Directory('${tempDir.path}/assets');
    assetsDir.createSync(recursive: true);

    // Create used asset file
    usedAsset = File('${assetsDir.path}/used.png')..writeAsBytesSync([0, 1, 2]);

    // Create unused asset file
    unusedAsset = File('${assetsDir.path}/unused.png')..writeAsBytesSync([3, 4, 5]);

    // Create Dart file that uses one asset
    dartFile = File('${tempDir.path}/lib/main.dart');
    dartFile.createSync(recursive: true);
    dartFile.writeAsStringSync('''
    import 'package:flutter/material.dart';
    final image = AssetImage('assets/used.png');
    ''');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  test('Dry run lists unused assets without deleting', () async {
    final logFile = File('${tempDir.path}/dry_run_log.txt');

    await cleanUnusedAssets(
      assetsPath: assetsDir.path,
      dryRun: true,
      deleteFiles: false,
      logPath: logFile.path,
    );

    expect(unusedAsset.existsSync(), isTrue);
    expect(usedAsset.existsSync(), isTrue);
    expect(logFile.existsSync(), isTrue);

    final logContent = logFile.readAsStringSync();
    expect(logContent.contains('unused.png'), isTrue);
    expect(logContent.contains('used.png'), isFalse);
  });

  test('Delete mode removes unused assets after confirmation', () async {
    // Simulate delete without asking user (skip stdin for testing)
    await cleanUnusedAssets(
      assetsPath: assetsDir.path,
      dryRun: false,
      deleteFiles: true,
      logPath: '${tempDir.path}/delete_log.txt',
    );

    // The unused file should be deleted
    expect(unusedAsset.existsSync(), isFalse);

    // The used file should still exist
    expect(usedAsset.existsSync(), isTrue);
  });
}
