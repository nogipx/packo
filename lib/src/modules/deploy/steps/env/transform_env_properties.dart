import 'package:packo/packo.dart';

typedef EnvPropertiesTransformer = Map<String, EnvProperty> Function(
  Map<String, EnvProperty>,
);

class StepTransformEnvProperties
    with VerboseStep
    implements BuildStep<BuildTransaction> {
  /// Allows to transform env properties.
  ///
  /// Has higher priority over [overrides] (applies after).
  final EnvPropertiesTransformer? transformer;

  /// Allows to override env properties.
  ///
  /// Has lower priority over [transformer] (applies before)
  final Map<String, EnvProperty> overrides;

  StepTransformEnvProperties({
    this.transformer,
    this.overrides = const {},
  });

  @override
  FutureOr<BuildTransaction> handle(BuildTransaction data) {
    final currentEnv = DeployUtils.fastMapProperties(data.env);

    final overriddenEnv = currentEnv..addAll(overrides);

    final transformedEnv =
        transformer == null ? overriddenEnv : transformer!(overriddenEnv);

    data.env.clear();
    data.env.addAll(transformedEnv.values);

    return data;
  }
}
