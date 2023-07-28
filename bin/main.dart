// ignore_for_file: avoid_types_on_closure_parameters

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

  await runner.run(arguments).catchError((Object error) {
    if (error is! UsageException) {
      // ignore: only_throw_errors
      throw error;
    }
    print(error);
    exit(64);
  });
}
