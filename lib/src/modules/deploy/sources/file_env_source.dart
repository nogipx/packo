// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:packo/packo.dart';

class FileEnvPropertySource implements EnvPropertySource {
  final String envFilePath;

  FileEnvPropertySource({
    required this.envFilePath,
  });

  @override
  FutureOr<Iterable<EnvProperty>> loadProperties() {
    _guardEnvFileAvailable(envFilePath);

    Iterable<EnvProperty> result = {};

    try {
      _guardEnvFileAvailable(envFilePath);
      final props = _loadPropertiesFromEnv(envFilePath);
      result = props;
    } on Exception catch (_) {
      result = {};
    }

    return result;
  }

  void _guardEnvFileAvailable(String envFile) {
    if (!File(envFile).existsSync()) {
      throw Exception('Cannot read file from path: $envFile');
    }
  }

  Iterable<EnvProperty> _loadPropertiesFromEnv(
    String envFilePath, {
    bool includePlatformEnvironment = false,
  }) {
    final env = DotEnv(
      includePlatformEnvironment: includePlatformEnvironment,
    )..load([envFilePath]);

    final map = env.map;
    final envProperties = map.keys.map(
      (key) => EnvProperty(key, value: map[key]),
    );
    return envProperties;
  }
}
