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
        'buildRecursive',
        abbr: 'r',
        help: 'Run build runner for all packages',
      );
  }

  @override
  Future<void> run() async {
    final args = argResults!;
    final collection = entrypoint.getPackages();

    if (args.wasParsed('build')) {
      final name = args.arguments[1];
      final package = collection.find(name: name);
      if (package != null) {
        await entrypoint.startBuildRunner(package);
      }
    }
    if (args.wasParsed('buildRecursive')) {
      for (final package in collection.packages) {
        await entrypoint.startBuildRunner(package);
      }

      final current = entrypoint.currentPackage;
      if (current != null) {
        await entrypoint.startBuildRunner(current);
      }
    }
  }
}
