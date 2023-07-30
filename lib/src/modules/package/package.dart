import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

class Package {
  const Package({
    required this.directory,
    required Pubspec pubspec,
    required this.name,
    required this.currentVersion,
    required this.originalVersion,
  }) : _pubspec = pubspec;

  final Directory directory;
  final String name;
  final Version originalVersion;
  final Version currentVersion;
  final Pubspec _pubspec;

  @override
  String toString() => '$name($currentVersion)';

  bool hasDependency(String name) {
    return hasProdDependency(name) || hasDevDependency(name);
  }

  bool hasProdDependency(String name) {
    final dep = name.replaceAll(':', '');
    return _pubspec.dependencies.containsKey(dep);
  }

  bool hasDevDependency(String name) {
    final dep = name.replaceAll(':', '');
    return _pubspec.devDependencies.containsKey(dep);
  }

  String get buildNumberString => currentVersion.build.join('.');

  int? get buildNumber {
    final formattedBuild = currentVersion.build.join('.');
    if (currentVersion.build.length > 1) {
      print('Build number is not int: "$formattedBuild"');
      return null;
    }

    final number = int.tryParse(currentVersion.build.first.toString());
    return number;
  }

  Version? get nextBuildNumber {
    final buildNumber = this.buildNumber;
    if (buildNumber == null) {
      print('Cannot increment build number format: "$buildNumberString"');
      return null;
    }

    final newVersion = Version(
      currentVersion.major,
      currentVersion.minor,
      currentVersion.patch,
      build: (buildNumber + 1).toString(),
    );
    return newVersion;
  }

  Package copyWith({
    Version? version,
  }) {
    return Package(
      directory: directory,
      name: name,
      currentVersion: version ?? currentVersion,
      pubspec: _pubspec,
      originalVersion: originalVersion,
    );
  }
}
