import 'package:args/command_runner.dart';
import 'package:packo/packo.dart';

import '_helper.dart';

class StartPubGetCommand extends Command {
  @override
  final String name = 'pubget';
  @override
  final String description = 'Pub get';

  final Entrypoint entrypoint;

  StartPubGetCommand(this.entrypoint) {
    argParser
      ..addOption(
        'get',
        abbr: 'g',
        help: 'Run pub get for package',
      )
      ..addFlag(
        'get-recursive',
        abbr: 'r',
        help: 'Run pub get for all packages',
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

    if (args.wasParsed('get')) {
      final name = args.arguments[1];
      await helper.prepareSingle(
        name: name,
        pubget: true,
        buildRunner: false,
      );
    } else if (args.wasParsed('get-recursive')) {
      await helper.prepareRecursive(
        pubget: true,
        buildRunner: false,
      );
    } else {
      printUsage();
    }
  }
}
