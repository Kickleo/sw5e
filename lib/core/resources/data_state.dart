// lib/core/resources/data_state.dart
sealed class DataState<T> {
  const DataState();
}

class DataSuccess<T> extends DataState<T> {
  final T data;
  const DataSuccess(this.data);
}

class DataFailed<T> extends DataState<T> {
  final Object error;
  final StackTrace? stackTrace;
  const DataFailed(this.error, [this.stackTrace]);
}