part of 'add_churches_cubit.dart';

@immutable
sealed class AddChurchesState {}

final class AddChurchesInitial extends AddChurchesState {}

class AddChurchesLoading extends AddChurchesState {}

class AddChurchesSuccess extends AddChurchesState {}

class AddChurchesError extends AddChurchesState {
  AddChurchesError(this.message);
  final String message;
}