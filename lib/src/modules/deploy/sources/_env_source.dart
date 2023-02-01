import '../_index.dart';

abstract class EnvPropertySource {
  FutureOr<Iterable<EnvProperty>> loadProperties();
}
