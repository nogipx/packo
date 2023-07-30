import 'package:packo/packo.dart';

class StepInjectSystemProperties implements BuildStep<BuildTransaction> {
  const StepInjectSystemProperties();

  @override
  FutureOr<BuildTransaction> handle(BuildTransaction data) {
    final package = PackageProvider.of(data.settings.directory);

    final systemProps = [
      EnvProperty('BUILD_TYPE', value: data.settings.type.name),
      EnvProperty('BUILD_PLATFORM', value: data.settings.platform.name),
      if (package != null)
        EnvProperty('APP_VERSION', value: package.currentVersion.toString()),
    ];

    data.env.addAll(systemProps);

    return data;
  }
}
