import 'dart:io';
import 'package:args/args.dart';

void runCleaner(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('dry-run', abbr: 'd', negatable: false, help: 'List unused assets without deleting.')
    ..addFlag('delete', abbr: 'x', negatable: false, help: 'Delete unused assets after confirmation.')
    ..addOption('assets-path', defaultsTo: 'assets', help: 'Path to assets folder.')
    ..addOption('log-path', defaultsTo: 'unused_assets_log.txt', help: 'File to save log report.');

  final argResults = parser.parse(arguments);

  final isDryRun = argResults['dry-run'] as bool;
  final isDelete = argResults['delete'] as bool;
  final assetsPath = argResults['assets-path'] as String;
  final logPath = argResults['log-path'] as String;

  await cleanUnusedAssets(
    assetsPath: assetsPath,
    dryRun: isDryRun,
    deleteFiles: isDelete,
    logPath: logPath,
  );
}

Future<void> cleanUnusedAssets({
  required String assetsPath,
  required bool dryRun,
  required bool deleteFiles,
  required String logPath,
}) async {
  final assetsDir = Directory(assetsPath);

  if (!assetsDir.existsSync()) {
    print('❌ Assets directory "$assetsPath" not found.');
    return;
  }

  final assetFiles = assetsDir
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .toList();

  if (assetFiles.isEmpty) {
    print('✅ No asset files found in "$assetsPath".');
    return;
  }

  final projectFiles = Directory('.')
      .listSync(recursive: true)
      .where((entity) =>
  entity is File &&
      (entity.path.endsWith('.dart') || entity.path.endsWith('.yaml')))
      .cast<File>()
      .toList();

  final usedAssets = <String>{};

  for (var projectFile in projectFiles) {
    final content = await projectFile.readAsString();

    for (var asset in assetFiles) {
      final assetRelativePath = asset.path.replaceAll('\\', '/');
      final fileName = assetRelativePath.split('/').skipWhile((e) => e != assetsPath).join('/');

      final regex = RegExp(
        RegExp.escape(fileName),
        caseSensitive: false,
      );

      if (regex.hasMatch(content)) {
        usedAssets.add(assetRelativePath);
      }
    }
  }

  final unusedAssets = assetFiles.where((file) {
    final path = file.path.replaceAll('\\', '/');
    return !usedAssets.contains(path);
  }).toList();

  if (unusedAssets.isEmpty) {
    print('✅ No unused assets found.');
    return;
  }

  final logFile = File(logPath);
  final sink = logFile.openWrite();

  print('📋 Unused Assets (${unusedAssets.length}):');
  for (var asset in unusedAssets) {
    print(' - ${asset.path}');
    sink.writeln(asset.path);
  }

  sink.close();

  if (dryRun) {
    print('\n🔎 Dry run completed. No files were deleted.');
    print('📄 Log saved to: $logPath');
    return;
  }

  if (deleteFiles) {
    stdout.write('\n❓ Are you sure you want to delete these files? (y/n): ');
    final input = stdin.readLineSync();

    if (input?.toLowerCase() != 'y') {
      print('❌ Deletion cancelled.');
      return;
    }

    int deletedCount = 0;

    for (var asset in unusedAssets) {
      try {
        asset.deleteSync();
        print('🗑️ Deleted: ${asset.path}');
        deletedCount++;
      } catch (e) {
        print('⚠️ Failed to delete ${asset.path}: $e');
      }
    }

    print('\n🎯 Done! Deleted $deletedCount unused assets.');
    print('📄 Deletion log saved to: $logPath');
  } else {
    print('\n⚡ To delete these files, rerun with --delete flag.');
  }
}
