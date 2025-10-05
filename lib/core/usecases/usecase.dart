// lib/core/usecases/usecase.dart
abstract class Usecase<R, P> {
  const Usecase();
  Future<R> call({required P params});
}

class NoParams {
  const NoParams();
}
