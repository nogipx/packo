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
}
