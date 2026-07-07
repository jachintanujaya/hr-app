import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base contract for usecases that expose a live stream of data instead of
/// a single Future — for Firestore-backed features that should update in
/// real time without a manual refresh.
abstract class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}
