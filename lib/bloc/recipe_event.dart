import '../models/recipe.dart';

abstract class RecipeEvent {}

class LoadInitial extends RecipeEvent {}

class SearchChanged extends RecipeEvent {
  final String query;
  SearchChanged(this.query);
}

class CategoryChanged extends RecipeEvent {
  final String? category;
  CategoryChanged(this.category);
}

class LoadMore extends RecipeEvent {} //this is for infinite scrolling

class SelectRecipe extends RecipeEvent {
  final String id;
  SelectRecipe(this.id);
}

class ToggleFavorite extends RecipeEvent {
  final String id;
  ToggleFavorite(this.id);
}
