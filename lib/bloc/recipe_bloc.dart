import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/recipes.dart';
import '../models/recipe.dart';
import '../services/prefs_service.dart';
import 'recipe_event.dart';
import 'recipe_state.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  RecipeBloc() : super(RecipeState.initial(kAllRecipes)) {
    on<LoadInitial>(_onLoadInitial);
    on<SearchChanged>(_onSearchChanged);
    on<CategoryChanged>(_onCategoryChanged);
    on<LoadMore>(_onLoadMore); // +7 each time
    on<SelectRecipe>((e, emit) => emit(state.copyWith(selectedId: e.id)));
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadInitial(LoadInitial e, Emitter<RecipeState> emit) async {
    final saved = await PrefsService.load();
    final favs = <String>{...(saved['favorites']?.cast<String>() ?? const <String>[])};
    final search = (saved['search'] ?? '') as String;
    final cat = saved['category'] as String?;

    final filtered = _applyFilters(kAllRecipes, search, cat);
    const limit = 7;
    final first = filtered.take(limit).toList();

    emit(RecipeState(
      all: kAllRecipes,
      filtered: filtered,
      visible: first,
      search: search,
      category: cat,
      limit: limit,
      offset: first.length,
      canLoadMore: filtered.length > first.length,
      selectedId: null,
      favorites: favs,
      isLoading: false,
    ));
  }

  Future<void> _persist() async {
    await PrefsService.save({
      'favorites': state.favorites.toList(),
      'search': state.search,
      'category': state.category,
    });
  }

  void _onSearchChanged(SearchChanged e, Emitter<RecipeState> emit) {
    final filtered = _applyFilters(state.all, e.query, state.category);
    final first = filtered.take(state.limit).toList();
    emit(state.copyWith(
      search: e.query,
      filtered: filtered,
      visible: first,
      offset: first.length,
      canLoadMore: filtered.length > first.length,
      isLoading: false,
    ));
    _persist();
  }

  void _onCategoryChanged(CategoryChanged e, Emitter<RecipeState> emit) {
    final filtered = _applyFilters(state.all, state.search, e.category);
    final first = filtered.take(state.limit).toList();
    emit(state.copyWith(
      category: e.category,
      filtered: filtered,
      visible: first,
      offset: first.length,
      canLoadMore: filtered.length > first.length,
      isLoading: false,
    ));
    _persist();
  }

  Future<void> _onLoadMore(LoadMore e, Emitter<RecipeState> emit) async {
    if (!state.canLoadMore || state.isLoading) return;

    emit(state.copyWith(isLoading: true));
    await Future.delayed(const Duration(milliseconds: 600));

    final nextOffset = (state.offset + state.limit).clamp(0, state.filtered.length);
    final nextVisible = state.filtered.take(nextOffset).toList();

    emit(state.copyWith(
      visible: nextVisible,
      offset: nextVisible.length,
      canLoadMore: state.filtered.length > nextVisible.length,
      isLoading: false,
    ));
  }

  void _onToggleFavorite(ToggleFavorite e, Emitter<RecipeState> emit) {
    final favs = Set<String>.from(state.favorites);
    favs.contains(e.id) ? favs.remove(e.id) : favs.add(e.id);
    emit(state.copyWith(favorites: favs));
    _persist();
  }

  List<Recipe> _applyFilters(List<Recipe> src, String search, String? cat) {
    final q = search.trim().toLowerCase();
    return src.where((r) {
      final matchesTitle = q.isEmpty || r.title.toLowerCase().contains(q);
      final matchesCat = cat == null || r.category == cat;
      return matchesTitle && matchesCat;
    }).toList();
  }
}
