
class AssetReporter {
  final String projectPath;

  AssetReporter(this.projectPath);

  void report(Set<String> unusedAssets) {
    if (unusedAssets.isEmpty) {
      print('No unused assets found.');
    } else {
      print('Unused assets:');
      for (var asset in unusedAssets) {
        print(asset);
      }
    }
  }
}
