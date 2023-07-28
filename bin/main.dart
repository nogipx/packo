import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:packo/packo.dart';

import 'commands/_index.dart';

Future<void> main(List<String> arguments) async {
  final entrypoint = Entrypoint(Directory.current);

  final runner = CommandRunner<dynamic>('packo', 'Sync all packages')
    ..addCommand(IncrementVersionsCommand(entrypoint))
    ..addCommand(StartBuildRunnerCommand(entrypoint))
    ..addCommand(BuildAppCommand());

  try {
    await runner.run(arguments).catchError((error) {});
  } on Exception catch (e) {
    if (e is! UsageException) rethrow;
    print(e);
    exit(64); // Exit code 64 indicates a usage error.
  }
}
