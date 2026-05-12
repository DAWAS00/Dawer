import '../../domain/failures/app_failure.dart';
export '../../domain/failures/app_failure.dart';
export '../result/result.dart' show AppResult;

sealed class ViewState<T> {
  const ViewState();
}

final class Idle<T> extends ViewState<T> {
  const Idle();
}

final class Loading<T> extends ViewState<T> {
  const Loading();
}

final class Loaded<T> extends ViewState<T> {
  const Loaded(this.data);
  final T data;
}

final class Failed<T> extends ViewState<T> {
  const Failed(this.failure);
  final AppFailure failure;
}
