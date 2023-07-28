import 'package:packo/packo.dart';

class StepGuardEnvProperties
    with VerboseStep
    implements BuildStep<BuildTransaction> {
  final Set<EnvProperty> requiredProperties;

  @override
  String get description =>
      'Filling properties with default values and adding missing properties.';

  const StepGuardEnvProperties({
    this.requiredProperties = const {},
  });

  @override
  FutureOr<BuildTransaction> handle(BuildTransaction data) {
    final wrongProps =
        _checkWrongProperties(DeployUtils.fastMapProperties(data.env));

    if (wrongProps.isNotEmpty) {
      final propsKeys = wrongProps.map((e) => e.key).join(', ');

      throw Exception('Missing required properties: $propsKeys');
    } else {
      return data;
    }
  }

  Iterable<EnvProperty> _checkWrongProperties(
    Map<String, EnvProperty> targetPropsMap,
  ) {
    return requiredProperties.where((property) {
      final targetProperty = targetPropsMap[property.key];

      if (property.required && targetProperty?.value == null) {
        return true;
      }
      return false;
    });
  }
}
