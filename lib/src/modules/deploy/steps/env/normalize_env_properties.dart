import 'package:expressions/expressions.dart';
import 'package:packo/packo.dart';

class StepNormalizeEnvProperties
    with VerboseStep
    implements BuildStep<BuildTransaction> {
  final Set<EnvProperty> neededProperties;
  final StringEvaluator? stringEvaluator;

  const StepNormalizeEnvProperties({
    this.neededProperties = const {},
    this.stringEvaluator,
  });

  @override
  FutureOr<BuildTransaction> handle(BuildTransaction data) async {
    final fastMap = _fillWithDefaults(DeployUtils.fastMapProperties(data.env));
    final result = _interpolateEnvValues(
      data: fastMap,
      buildSettings: data.settings,
      excludeKeys: {
        'APP_VERSION',
      },
    );

    data.env.clear();
    data.env.addAll(result.values);
    return data;
  }

  FastMapEnvProperty _fillWithDefaults(FastMapEnvProperty data) {
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
          (e) =>
              !filledExistedProps.containsKey(e.key) && e.defaultValue != null,
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

  FastMapEnvProperty _interpolateEnvValues({
    FastMapEnvProperty data = const {},
    BuildSettings? buildSettings,
    Iterable<String> excludeKeys = const {},
  }) {
    final context = data
        .map((key, value) => MapEntry(key, value.value ?? value.defaultValue));

    final interpolated = data.map((key, value) {
      final originalEntry = MapEntry(key, value);
      if (value.value == null || excludeKeys.contains(key)) {
        return originalEntry;
      }

      try {
        final expression = Expression.parse(value.value!);
        final evaluatedValue =
            YamlEvaluator(env: context, settings: buildSettings)
                .eval(expression, context)
                ?.toString();

        final newValue =
            evaluatedValue != 'null' ? evaluatedValue : value.value;

        final newProperty = value.copyWith(value: newValue);
        print('Expanded value: $newProperty');

        context[key] = newValue;

        final newEntry = MapEntry(key, newProperty);
        return newEntry;
      } on Exception catch (e, stackTrace) {
        print('Exception while interpolate property: $key');
        print(e);
        print(stackTrace);
        return originalEntry;
      }
    });

    return interpolated;
  }
}
