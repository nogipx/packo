import 'dart:io';

import 'package:packo/packo.dart';
import 'package:process_run/shell.dart';

class StepRunActualBuild
    with VerboseStep
    implements BuildStep<BuildTransaction> {
  const StepRunActualBuild();

  @override
  FutureOr<BuildTransaction> handle(BuildTransaction data) async {
    final dartDefineString = data.env.map((e) => e.dartDefine).join(' ');
    final cmdBuffer = StringBuffer()
      ..write('build ${data.settings.platform.name} ')
      ..write('--${data.settings.type.name} $dartDefineString');

    final args = cmdBuffer.toString().trim();

    final controller = ShellLinesController();

    final shell = Shell(
      workingDirectory: data.settings.directory.path,
      stdout: controller.sink,
    );

    final cmd = '${data.settings.flutterExecutable} $args';

    await shell.run(cmd);
    shell.kill(ProcessSignal.sigquit);
    return data;
  }
}
