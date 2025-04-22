import 'dart:io';
import 'package:args/args.dart';
import 'package:unused_assets_removal/src/asset_reporter.dart';
import 'package:unused_assets_removal/src/asset_scanner.dart';
import 'package:unused_assets_removal/src/reference_scanner.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('path', abbr: 'p', help: 'Path to Flutter project root')
    ..addFlag('delete', abbr: 'd', help: 'Delete unused assets', defaultsTo: false)
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help');

  final argResults = parser.parse(arguments);

  if (argResults['help'] as bool || !argResults.wasParsed('path')) {
    print('Detect unused Flutter assets\n');
    print(parser.usage);
    exit(0);
  }

  final projectPath = argResults['path'] as String;
  final shouldDelete = argResults['delete'] as bool;

  final assetScanner = AssetScanner(projectPath);
  final referenceScanner = ReferenceScanner(projectPath);

  final allAssets = await assetScanner.scan();
  final usedAssets = await referenceScanner.scan();

  final unusedAssets = allAssets.difference(usedAssets);

  final reporter = AssetReporter(projectPath);
  reporter.report(unusedAssets);

  if (shouldDelete && unusedAssets.isNotEmpty) {
    print("\nDeleting unused assets...\n");
    for (final asset in unusedAssets) {
      final file = File(asset);
      if (await file.exists()) {
        await file.delete();
        print('Deleted: \$asset');
      }
    }
  }
}
