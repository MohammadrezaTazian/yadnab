import 'package:equatable/equatable.dart';
import '../../data/models/package_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<PackageModel> packages;
  final List<PackageModel> filteredPackages;
  final String searchQuery;
  final bool isSearching;

  const HomeLoaded(
    this.packages, {
    this.filteredPackages = const [],
    this.searchQuery = '',
    this.isSearching = false,
  });

  HomeLoaded copyWith({
    List<PackageModel>? packages,
    List<PackageModel>? filteredPackages,
    String? searchQuery,
    bool? isSearching,
  }) {
    return HomeLoaded(
      packages ?? this.packages,
      filteredPackages: filteredPackages ?? this.filteredPackages,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object> get props => [packages, filteredPackages, searchQuery, isSearching];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
