enum BuildPlatform {
  undefined,
  appbundle,
  apk,
  ipa;

  static BuildPlatform parse(String? name) => BuildPlatform.values.firstWhere(
        (e) => e.name == name,
        orElse: () => BuildPlatform.undefined,
      );
}

enum BuildType {
  undefined,
  debug,
  profile,
  release;

  static BuildType parse(String? name) => BuildType.values.firstWhere(
        (e) => e.name == name,
        orElse: () => BuildType.undefined,
      );
}
