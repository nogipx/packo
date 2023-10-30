import 'dart:developer';
import 'dart:io';

import 'package:packo/packo.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

abstract class PackageProvider {
  static Package? of(Directory directory) {
    try {
      final pubspec = _pubspec(directory);
      if (pubspec != null) {
        return Package(
          directory: directory,
          name: pubspec.name,
          pubspec: pubspec,
          currentVersion: pubspec.version ?? Version(0, 0, 0),
          originalVersion: pubspec.version ?? Version(0, 0, 0),
        );
      } else {
        return null;
      }
    } on Object catch (e) {
      log('Cannot recognize package at "${directory.path}"');
      return null;
    }
  }

  static void savePackage(Package package) {
    final pubspecFile = _getPubspecFile(package.directory);
    if (pubspecFile == null) {
      throw Exception(
        'Cannot save package "${package.name}". '
        'Pubspec not found.',
      );
    }

    var content = pubspecFile.readAsStringSync();
    content = content.replaceFirst(
      'version: ${package.originalVersion}',
      'version: ${package.currentVersion}',
    );

    pubspecFile.writeAsStringSync(content);
  }

  static Pubspec? _pubspec(Directory directory) {
    final file = _getPubspecFile(directory);
    if (file != null) {
      final content = file.readAsStringSync();
      final pubspec = Pubspec.parse(content);
      return pubspec;
    } else {
      return null;
    }
  }

  static File? _getPubspecFile(Directory directory) {
    final file = File('${directory.path}/pubspec.yaml');
    if (file.existsSync()) {
      return file;
    } else {
      final shortFile = File('${directory.path}/pubspec.yml');
      if (shortFile.existsSync()) {
        return shortFile;
      }
    }
    return null;
  }
}
