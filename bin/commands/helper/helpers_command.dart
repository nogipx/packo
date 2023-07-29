import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:packo/packo.dart';

class HelpersCommand extends Command {
  @override
  final String name = 'helpers';
  @override
  final String description = 'Helpers';

  final Entrypoint entrypoint;

  HelpersCommand(this.entrypoint) {
    argParser.addFlag(
      'current-version',
      help: 'Returns current package version.',
      negatable: false,
    );
  }

  @override
  Future<void> run() async {
    final args = argResults!;
    final collection = entrypoint.getPackages();
    final availablePackages = collection.packages.map((e) => e.name).toList();
    final argPackageName = args.arguments.elementAtOrNull(1);
    final targetPackageName = argPackageName ?? entrypoint.currentPackage?.name;

    if (targetPackageName == null) {
      throw UsageException(
        'Not specified target package.',
        'Specify package name or locate to dart/flutter directory',
      );
    }

    if (args.wasParsed('current-version')) {
      final package = collection.find(name: targetPackageName);
      if (package != null) {
        print(package.version.toString());
      } else {
        throw UsageException(
          'Package "$targetPackageName" not found.',
          'Available packages: $availablePackages',
        );
      }
    } else {
      printUsage();
    }
  }
}
