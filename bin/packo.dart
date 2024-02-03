// ignore_for_file: avoid_types_on_closure_parameters

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:packo/packo.dart';

import 'commands/_index.dart';

Future<void> main(List<String> arguments) async {
  final dir = Directory.current;
  var entrypoint = Entrypoint(dir);

  final targetArguments = List.of(arguments);
  if (targetArguments.isNotEmpty && targetArguments.first == '-fvm') {
    entrypoint = Entrypoint(dir, useFvm: true);
    targetArguments.removeAt(0);
  }

  final runner = CommandRunner<dynamic>('packo', 'Sync all packages')
    ..addCommand(IncrementVersionsCommand(entrypoint))
    ..addCommand(StartBuildRunnerCommand(entrypoint))
    ..addCommand(StartPubGetCommand(entrypoint))
    ..addCommand(HelpersCommand(entrypoint))
    ..addCommand(DepsAnalyzeCommand(entrypoint))
    ..addCommand(BuildAppCommand());

  await runner.run(targetArguments).catchError((Object error) {
    if (error is! UsageException) {
      // ignore: only_throw_errors
      throw error;
    }
    print(error);
    exit(64);
  });
}
