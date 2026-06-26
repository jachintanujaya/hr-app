import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

/// Base contract every UseCase must follow.
/// Type = return type wrapped in Either, Params = input params.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use when a usecase takes no parameters.
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
