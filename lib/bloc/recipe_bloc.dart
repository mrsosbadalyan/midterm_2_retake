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
    on<LoadMore>(_onLoadMore);
    on<SelectRecipe>((e, emit) => emit(state.copyWith(selectedId: e.id)));
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadInitial(LoadInitial e, Emitter<RecipeState> emit) async {
    final saved = await PrefsService.load();
    final favs = <String>{...(saved['favorites']?.cast<String>() ?? const <String>[])};
    final search = (saved['search'] ?? '') as String;
    final cat = saved['category'] as String?;
    final filtered = _applyFilters(kAllRecipes, search, cat);
    final limit = 7;
    final visible = filtered.take(limit).toList();
    emit(RecipeState(
      all: kAllRecipes,
      filtered: filtered,
      visible: visible,
      search: search,
      category: cat,
      limit: limit,
      offset: visible.length,
      canLoadMore: filtered.length > visible.length,
      selectedId: null,
      favorites: favs,
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
    final visible = filtered.take(state.limit).toList();
    emit(state.copyWith(
      search: e.query,
      filtered: filtered,
      visible: visible,
      offset: visible.length,
      canLoadMore: filtered.length > visible.length,
    ));
    _persist();
  }

  void _onCategoryChanged(CategoryChanged e, Emitter<RecipeState> emit) {
    final filtered = _applyFilters(state.all, state.search, e.category);
    final visible = filtered.take(state.limit).toList();
    emit(state.copyWith(
      category: e.category,
      filtered: filtered,
      visible: visible,
      offset: visible.length,
      canLoadMore: filtered.length > visible.length,
    ));
    _persist();
  }

  // again this is for infinite scrolling and searching
  void _onLoadMore(LoadMore e, Emitter<RecipeState> emit) {
    if (!state.canLoadMore) return;
    final next = (state.offset + state.limit).clamp(0, state.filtered.length);
    final visible = state.filtered.take(next).toList();
    emit(state.copyWith(
      visible: visible,
      offset: visible.length,
      canLoadMore: state.filtered.length > visible.length,
    ));
  }

  // this is for favorites
  void _onToggleFavorite(ToggleFavorite e, Emitter<RecipeState> emit) {
    final favs = Set<String>.from(state.favorites);
    if (favs.contains(e.id)) {
      favs.remove(e.id);
    } else {
      favs.add(e.id);
    }
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
