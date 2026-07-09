part of 'collection_results_cubit.dart';

@immutable
sealed class CollectionResultsState {}

final class CollectionResultsInitial extends CollectionResultsState {}

class CollectionResultsLoading extends CollectionResultsState {}

class CollectionResultsSuccess extends CollectionResultsState {
  CollectionResultsSuccess(this.rankings);
  final List<ChurchAverage> rankings;
}