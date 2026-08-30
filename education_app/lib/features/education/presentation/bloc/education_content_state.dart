import 'package:equatable/equatable.dart';
import '../../domain/entities/education_content.dart';

abstract class EducationContentState extends Equatable {
  const EducationContentState();
  
  @override
  List<Object> get props => [];
}

class EducationContentInitial extends EducationContentState {}

class EducationContentLoading extends EducationContentState {}

class EducationContentLoaded extends EducationContentState {
  final List<EducationContent> contents;
  final List<EducationContent> filteredContents;
  final String searchQuery;
  final bool isSearching;

  const EducationContentLoaded(
    this.contents, {
    this.filteredContents = const [],
    this.searchQuery = '',
    this.isSearching = false,
  });

  EducationContentLoaded copyWith({
    List<EducationContent>? contents,
    List<EducationContent>? filteredContents,
    String? searchQuery,
    bool? isSearching,
  }) {
    return EducationContentLoaded(
      contents ?? this.contents,
      filteredContents: filteredContents ?? this.filteredContents,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object> get props => [contents, filteredContents, searchQuery, isSearching];
}

class EducationContentError extends EducationContentState {
  final String message;

  const EducationContentError(this.message);

  @override
  List<Object> get props => [message];
}
