import 'package:packo/packo.dart';

class StepNormalizeEnvProperties
    with VerboseStep
    implements BuildStep<BuildTransaction> {
  final Set<EnvProperty> neededProperties;

  StepNormalizeEnvProperties({
    this.neededProperties = const {},
  });

  @override
  FutureOr<BuildTransaction> handle(BuildTransaction data) async {
    final fastMap = _fillWithDefaults(DeployUtils.fastMapProperties(data.env));
    data.env.clear();
    data.env.addAll(fastMap.values);
    return data;
  }

  Map<String, EnvProperty> _fillWithDefaults(
    Map<String, EnvProperty> data,
  ) {
    final neededFastMap = DeployUtils.fastMapProperties(neededProperties);
    final actualFastMap = data;

    /// Fill actual env properties with default values from required props.
    final filledExistedProps = actualFastMap.map((key, value) {
      final neededProperty = neededFastMap[key];

      if (neededProperty != null) {
        if (value.value == null && neededProperty.defaultValue != null) {
          return MapEntry(
            key,
            value.copyWith(value: neededProperty.defaultValue),
          );
        }
      }
      return MapEntry(key, value);
    });

    /// Create env properties that are in needed props with default value,
    /// but not contained in existed props.
    final neededPropsKeysNotInExisted = neededFastMap.values
        .where(
          (e) => !filledExistedProps.containsKey(e) && e.defaultValue != null,
        )
        .map(
          (e) => MapEntry(e.key, e.copyWith(value: e.defaultValue)),
        );

    final resultProps = {
      ...filledExistedProps,
      ...Map.fromEntries(neededPropsKeysNotInExisted)
    };

    return resultProps;
  }
}
