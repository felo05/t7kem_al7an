part of 'judges_assigning_cubit.dart';

@immutable
sealed class JudgesAssigningState {}

final class JudgesAssigningInitial extends JudgesAssigningState {}

final class JudgesAssigningSuccess extends JudgesAssigningState {}

final class JudgesAssigningLoading extends JudgesAssigningState {}

final class JudgesAssigningError extends JudgesAssigningState {
  final String message;

  JudgesAssigningError(this.message);
}
