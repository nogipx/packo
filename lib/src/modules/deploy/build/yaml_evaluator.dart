import 'package:expressions/expressions.dart';
import 'package:intl/intl.dart';

class YamlEvaluator extends ExpressionEvaluator {
  final Map<String, String?> env;

  const YamlEvaluator({
    this.env = const {},
    super.memberAccessors = const [],
  });

  @override
  dynamic evalMemberExpression(
    MemberExpression expression,
    Map<String, dynamic> context,
  ) {
    final variable = expression.toString();

    if (variable.startsWith('env.')) {
      final envCommand = variable.replaceFirst('env.', '').split('.');
      if (envCommand.isEmpty) {
        throw Exception('Invalid interpolation: $variable');
      }

      final envKey = envCommand.last;

      var prefix = '';

      if (envCommand.contains('dot')) {
        prefix = '.';
      }

      return env.containsKey(envKey) ? '$prefix${env[envKey]}' : '';
    }

    if (variable.startsWith('datetime.')) {
      final dtVariable = variable.replaceFirst('datetime.', '');
      if (dtVariable == 'nowFull') {
        final date = DateFormat('yyyy.MM.dd-HH.mm').format(DateTime.now());
        return date;
      }
    }

    return super.evalMemberExpression(expression, context);
  }
}
