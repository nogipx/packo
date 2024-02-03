import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:packo/packo.dart';

enum ExitCode {
  ok,
  invalidOption,
  noRootDirectorySpecified,
  buildModelFailed,
  writeToFileFailed,
  dependencyCycleDetected
}

const _outputDefault = 'STDOUT';

class DepsAnalyzeCommand extends Command {
  @override
  final String name = 'deps';
  @override
  final String description = 'Analyze dependencies.';

  final Entrypoint entrypoint;

  DepsAnalyzeCommand(this.entrypoint) {
    argParser
      ..addOption(
        'format',
        abbr: 'f',
        help: 'Output format.',
        valueHelp: 'FORMAT',
        allowed: ['dot', 'json'],
        defaultsTo: 'dot',
      )
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Save output to a file instead of printing it.',
        valueHelp: 'FILE',
        defaultsTo: _outputDefault,
      )
      ..addFlag(
        'tree',
        help: 'Show directory structure as subgraphs.',
        defaultsTo: true,
      )
      ..addFlag(
        'metrics',
        abbr: 'm',
        help: 'Compute and show global metrics.\n(defaults to --no-metrics)',
      )
      ..addFlag(
        'node-metrics',
        help:
            'Show node metrics. Only works when --metrics is true.\n(defaults to --no-node-metrics)',
      )
      ..addOption(
        'ignore',
        abbr: 'i',
        help: 'Exclude files and directories with a glob pattern.',
        valueHelp: 'GLOB',
        defaultsTo: '!**',
      )
      ..addFlag(
        'cycles-allowed',
        help:
            'With --no-cycles-allowed lakos runs normally\nbut exits with a non-zero exit code\nif a dependency cycle is detected.\nUseful for CI builds.\n(defaults to --no-cycles-allowed)',
      );
  }

  @override
  Future<void> run() async {
    // Parse args.
    final argResults = this.argResults!;

    // Get options.
    final rootDir = entrypoint.workdir;
    final format = argResults['format'] as String?;
    final output = argResults['output'] as String?;
    final tree = argResults['tree'] as bool;
    final metrics = argResults['metrics'] as bool;
    final nodeMetrics = argResults['node-metrics'] as bool;
    final ignore = argResults['ignore'] as String;
    final cyclesAllowed = argResults['cycles-allowed'] as bool?;

    // Build model.
    late Model model;
    try {
      model = buildModel(
        rootDir,
        ignoreGlob: ignore,
        showTree: tree,
        showMetrics: metrics,
        showNodeMetrics: nodeMetrics,
      );
    } on Object catch (e) {
      print(e);
      exit(ExitCode.buildModelFailed.index);
    }

    // Write output to STDOUT or a file.
    var contents = '';
    switch (format) {
      case 'dot':
        contents = model.getOutput(OutputFormat.dot);
        break;
      case 'json':
        contents = model.getOutput(OutputFormat.json);
        break;
    }

    if (output == _outputDefault) {
      print(contents);
    } else {
      try {
        if (!File(output!).parent.existsSync()) {
          File(output).parent.createSync(recursive: true);
        }
        File(output).writeAsStringSync(contents);
      } on Object catch (e) {
        print(e);
        exit(ExitCode.writeToFileFailed.index);
      }
    }

    // Detect cycles.
    if (!cyclesAllowed! && !model.toDirectedGraph().isAcyclic) {
      exit(ExitCode.dependencyCycleDetected.index);
    }
  }
}
