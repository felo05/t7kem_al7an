part of 'churches_cubit.dart';

@immutable
sealed class ChurchesState {}

final class ChurchesInitial extends ChurchesState {}

final class ChurchesLoading extends ChurchesState {}

final class ChurchesSuccess extends ChurchesState {
  final List<BaseMarksFormModel> churches;

  ChurchesSuccess({required this.churches});
}

final class ChurchesError extends ChurchesState {
  final String message;

  ChurchesError({required this.message});
}