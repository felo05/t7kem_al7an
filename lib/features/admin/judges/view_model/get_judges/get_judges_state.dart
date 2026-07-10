part of 'get_judges_cubit.dart';

abstract class GetJudgesState {}

class GetJudgesLoading extends GetJudgesState {}

class GetJudgesLoaded extends GetJudgesState {
  GetJudgesLoaded(this.judges);
  final List<UserModel> judges;
}

class GetJudgesError extends GetJudgesState {
  GetJudgesError(this.message);
  final String message;
}

class JudgeEntry {
  JudgeEntry(this.user);
  final UserModel user;
}
