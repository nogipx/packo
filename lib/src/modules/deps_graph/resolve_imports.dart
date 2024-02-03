import 'dart:io';
import 'package:path/path.dart';

/// Resolve one file relative to another.
File resolveFile(File thisDartFile, String relativeFile) {
  final thisDartFileUri = Uri.file(thisDartFile.path);
  final resolvedUri = thisDartFileUri.resolve(relativeFile);
  final fileFromUri = File.fromUri(resolvedUri);
  final fileFromUriForwardSlashes =
      File(fileFromUri.path.replaceAll('\\', '/'));
  return fileFromUriForwardSlashes;
}

/// Searches up the directory tree until it finds the pubspec.yaml file.
/// Returns null if pubspec.yaml is not found.
File? findPubspecYaml(Directory currentDir) {
  if (!currentDir.isAbsolute) {
    currentDir = Directory(normalize(currentDir.absolute.path));
  }
  final rootDir = split(currentDir.path).first;
  while (currentDir.path != rootDir) {
    final currentDirItems =
        currentDir.listSync(recursive: false, followLinks: false);
    final pubspecYaml = currentDirItems
        .whereType<File>()
        .where((file) => basename(file.path).toLowerCase() == 'pubspec.yaml');
    if (pubspecYaml.length == 1) {
      return pubspecYaml.first;
    } else {
      currentDir = currentDir.parent;
    }
  }
  return null;
}

/// Convert to a relative file in lib directory, then resolve from pubspec.yaml.
File resolvePackageFileFromPubspecYaml(File pubspecYaml, String packageFile) {
  packageFile = packageFile.replaceFirst('package:', '');
  final packageFilePathParts = split(packageFile);
  packageFilePathParts[0] = 'lib'; // Replace package name with lib
  packageFile = joinAll(packageFilePathParts).replaceAll('\\', '/');
  return resolveFile(pubspecYaml, packageFile);
}
