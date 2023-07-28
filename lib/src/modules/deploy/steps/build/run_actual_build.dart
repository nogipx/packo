import 'package:packo/packo.dart';

class StepRunActualBuild
    with VerboseStep
    implements BuildStep<BuildTransaction> {
  StepRunActualBuild();

  @override
  FutureOr<BuildTransaction> handle(BuildTransaction data) async {
    final dartDefineString = data.env.map((e) => e.dartDefine).join(' ');
    final cmdBuffer = StringBuffer()
      ..write('build ${data.settings.platform.name} ')
      ..write('--${data.settings.type.name} $dartDefineString');

    final cmd = cmdBuffer.toString().trim();

    final shell = FlutterShell(
      workingDirectory: data.settings.directory,
      executable: data.settings.flutterExecutable,
    )..open();
    shell.eventStream.listen(print);

    await shell.run(cmd);
    await shell.close();
    return data;
  }
}
