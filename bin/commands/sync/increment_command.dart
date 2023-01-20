import 'package:args/command_runner.dart';
import 'package:packo/packo.dart';

class IncrementVersionsCommand extends Command {
  @override
  final String name = 'increment';
  @override
  final String description = 'Increment versions to bunch of packages';

  final Entrypoint entrypoint;

  IncrementVersionsCommand(this.entrypoint) {
    argParser
      ..addFlag(
        'major',
        help: 'Increments major versions of all packages.',
        negatable: false,
      )
      ..addFlag(
        'minor',
        help: 'Increments minor versions of all packages.',
        negatable: false,
      )
      ..addFlag(
        'patch',
        help: 'Increments patch versions of all packages.',
        negatable: false,
      );
  }

  @override
  Future<void> run() async {
    final args = argResults!;

    if (args.wasParsed('major')) {
      await entrypoint.incrementAllMajor();
    } else if (args.wasParsed('minor')) {
      await entrypoint.incrementAllMinor();
    } else if (args.wasParsed('patch')) {
      await entrypoint.incrementAllPatch();
    }

    printUsage();
  }
}
