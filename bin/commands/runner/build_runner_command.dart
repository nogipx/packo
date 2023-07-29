import 'package:args/command_runner.dart';
import 'package:packo/packo.dart';

import '_helper.dart';

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
    final helper = PackagesHelper(
      entrypoint: entrypoint,
      packages: entrypoint.getPackages(),
      flutterExec: entrypoint.useFvm ? 'fvm flutter' : 'flutter',
    );

    if (args.wasParsed('build')) {
      final name = args.arguments[1];
      await helper.prepareSingle(
        name: name,
        pubget: true,
        buildRunner: true,
      );
    } else if (args.wasParsed('build-recursive')) {
      await helper.prepareRecursive(
        pubget: true,
        buildRunner: true,
      );
    } else {
      printUsage();
    }
  }
}
