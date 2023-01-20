import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:packo/packo.dart';

class VersioningPackagesCommand extends Command {
  @override
  final String name = 'versions';
  @override
  final String description = 'Versioning packages';
  final Entrypoint entrypoint;

  final PackageCallback? onSync;

  VersioningPackagesCommand(this.entrypoint, {this.onSync}) {
    argParser
      ..addOption(
        'syncNew',
        help: 'Sync all packages to particular version.',
        valueHelp: '1.2.3',
      )
      ..addFlag(
        'syncLatest',
        help: 'Sync all packages to greatest version.',
        negatable: false,
      )
      ..addFlag(
        'syncCheck',
        abbr: 'c',
        help:
            'Checks are all packages in sync and prints their common version.',
        negatable: false,
      )
      ..addFlag(
        'list',
        abbr: 'l',
        help: 'List all packages versions.',
        negatable: false,
      );
  }

  @override
  Future<void> run() async {
    final args = argResults!;

    if (args.wasParsed('new')) {
      final version = Version.parse(args.arguments[1]);
      await synchronize(version, onSync);
    } else if (args.wasParsed('max')) {
      /// Get greatest version of all packages
      /// and updates others.
      final packages = entrypoint.getPackages();
      if (await checkSynced()) {
        print('Already synced.');
        exit(0);
      }

      final maxVersion = packages.maxVersion;
      if (maxVersion != null) {
        await synchronize(maxVersion, onSync);
      }
    } else if (args.wasParsed('checkSync')) {
      await checkSynced();
    } else if (args.wasParsed('list')) {
      final packages = entrypoint.getPackages();
      print(packages.map((e) => e.toString()).join('\n'));
    }
  }

  Version get _invalidVersion => Version(0, 0, 0);

  Future<bool> checkSynced() async {
    final packages = entrypoint.getPackages().excludeSync;

    final isSynced = packages.allVersionsSynced;
    print(isSynced ? 'All in sync' : 'Some not synced');
    return isSynced;
  }

  Future<void> synchronize(
    Version version, [
    PackageCallback? callback,
  ]) async {
    final packages = entrypoint.getPackages().excludeSync;

    if (packages.isEmpty || version == _invalidVersion) {
      print('There are no packages to sync');
      exit(2);
    }

    for (final package in packages) {
      await package.setVersion(version: version);
      callback?.call(package);
    }
  }
}
