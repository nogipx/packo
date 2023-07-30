import 'package:packo/packo.dart';
import 'package:pub_semver/pub_semver.dart';

class PackagesCollection {
  const PackagesCollection({
    List<Package> packages = const [],
  }) : _packages = packages;

  final List<Package> _packages;
  List<Package> get packages =>
      _packages.where((e) => !excludePackages.contains(e.name)).toList();

  List<Version> get versions => packages.map((e) => e.currentVersion).toList();

  Package? find({required String name}) {
    final match = packages.where((e) => e.name == name);
    return match.isNotEmpty ? match.first : null;
  }

  List<Package> filterByDependency(String dependency) =>
      packages.where((e) => e.hasDependency(dependency)).toList();
}
