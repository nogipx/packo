import 'package:collection/collection.dart';

enum BuildPlatform {
  appbundle,
  apk,
  ipa;

  static BuildPlatform? parse(String? name) =>
      BuildPlatform.values.firstWhereOrNull((e) => e.name == name);
}

enum BuildType {
  debug,
  profile,
  release;

  static BuildType? parse(String? name) =>
      BuildType.values.firstWhereOrNull((e) => e.name == name);
}
