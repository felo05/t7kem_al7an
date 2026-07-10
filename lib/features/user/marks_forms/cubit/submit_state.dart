part of 'submit_cubit.dart';

@immutable
sealed class SubmitState {}

final class SubmitInitial extends SubmitState {}

final class SubmitLoading extends SubmitState {}

final class SubmitSuccess extends SubmitState {
  SubmitSuccess({this.payload});
  final Map<String, dynamic>? payload;
}

final class SubmitFailure extends SubmitState {
  final String error;

  SubmitFailure(this.error);
}
