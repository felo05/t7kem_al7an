part of 'church_results_cubit.dart';

@immutable
sealed class ChurchResultsState {}

final class ChurchResultsInitial extends ChurchResultsState {}

class ChurchResultsLoading extends ChurchResultsState {}

class ChurchResultsSuccess extends ChurchResultsState {
  ChurchResultsSuccess(this.documents);
  final List<ChurchResultDoc> documents;
}