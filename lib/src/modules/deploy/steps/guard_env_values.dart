import 'package:packo/packo.dart';

class StepGuardEnvProperties extends BaseBuildStep {
  final Set<EnvProperty> requiredProperties;

  StepGuardEnvProperties({
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
      return super.handle(data);
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
