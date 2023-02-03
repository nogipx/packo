import 'package:cli_util/cli_logging.dart';
import 'package:packo/packo.dart';
import 'package:packo/src/modules/deploy/build_step_listener.dart';
import 'package:packo/src/modules/deploy/steps/build/move_artifacts.dart';

final listener = ConsolePrinterStepListener(
  Logger.verbose(
    ansi: Ansi(true),
  ),
);

Future<void> buildApp({
  required BuildSettings settings,
  EnvPropertiesTransformer? transformProperties,
}) async {
  final neededProperties = settings.neededEnvKeys.map((e) {
    return EnvProperty(
      e,
      defaultValue: settings.initialEnv[e],
    );
  }).toSet();

  final collectEnvStep = StepCollectEnvProperties(
    sources: {
      if (settings.envFilePath != null)
        FileEnvPropertySource(
          envFilePath: settings.envFilePath!,
        ),
    },
  );

  final transformEnvStep = StepTransformEnvProperties(
    transformer: transformProperties,
  );

  final normalizeEnvStep = StepNormalizeEnvProperties(
    neededProperties: neededProperties,
  );

  final guardEnvStep = StepGuardEnvProperties(
    requiredProperties: neededProperties,
  );

  final buildCompositor = BuildCompositor()
    ..setNext(collectEnvStep)
    ..setNext(normalizeEnvStep)
    ..setNext(transformEnvStep)
    ..setNext(guardEnvStep)
    ..setNext(StepRunActualBuild())
    ..setNext(StepMoveArtifacts());

  await buildCompositor.run(
    settings: settings,
    listener: listener,
  );
}
