part of 'get_judges_cubit.dart';

@immutable
sealed class GetJudgesState {}

final class GetJudgesInitial extends GetJudgesState {}

final class GetJudgesLoading extends GetJudgesState {}

final class GetJudgesSuccess extends GetJudgesState {
  final List<String> judges;

  GetJudgesSuccess(this.judges);
}

final class GetJudgesError extends GetJudgesState {
  final String message;

  GetJudgesError(this.message);
}
