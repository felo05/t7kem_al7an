part of 'delete_judge_cubit.dart';

abstract class DeleteJudgeState {}

class DeleteJudgeInitial extends DeleteJudgeState {}

class DeleteJudgeLoading extends DeleteJudgeState {}

class DeleteJudgeSuccess extends DeleteJudgeState {}

class DeleteJudgeError extends DeleteJudgeState {
  DeleteJudgeError(this.message);
  final String message;
}
