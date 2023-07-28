import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:packo/packo.dart';

class IncrementVersionsCommand extends Command {
  @override
  final String name = 'increment';
  @override
  final String description = 'Increment version or build number of package';

  final Entrypoint entrypoint;

  IncrementVersionsCommand(this.entrypoint) {
    argParser
      ..addFlag(
        'major',
        help: 'Increments package major version.',
        negatable: false,
        aliases: ['major'],
      )
      ..addFlag(
        'minor',
        help: 'Increments package minor version.',
        negatable: false,
        aliases: ['minor'],
      )
      ..addFlag(
        'patch',
        help: 'Increments package patch version.',
        negatable: false,
        aliases: ['patch'],
      )
      ..addFlag(
        'build',
        help: 'Increments package build number.',
        negatable: false,
        aliases: ['build'],
      );
  }

  @override
  Future<void> run() async {
    const usageMessage = 'Specify particual package name as argument, '
        'or leave it empty to apply increment '
        'to package in current directory.';

    final args = argResults!;
    final collection = entrypoint.getPackages();
    final argPackageName = args.arguments.elementAtOrNull(1);
    final targetPackageName = argPackageName ?? entrypoint.currentPackage?.name;

    final availablePackages = collection.packages.map((e) => e.name).toList();

    if (targetPackageName == null) {
      throw UsageException(
        'Not specified target package. \n'
        'Available packages: $availablePackages',
        usageMessage,
      );
    }

    final targetPackage = collection.find(name: targetPackageName);

    if (targetPackage == null) {
      throw UsageException(
        'Package "$targetPackageName" not found. \n'
        'Available packages: $availablePackages',
        usageMessage,
      );
    }

    if (args.wasParsed('major')) {
      entrypoint.incrementMajor(targetPackage);
    } else if (args.wasParsed('minor')) {
      entrypoint.incrementMinor(targetPackage);
    } else if (args.wasParsed('patch')) {
      entrypoint.incrementPatch(targetPackage);
    } else if (args.wasParsed('build')) {
      entrypoint.incrementBuildNumber(targetPackage);
    } else {
      printUsage();
      return;
    }

    print('${targetPackage.name} version changed.');
  }
}
