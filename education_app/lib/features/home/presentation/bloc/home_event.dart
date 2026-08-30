import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadPackagesEvent extends HomeEvent {}

class SearchPackagesEvent extends HomeEvent {
  final String query;

  const SearchPackagesEvent(this.query);

  @override
  List<Object> get props => [query];
}

class ClearPackagesSearchEvent extends HomeEvent {}

class ToggleHomeSearchVisibilityEvent extends HomeEvent {}
