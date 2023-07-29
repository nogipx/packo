import 'package:args/command_runner.dart';
import 'package:packo/packo.dart';

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
        'getRecursive',
        abbr: 'r',
        help: 'Run pub get for all packages',
        negatable: false,
      );
  }

  @override
  Future<void> run() async {
    final args = argResults!;
    final collection = entrypoint.getPackages();
    final flutterExec = entrypoint.useFvm ? 'fvm flutter' : 'flutter';
    final availablePackages = collection.packages.map((e) => e.name).toList();

    if (args.wasParsed('get')) {
      final name = args.arguments[1];
      final package = collection.find(name: name);
      if (package != null) {
        await entrypoint.startPubGet(
          package: package,
          flutterExecutable: flutterExec,
        );
      } else {
        throw UsageException(
          'Package "$name" not found.',
          'Available packages: $availablePackages',
        );
      }
    } else if (args.wasParsed('getRecursive')) {
      print('Start pub get for packages: $availablePackages\n');

      for (final package in collection.packages) {
        await entrypoint.startPubGet(
          package: package,
          flutterExecutable: flutterExec,
        );
      }
    } else {
      printUsage();
    }
  }
}
