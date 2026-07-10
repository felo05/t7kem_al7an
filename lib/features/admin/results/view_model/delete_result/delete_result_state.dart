part of 'delete_result_cubit.dart';

@immutable
sealed class DeleteResultState {}

final class DeleteResultInitial extends DeleteResultState {}

class DeleteResultLoading extends DeleteResultState {}

class DeleteResultSuccess extends DeleteResultState {}

class DeleteResultError extends DeleteResultState {
  DeleteResultError(this.message);
  final String message;
}
