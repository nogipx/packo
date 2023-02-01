enum BuildPlatform {
  appbundle,
  apk,
  ipa;

  static BuildPlatform fromName(String name) =>
      BuildPlatform.values.firstWhere((e) => e.name == name);
}

enum BuildType {
  debug,
  profile,
  release;

  static BuildType fromName(String name) =>
      BuildType.values.firstWhere((e) => e.name == name);
}
