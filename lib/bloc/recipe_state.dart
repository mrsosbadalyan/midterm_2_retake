import '../models/recipe.dart';

class RecipeState {
  final List<Recipe> all;
  final List<Recipe> filtered;
  final List<Recipe> visible;
  final String search;
  final String? category;
  final int limit;
  final int offset;
  final bool canLoadMore;
  final String? selectedId;
  final Set<String> favorites;
  final bool isLoading;

  const RecipeState({
    required this.all,
    required this.filtered,
    required this.visible,
    required this.search,
    required this.category,
    required this.limit,
    required this.offset,
    required this.canLoadMore,
    required this.selectedId,
    required this.favorites,
    required this.isLoading,
  });

  factory RecipeState.initial(List<Recipe> dataset) {
    const limit = 7; // show 7 initially
    final filtered = List<Recipe>.from(dataset);
    final visible = filtered.take(limit).toList();
    return RecipeState(
      all: dataset,
      filtered: filtered,
      visible: visible,
      search: '',
      category: null,
      limit: limit,
      offset: visible.length,
      canLoadMore: filtered.length > visible.length,
      selectedId: null,
      favorites: <String>{},
      isLoading: false,
    );
  }

  RecipeState copyWith({
    List<Recipe>? all,
    List<Recipe>? filtered,
    List<Recipe>? visible,
    String? search,
    Object? category = _keep,
    int? limit,
    int? offset,
    bool? canLoadMore,
    Object? selectedId = _keep,
    Set<String>? favorites,
    bool? isLoading,
  }) {
    return RecipeState(
      all: all ?? this.all,
      filtered: filtered ?? this.filtered,
      visible: visible ?? this.visible,
      search: search ?? this.search,
      category: identical(category, _keep) ? this.category : category as String?,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      canLoadMore: canLoadMore ?? this.canLoadMore,
      selectedId:
      identical(selectedId, _keep) ? this.selectedId : selectedId as String?,
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  static const _keep = Object();
}
