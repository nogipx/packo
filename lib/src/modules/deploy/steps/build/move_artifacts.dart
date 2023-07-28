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
        data.settings.platform,
      );
    }
    return data;
  }

  Future<void> _copyBuildToCustomOutput(
    String projectDir,
    String? outputDirPath,
    BuildType type,
    BuildPlatform platform,
  ) async {
    if (outputDirPath != null) {
      late final String typeDir;
      late final String platformDir;

      switch (type) {
        case BuildType.undefined:
          throw ArgumentError.value(type);
        case BuildType.debug:
          typeDir = '/debug';
          break;
        case BuildType.profile:
          typeDir = '/profile';
          break;
        case BuildType.release:
          typeDir = '/release';
          break;
      }

      switch (platform) {
        case BuildPlatform.undefined:
          throw ArgumentError.value(type);
        case BuildPlatform.appbundle:
          platformDir = 'bundle';
          break;
        case BuildPlatform.apk:
          platformDir = 'apk';
          break;
        case BuildPlatform.ipa:
          break;
      }

      final outputDir = Directory(outputDirPath);
      if (!outputDir.existsSync()) {
        await outputDir.create(recursive: true);
      }

      print('\nOutput directory: ${outputDir.absolute.path}\n');
      String? cpArgs;

      final isAndroid =
          [BuildPlatform.apk, BuildPlatform.appbundle].contains(platform);
      final isIos = [BuildPlatform.ipa].contains(platform);

      if (isAndroid) {
        cpArgs =
            '-a $projectDir/build/app/outputs/$platformDir/$typeDir ${outputDir.path}';
      } else if (isIos) {
        cpArgs = '-a $projectDir/build/ios/archive/* ${outputDir.path}';
      }

      if (cpArgs == null) {
        return;
      }

      final cmd = ProcessCmd(
        'cp',
        cpArgs.split(' '),
      );
      await runCmd(cmd);
    }
  }
}
