import 'package.dart';

export 'extension.dart';
export 'modules/_index.dart';
export 'package.dart';
export 'publish.dart';
export 'shell/_index.dart';
export 'version.dart';

final excludePackages = ['packo'];

typedef PackageCallback = void Function(Package package);
