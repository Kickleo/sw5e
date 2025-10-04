abstract class Usecase<TResult, TParams> {
  Future<TResult> call({TParams params});
}