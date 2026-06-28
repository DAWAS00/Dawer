import '../../domain/failures/app_failure.dart';

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
  final T data;
  const Loaded(this.data);
}

final class Failed<T> extends ViewState<T> {
  final AppFailure failure;
  const Failed(this.failure);
}
