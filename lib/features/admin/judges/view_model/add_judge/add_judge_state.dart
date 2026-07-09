part of 'add_judge_cubit.dart';

abstract class AddJudgeState {}

class AddJudgeInitial extends AddJudgeState {}

class AddJudgeLoading extends AddJudgeState {}

class AddJudgeSuccess extends AddJudgeState {
  AddJudgeSuccess({required this.isEditing});
  final bool isEditing;
}

class AddJudgeError extends AddJudgeState {
  AddJudgeError(this.message);
  final String message;
}