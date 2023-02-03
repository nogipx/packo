import 'package:cli_util/cli_logging.dart';
import 'package:packo/packo.dart';

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
    listener: ConsolePrinterStepListener(
      Logger.verbose(
        ansi: Ansi(true),
      ),
    ),
  );
}
