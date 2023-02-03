import 'package:packo/packo.dart';

class BuildTransaction {
  final BuildSettings settings;
  final Set<EnvProperty> env;

  const BuildTransaction({
    required this.settings,
    this.env = const {},
  });
}
