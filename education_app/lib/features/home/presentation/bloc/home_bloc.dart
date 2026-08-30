import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service.dart';
import '../../data/models/package_model.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ApiService apiService;

  HomeBloc({required this.apiService}) : super(HomeInitial()) {
    on<LoadPackagesEvent>(_onLoadPackages);
    on<SearchPackagesEvent>(_onSearchPackages);
    on<ClearPackagesSearchEvent>(_onClearPackagesSearch);
    on<ToggleHomeSearchVisibilityEvent>(_onToggleHomeSearchVisibility);
  }

  Future<void> _onLoadPackages(
    LoadPackagesEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final packages = await apiService.getPackages();
      emit(HomeLoaded(packages, filteredPackages: packages));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  void _onSearchPackages(
    SearchPackagesEvent event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final query = event.query.trim().toLowerCase();
      final filtered = _filterPackages(currentState.packages, query);
      emit(currentState.copyWith(
        filteredPackages: filtered,
        searchQuery: query,
      ));
    }
  }

  void _onClearPackagesSearch(
    ClearPackagesSearchEvent event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(
        filteredPackages: currentState.packages,
        searchQuery: '',
      ));
    }
  }

  void _onToggleHomeSearchVisibility(
    ToggleHomeSearchVisibilityEvent event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final nextIsSearching = !currentState.isSearching;
      emit(currentState.copyWith(
        isSearching: nextIsSearching,
        filteredPackages: nextIsSearching ? currentState.filteredPackages : currentState.packages,
        searchQuery: nextIsSearching ? currentState.searchQuery : '',
      ));
    }
  }

  List<PackageModel> _filterPackages(List<PackageModel> packages, String query) {
    if (query.isEmpty) return packages;
    return packages.where((p) {
      final titleMatch = p.title.toLowerCase().contains(query);
      final descMatch = p.description.toLowerCase().contains(query);
      return titleMatch || descMatch;
    }).toList();
  }
}
