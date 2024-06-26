import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:packo/packo.dart';
import 'package:process_run/shell.dart';

class Entrypoint {
  final Directory _workdir;
  final bool useFvm;

  Directory get workdir => _workdir;

  Entrypoint(
    Directory? workdir, {
    this.useFvm = false,
  }) : _workdir = workdir ?? Directory.current;

  Iterable<Directory> getSubDirectories({
    bool recursive = true,
  }) {
    final featurePackagesPath = _workdir
        .listSync(recursive: recursive)
        .whereType<Directory>()
        .where((e) {
      final isDartTool = e.path.contains('.dart_tool');
      final isSdk = e.path.contains('flutter_sdk') ||
          e.path.contains('.symlinks') ||
          e.path.contains('.plugin_symlinks');
      final isFromFvm = e.path.contains('.fvm');
      final isHiddenDirectory = _lastPathSegment(e.uri).startsWith('.');

      return !isSdk && !isDartTool && !isHiddenDirectory && !isFromFvm;
    });

    return featurePackagesPath;
  }

  String _lastPathSegment(Uri data) {
    final segments = data.pathSegments;
    return data.pathSegments.length >= 2 ? segments[segments.length - 2] : '';
  }

  Package? get currentPackage {
    return PackageProvider.of(_workdir);
  }

  Future<bool> containsPubspec() async {
    final file = File('${_workdir.path}/pubspec.yaml');
    if (file.existsSync()) {
      return true;
    } else {
      final shortFile = File('${_workdir.path}/pubspec.yml');
      if (shortFile.existsSync()) {
        return true;
      }
      return false;
    }
  }

  PackagesCollection getPackages({
    bool recursive = true,
    bool withRootPackage = true,
  }) {
    final packagesDirs = getSubDirectories(recursive: recursive);
    final targetDirs = [
      ...packagesDirs,
      if (withRootPackage) workdir,
    ];
    final packages =
        targetDirs.map(PackageProvider.of).whereType<Package>().toList();
    final collection = PackagesCollection(
      packages: packages,
    );

    return collection;
  }

  void incrementMajor(Package package) {
    final updated = package.copyWith(
      version: package.currentVersion.nextMajor,
    );
    PackageProvider.savePackage(updated);
  }

  void incrementMinor(Package package) {
    final updated = package.copyWith(
      version: package.currentVersion.nextMinor,
    );
    PackageProvider.savePackage(updated);
  }

  void incrementPatch(Package package) {
    final updated = package.copyWith(
      version: package.currentVersion.nextPatch,
    );
    PackageProvider.savePackage(updated);
  }

  void incrementBuildNumber(Package package) {
    final nextBuildNumber = package.nextBuildNumber;
    if (nextBuildNumber == null) {
      throw UsageException(
        'Cannot increment build runner.',
        'Only integer build allowed.',
      );
    }
    final updated = package.copyWith(
      version: nextBuildNumber,
    );
    PackageProvider.savePackage(updated);
  }

  Future<void> startBuildRunner({
    required String flutterExecutable,
    required Package package,
  }) async {
    _guardEntrypointContainsPackage(package);

    if (!package.hasDependency('build_runner')) {
      print(
        'Skip "${package.name}" generation cause "build_runner" '
        'dependency not registered by this package.\n\n',
      );
      return;
    }

    final controller = ShellLinesController();
    final listen = controller.stream.listen(print);
    final dir = package.directory.path;

    final shell = Shell(
      workingDirectory: dir,
      stdout: controller.sink,
    );

    print('\n[${package.name}] build_runner started at directory "$dir"');

    await shell.run(
      '$flutterExecutable pub run build_runner build --delete-conflicting-outputs',
    );

    controller.close();
    await listen.cancel();
  }

  Future<void> startPubGet({
    required String flutterExecutable,
    required Package package,
  }) async {
    _guardEntrypointContainsPackage(package);

    final controller = ShellLinesController();
    final listen = controller.stream.listen(print);
    final dir = package.directory.path;

    final shell = Shell(
      workingDirectory: dir,
      stdout: controller.sink,
    );

    print('\n[${package.name}] pub get started at directory "$dir"');

    await shell.run(
      '$flutterExecutable pub get',
    );

    controller.close();
    await listen.cancel();
  }

  void _guardEntrypointContainsPackage(Package package) {
    final collection = getPackages();
    final availablePackages = collection.packages.join('\n');

    final found = collection.find(name: package.name);
    if (found == null) {
      throw UsageException(
        'Cannot perform action to package outbound current entrypoint',
        'Available packages: \n$availablePackages',
      );
    }
  }
}
