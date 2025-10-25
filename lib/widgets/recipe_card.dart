import 'package:flutter/material.dart';
import '../models/recipe.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final bool favorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.favorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        title: Text(recipe.title),
        subtitle: Text(recipe.category),
        trailing: IconButton(
          onPressed: onToggleFavorite,
          icon: Icon(
            favorite ? Icons.star_rounded : Icons.star_border_rounded,
            color: favorite ? Colors.amber : scheme.outline,
          ),
          tooltip: favorite ? 'Unfavorite' : 'Favorite',
        ),
      ),
    );
  }
}
