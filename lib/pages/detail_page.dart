import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/recipe_bloc.dart';
import '../bloc/recipe_state.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecipeBloc, RecipeState>(
      builder: (context, state) {
        final id = state.selectedId;
        final recipe = id == null
            ? null
            : state.all.firstWhere((r) => r.id == id, orElse: () => state.visible.first);
        final isFav = id != null && state.favorites.contains(id);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Details'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: recipe == null
              ? const Center(child: Text('No item selected.'))
              : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      recipe.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Icon(isFav ? Icons.star_rounded : Icons.star_border_rounded,
                      color: isFav ? Colors.amber : null),
                ],
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(recipe.category),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(height: 12),
              Text(
                recipe.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Ingredients',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...recipe.ingredients.map((ing) => ListTile(
                dense: true,
                leading: const Icon(Icons.check_circle_outline),
                title: Text(ing),
                contentPadding: EdgeInsets.zero,
              )),
            ],
          ),
        );
      },
    );
  }
}
