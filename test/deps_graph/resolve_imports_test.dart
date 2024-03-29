import 'dart:io';
import 'package:test/test.dart';
import 'package:packo/packo.dart';
import 'get_package_location.dart';
import 'package:path/path.dart';

void main() {
  final testPackage = getPackageLocation('test');
  final pathPackage = getPackageLocation('path');

  test('Resolve relative file', () {
    var thisDartFile = File(join(testPackage!.path, 'lib', 'src', 'runner',
        'browser', 'phantom_js.dart'));
    var relativeFile = '../executable_settings.dart';
    var resolvedFile = resolveFile(thisDartFile, relativeFile);
    print(resolvedFile);
    expect(
        resolvedFile.path,
        join(testPackage.path, 'lib', 'src', 'runner',
                'executable_settings.dart')
            .replaceAll('\\', '/'));
  });

  test('Resolve relative file from .', () {
    var relativeFile = 'resolve_imports.dart';
    var thisDartFile = File('./lib/graphviz.dart');
    var resolvedFile = resolveFile(thisDartFile, relativeFile);
    print(resolvedFile);
    expect(resolvedFile.path,
        join('lib', 'resolve_imports.dart').replaceAll('\\', '/'));
  });

  test('find pubspec.yaml', () {
    var pubspecYaml = findPubspecYaml(Directory('.'));
    expect(pubspecYaml, isNotNull);
    pubspecYaml = findPubspecYaml(Directory('./lib'));
    expect(pubspecYaml, isNotNull);
    pubspecYaml = findPubspecYaml(testPackage!);
    expect(pubspecYaml, isNotNull);
    pubspecYaml = findPubspecYaml(pathPackage!);
    expect(pubspecYaml, isNotNull);
    pubspecYaml = findPubspecYaml(Directory('..'));
    expect(pubspecYaml, isNull);
  });

  test('resolvePackageFileFromPubspecYaml', () {
    var pubspecYaml = findPubspecYaml(Directory('.'))!;
    var resolvedPackageFile = resolvePackageFileFromPubspecYaml(
        pubspecYaml, 'package:packo/graphviz.dart');
    var pathParts = split(resolvedPackageFile.path);
    var lastThreeParts =
        joinAll(pathParts.sublist(pathParts.length - 3)).replaceAll('\\', '/');
    expect(lastThreeParts, 'lakos/lib/graphviz.dart');
  });
}
