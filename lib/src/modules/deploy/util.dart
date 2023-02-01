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
}
