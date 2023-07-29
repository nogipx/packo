import 'package:expressions/expressions.dart';
import 'package:packo/packo.dart';

class YamlEvaluator extends ExpressionEvaluator {
  final BuildSettings? settings;
  final Map<String, String?> env;

  const YamlEvaluator({
    this.settings,
    this.env = const {},
    super.memberAccessors = const [],
  });

  @override
  dynamic evalCallExpression(
    CallExpression expression,
    Map<String, dynamic> context,
  ) {
    try {
      final t = super.evalCallExpression(expression, context);
      return t;
    }

    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      throw Exception(e.toString());
    }
  }

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
      final formats = <String, String Function(DateTime)>{
        'nowFull': (dt) {
          return '${dt.year}.${dt.month}.${dt.day}-${dt.hour}.${dt.minute}';
        },
      };

      final name = cmd.firstWhereOrNull(formats.keys.contains);
      final format = formats[name];

      if (format != null) {
        final date = format(DateTime.now());
        return _prefixed(cmd, date);
      }
      return;
    }

    if (cmd.first == 'build') {
      _guardBuildSettings();

      if (cmd[1] == 'isRelease') {
        return settings!.type == BuildType.release;
      } else if (cmd[1] == 'isProfile') {
        return settings!.type == BuildType.profile;
      } else if (cmd[1] == 'isDebug') {
        return settings!.type == BuildType.debug;
      } else if (cmd[1] == 'isNotRelease') {
        return settings!.type != BuildType.release;
      }
    }

    return super.evalMemberExpression(expression, context);
  }

  String _prefixed(List<String> cmd, String value) {
    final prefix = _getPrefix(cmd);
    return value.isNotEmpty ? '$prefix$value' : '';
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

  void _guardBuildSettings() {
    if (settings == null) {
      throw Exception('Build settings are not available.');
    }
  }
}
