import 'dart:io';

import 'package:packo/packo.dart';
import 'package:process_run/cmd_run.dart';

class StepMoveArtifacts
    with VerboseStep
    implements BuildStep<BuildTransaction> {
  StepMoveArtifacts();

  @override
  FutureOr<BuildTransaction> handle(BuildTransaction data) async {
    if (data.settings.outputDirPath != null) {
      await _copyBuildToCustomOutput(
        data.settings.directory.path,
        data.settings.outputDirPath,
        data.settings.type,
      );
    }
    return data;
  }

  Future<void> _copyBuildToCustomOutput(
    String projectDir,
    String? outputDirPath,
    BuildType type,
  ) async {
    if (outputDirPath != null) {
      late final String outputEndpoint;
      switch (type) {
        case BuildType.debug:
          outputEndpoint = '/debug';
          break;
        case BuildType.profile:
          outputEndpoint = '/profile';
          break;
        case BuildType.release:
          outputEndpoint = '/release';
          break;
        case BuildType.undefined:
          throw ArgumentError.value(type);
      }

      final outputDir = Directory(outputDirPath);
      if (!outputDir.existsSync()) {
        await outputDir.create(recursive: true);
      }

      print('\nOutput directory: ${outputDir.absolute.path}\n');
      final cmd = ProcessCmd(
        'cp',
        '-a $projectDir/build/app/outputs/apk/$outputEndpoint ${outputDir.path}'
            .split(' '),
      );
      await runCmd(cmd);
    }
  }
}
