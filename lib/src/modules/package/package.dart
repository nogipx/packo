import 'dart:io';

import 'package:packo/packo.dart';

class Package {
  const Package._({
    required this.directory,
  });

  final Directory directory;

  @override
  String toString() => '$name: $version';

  static Package? of(Directory directory) {
    final pubspec = _getPubspec(directory);
    if (pubspec != null) {
      return Package._(directory: directory);
    } else {
      return null;
    }
  }

  String get name {
    final lines = pubspec.readAsLinesSync();
    final nameLine = lines.singleWhere(
      (e) => e.startsWith('name'),
      orElse: () => '',
    );
    if (nameLine.isNotEmpty) {
      final name = nameLine.split(':')[1].trim();
      return name;
    } else {
      return '';
    }
  }

  File get pubspec {
    final file = _getPubspec(directory);
    if (file != null) {
      return file;
    }
    throw Exception('pubspec not found at ${directory.path}.');
  }

  File get readme {
    final file = File('${directory.path}/README.md');
    if (file.existsSync()) {
      return file;
    }
    throw Exception('Readme of "$name" package not found.');
  }

  Version get version {
    final versionLine = pubspec.readAsLinesSync().singleWhere(
          (e) => e.startsWith('version:'),
          orElse: () => '',
        );
    if (versionLine.isNotEmpty) {
      final versionString = versionLine.split(':')[1].trim();
      final version = Version.parse(versionString);
      return version;
    }
    throw Exception('cannot find version');
  }

  bool containsDependency(String name) {
    final pubspec = this.pubspec;
    final text = pubspec.readAsStringSync();
    final result = text.contains(name);
    return result;
  }

  static File? _getPubspec(Directory directory) {
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
