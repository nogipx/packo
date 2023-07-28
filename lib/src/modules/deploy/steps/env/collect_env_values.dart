import 'package:packo/packo.dart';

class StepCollectEnvProperties
    with VerboseStep
    implements BuildStep<BuildTransaction> {
  final Iterable<EnvPropertySource> sources;

  const StepCollectEnvProperties({
    this.sources = const {},
  });

  @override
  FutureOr<BuildTransaction> handle(BuildTransaction data) async {
    final loadedProps = <EnvProperty>[];
    for (final source in sources) {
      final env = await source.loadProperties();
      loadedProps.addAll(env);
    }
    _guardDuplicateEnvValues(loadedProps);

    for (final entry in data.settings.initialEnv.entries) {
      final prop = EnvProperty(entry.key, value: entry.value);
      loadedProps.add(prop);
    }

    data.env.addAll(loadedProps.toSet());

    return data;
  }

  void _guardDuplicateEnvValues(Iterable<EnvProperty> props) {
    final keys = <String, int>{};

    for (final prop in props) {
      final count = keys.putIfAbsent(prop.key, () => 0);
      keys[prop.key] = count + 1;
    }

    final duplicates = keys.entries.where((e) => e.value > 1);
    if (duplicates.isNotEmpty) {
      final duplicatesInfo =
          duplicates.map((e) => '${e.key}(${e.value})').join(',');
      final errorMsg = 'Found conflicting env properties: $duplicatesInfo';
      throw Exception(errorMsg);
    }
  }
}
