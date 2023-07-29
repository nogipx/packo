// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

class EnvProperty {
  final String key;
  final String? value;
  final String? defaultValue;

  final bool required;

  const EnvProperty(
    this.key, {
    this.value,
    this.defaultValue,
    this.required = true,
  });

  /// See issue: https://github.com/flutter/flutter/issues/55870
  /// .fromEnvironment() work only with const keyword.
  ///
  // String? get fromEnvironment =>
  //     String.fromEnvironment(key, defaultValue: defaultValue ?? '');

  String get dartDefine => '--dart-define=$key=$value';

  @override
  bool operator ==(Object other) => other is EnvProperty && other.key == key;

  @override
  int get hashCode => Object.hashAll([key]);

  EnvProperty copyWith({
    String? value,
    String? defaultValue,
    bool? required,
  }) {
    return EnvProperty(
      key,
      value: value ?? this.value,
      defaultValue: defaultValue ?? this.defaultValue,
      required: required ?? this.required,
    );
  }

  @override
  String toString() => 'EnvProperty('
      '$key, '
      'value: $value'
      ')';
}
