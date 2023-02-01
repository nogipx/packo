import 'package:meta/meta.dart';
import 'package:packo/packo.dart';

abstract class BuildStep<T> {
  void setNext(BuildStep<T> step);
  FutureOr<T> handle(T data);
}

class BaseBuildStep implements BuildStep<BuildTransaction> {
  BuildStep<BuildTransaction>? _next;

  @override
  void setNext(BuildStep<BuildTransaction> step) {
    _next = step;
  }

  @override
  @mustCallSuper
  FutureOr<BuildTransaction> handle(BuildTransaction data) async {
    if (_next != null) {
      return await _next!.handle(data);
    }
    return data;
  }
}
