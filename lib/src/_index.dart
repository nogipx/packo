import 'package.dart';

export 'deploy/_index.dart';
export 'extension.dart';
export 'package.dart';
export 'publish.dart';
export 'shell/_index.dart';
export 'version.dart';

final excludePackages = ['packo'];

typedef PackageCallback = void Function(Package package);
