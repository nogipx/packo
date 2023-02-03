import 'package:expressions/expressions.dart';
import 'package:packo/packo.dart';

import '_index.dart';

typedef FastMapEnvProperty = Map<String, EnvProperty>;

abstract class DeployUtils {
  static FastMapEnvProperty fastMapProperties(Iterable<EnvProperty> props) {
    final targetPropsMap = <String, EnvProperty>{};
    for (final prop in props) {
      targetPropsMap[prop.key] = prop;
    }
    return targetPropsMap;
  }

  static FastMapEnvProperty fastPropertiesFromMap(Map<String, String> props) {
    final env = Map.fromEntries(props.entries.map(
      (e) => MapEntry(
        e.key,
        EnvProperty(
          e.key,
          value: e.value,
        ),
      ),
    ));

    return env;
  }

  static FastMapEnvProperty interpolateEnvValues(
    FastMapEnvProperty data,
    Map<String, String> initialEnv,
  ) {
    final context = data
        .map((key, value) => MapEntry(key, value.value ?? value.defaultValue))
      ..addAll(initialEnv);

    final interpolated = initialEnv.map((key, value) {
      final newValue = YamlEvaluator(env: context)
          .eval(
            Expression.parse(value),
            context,
          )
          .toString();

      context[key] = newValue;

      final newEntry = MapEntry(
        key,
        EnvProperty(key, value: newValue != 'null' ? newValue : value),
      );
      print('Expanded value: ${newEntry.value}');
      return newEntry;
    });

    return {
      ...data,
      ...interpolated,
    };
  }
}
