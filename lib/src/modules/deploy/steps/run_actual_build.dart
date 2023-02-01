import 'dart:io';

import 'package:packo/packo.dart';

class StepRunActualBuild extends BaseBuildStep {
  final String? customOutputPath;

  StepRunActualBuild({
    this.customOutputPath,
  });

  @override
  FutureOr<BuildTransaction> handle(BuildTransaction data) async {
    final dartDefineString = data.env.map((e) => e.dartDefine).join(' ');
    final cmd =
        'build ${data.platform.name} --${data.type.name} $dartDefineString'
            .trim();

    final shell = FlutterShell(
      workingDirectory: data.directory,
    )..open();
    shell.eventStream.listen(print);

    await shell.run(cmd);

    if (customOutputPath != null) {
      await _copyBuildToCustomOutput(
        customOutputPath,
        data.type,
        shell,
      );
    }

    shell.close();
    return super.handle(data);
  }

  Future<void> _copyBuildToCustomOutput(
    String? outputDirPath,
    BuildType type,
    FlutterShell shell,
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
      }

      final outputDir = Directory(outputDirPath);
      if (outputDir.existsSync()) {
        await shell.runWithoutFlutter(
          'cp',
          '-a build/app/outputs/apk/$outputEndpoint ${outputDir.path}',
        );
      }
    }
  }
}
