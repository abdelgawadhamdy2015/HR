import 'result.dart';

/// Standard contract every use case follows: takes [Params], returns a [Result].
abstract class UseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

/// Marker for use cases that need no parameters.
class NoParams {
  const NoParams();
}
