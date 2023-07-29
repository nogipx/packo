import 'package:args/command_runner.dart';
import 'package:packo/packo.dart';

class PackagesHelper {
  final Entrypoint entrypoint;
  final PackagesCollection packages;
  final String flutterExec;

  const PackagesHelper({
    required this.entrypoint,
    required this.packages,
    required this.flutterExec,
  });

  Future<void> prepareSingle({
    required String name,
    required bool pubget,
    required bool buildRunner,
  }) async {
    final package = packages.find(name: name);

    if (package != null) {
      if (pubget) {
        await entrypoint.startPubGet(
          package: package,
          flutterExecutable: flutterExec,
        );
      }

      if (buildRunner) {
        await entrypoint.startBuildRunner(
          package: package,
          flutterExecutable: flutterExec,
        );
      }
    } else {
      final allPackagesString = packages.packages.join('\n');
      final buildRunnerPackagesString =
          packages.filterByDependency('build_runner').join('\n');

      throw UsageException(
        'Package "$name" not found.',
        'Packages with "build_runner": \n$buildRunnerPackagesString}\n'
            'All packages: \n$allPackagesString\n',
      );
    }
  }

  Future<void> prepareRecursive({
    required bool pubget,
    required bool buildRunner,
  }) async {
    if (pubget) {
      final forPubGet = packages.packages;
      final pubGetString = forPubGet.join('\n');

      print('\n\nStart "pub get" for packages: \n$pubGetString');
      for (final package in forPubGet) {
        await entrypoint.startPubGet(
          package: package,
          flutterExecutable: flutterExec,
        );
      }
    }

    if (buildRunner) {
      final forBuildRunner = packages.filterByDependency('build_runner');
      final buildRunnerString = forBuildRunner.join('\n');
      print('\n\nStart "build_runner" for packages: \n$buildRunnerString');

      for (final package in forBuildRunner) {
        await entrypoint.startBuildRunner(
          package: package,
          flutterExecutable: flutterExec,
        );
      }
    }
  }
}
