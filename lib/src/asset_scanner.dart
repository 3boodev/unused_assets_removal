import 'dart:io';

class AssetScanner {
  final String projectPath;

  AssetScanner(this.projectPath);

  Future<Set<String>> scan() async {
    final assets = <String>{};
    final assetDir = Directory('$projectPath/assets');
    await for (var file in assetDir.list(recursive: true, followLinks: false)) {
      if (file is File) {
        assets.add(file.path.replaceFirst('$projectPath/', ''));
      }
    }
    return assets;
  }
}
