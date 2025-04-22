import 'dart:io';

class ReferenceScanner {
  final String projectPath;

  ReferenceScanner(this.projectPath);

  Future<Set<String>> scan() async {
    final usedAssets = <String>{};
    final files = Directory('$projectPath/lib')
        .listSync(recursive: true, followLinks: false);
    for (var file in files) {
      if (file is File && file.path.endsWith('.dart')) {
        final content = await file.readAsString();
        final regex = RegExp(
            r'''["'](assets\/[^\s"'()]+?\.(?:jpg|jpeg|png|gif|svg|json|mp4|webp))["']''');
        final matches = regex.allMatches(content);
        for (var match in matches) {
          usedAssets.add(match.group(1)!);
        }
      }
    }
    return usedAssets;
  }
}
