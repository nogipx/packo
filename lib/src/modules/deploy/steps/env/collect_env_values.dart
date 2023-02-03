import 'package:packo/packo.dart';

class StepCollectEnvProperties
    with VerboseStep
    implements BuildStep<BuildTransaction> {
  final Iterable<EnvPropertySource> sources;

  StepCollectEnvProperties({
    this.sources = const {},
  });

  @override
  FutureOr<BuildTransaction> handle(BuildTransaction data) async {
    final loadedProps = <EnvProperty>[];
    for (final source in sources) {
      final env = await source.loadProperties();
      loadedProps.addAll(env);
    }

    data.env.addAll(loadedProps.toSet());

    return data;
  }
}
