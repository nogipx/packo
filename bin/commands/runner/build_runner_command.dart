import 'package:args/command_runner.dart';
import 'package:packo/packo.dart';

class StartBuildRunnerCommand extends Command {
  @override
  final String name = 'runner';
  @override
  final String description = 'Build runner';

  final Entrypoint entrypoint;

  StartBuildRunnerCommand(this.entrypoint) {
    argParser
      ..addOption(
        'build',
        abbr: 'b',
        help: 'Run build runner for package',
      )
      ..addFlag(
        'build-recursive',
        abbr: 'r',
        help: 'Run build runner for all packages',
        negatable: false,
      );
  }

  @override
  Future<void> run() async {
    final args = argResults!;
    final collection = entrypoint.getPackages();
    final flutterExec = entrypoint.useFvm ? 'fvm flutter' : 'flutter';
    final availablePackages = collection.packages
        .where((e) => e.containsDependency('build_runner'))
        .map((e) => e.name)
        .toList();

    if (args.wasParsed('build')) {
      final name = args.arguments[1];
      final package = collection.find(name: name);
      if (package != null) {
        await entrypoint.startBuildRunner(
          package: package,
          flutterExecutable: flutterExec,
        );
      } else {
        throw UsageException(
          'Package "$name" not found.',
          'Available packages: $availablePackages',
        );
      }
    } else if (args.wasParsed('build-recursive')) {
      print('Start generating for packages: $availablePackages\n');

      for (final package in collection.packages) {
        await entrypoint.startBuildRunner(
          package: package,
          flutterExecutable: flutterExec,
        );
      }
    } else {
      printUsage();
    }
  }
}
