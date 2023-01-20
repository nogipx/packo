import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:packo/packo.dart';

import 'commands/runner/build_runner_command.dart';
import 'commands/sync/increment_command.dart';
import 'commands/sync/sync_command.dart';

Future<void> main(List<String> arguments) async {
  final entrypoint = Entrypoint(Directory.current);
  //
  // if (await entrypoint.containsPubspec()) {
  //   print('Current directory contains pubspec. Go to parent directory.');
  //   exit(64);
  // }

  final runner = CommandRunner<dynamic>('packo', 'Sync all packages')
    ..addCommand(VersioningPackagesCommand(
      entrypoint,
      onSync: (package) {
        entrypoint.updateReadmeCoreVersion(
            package: package, version: package.version);
      },
    ))
    ..addCommand(IncrementVersionsCommand(entrypoint))
    ..addCommand(StartBuildRunnerCommand(entrypoint));

  await runner.run(arguments).catchError((Object error) {
    if (error is! UsageException) throw error;
    print(error);
    exit(64); // Exit code 64 indicates a usage error.
  });
}
