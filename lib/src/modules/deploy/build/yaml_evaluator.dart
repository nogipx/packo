import 'package:collection/collection.dart';
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
    _guardInterpolation(expression.toString());
    final cmd = expression.toString().split('.');

    if (cmd.first == 'env') {
      final envKey = cmd.last;
      final value = _prefixed(cmd, _getEnv(envKey));
      return value;
    }

    if (cmd.first == 'datetime') {
      final formats = {
        'nowFull': DateFormat('yyyy.MM.dd-HH.mm'),
      };

      final name = cmd.firstWhereOrNull(formats.keys.contains);
      final format = formats[name];

      if (format != null) {
        final date = format.format(DateTime.now());
        return _prefixed(cmd, date);
      }
    }

    return super.evalMemberExpression(expression, context);
  }

  String _prefixed(List<String> cmd, String value) {
    final prefix = _getPrefix(cmd);
    return '$prefix$value';
  }

  String _getPrefix(List<String> cmd) {
    const prefixes = {
      'dot': '.',
      'dash': '-',
      'us': '_',
    };
    final names = prefixes.keys;

    final name = cmd.firstWhereOrNull(names.contains);

    return name != null ? prefixes[name] ?? '' : '';
  }

  String _getEnv(String envKey) => env[envKey] ?? '';

  void _guardInterpolation(String command) {
    if (command.split('.').isEmpty) {
      throw Exception('Invalid interpolation: $command');
    }
  }
}
