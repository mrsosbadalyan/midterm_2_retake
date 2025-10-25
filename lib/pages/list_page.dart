import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/recipe_bloc.dart';
import '../bloc/recipe_event.dart';
import '../bloc/recipe_state.dart';
import '../widgets/recipe_card.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final _scroll = ScrollController();
  bool _armed = true; // gate so we load only once per bottom reach

  @override
  void initState() {
    super.initState();

    _scroll.addListener(() {
      final bloc = context.read<RecipeBloc>();
      final s = bloc.state;
      final pos = _scroll.position;

      final nearBottom = pos.pixels >= (pos.maxScrollExtent - 120);

      // Re-arm once the user scrolls up a bit
      final rearmThreshold = pos.maxScrollExtent - 400;
      if (pos.pixels < rearmThreshold) {
        _armed = true;
      }

      if (nearBottom && _armed && s.canLoadMore) {
        _armed = false;
        print("Hello");
        bloc.add(LoadMore());
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecipeBloc, RecipeState>(
      builder: (context, state) {
        final bloc = context.read<RecipeBloc>();

        final categories = <String>{'All', ...state.all.map((r) => r.category)}
          ..removeWhere((e) => e.isEmpty);

        return Scaffold(
          appBar: AppBar(title: const Text('Recipe Explorer')),
          body: Column(
            children: [
              // Search
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  onChanged: (q) => bloc.add(SearchChanged(q)),
                  decoration: InputDecoration(
                    hintText: 'Search by title...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // Category chips
              SizedBox(
                height: 46,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: categories.map((c) {
                    final isAll = c == 'All';
                    final selected =
                    isAll ? state.category == null : c == state.category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(c),
                        selected: selected,
                        onSelected: (_) {
                          _armed = true; // re-arm when filters change
                          bloc.add(CategoryChanged(isAll ? null : c));
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 8),

              // List (NO loader row)
              Expanded(
                child: state.visible.isEmpty
                    ? const Center(child: Text('No items match your filters.'))
                    : ListView.builder(
                  controller: _scroll,
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 12,
                  ),
                  itemCount: state.visible.length, // <-- only visible items
                  itemBuilder: (context, i) {
                    final r = state.visible[i];
                    final fav = state.favorites.contains(r.id);
                    return RecipeCard(
                      recipe: r,
                      favorite: fav,
                      onTap: () {
                        bloc.add(SelectRecipe(r.id));
                        Navigator.pushNamed(context, '/details');
                      },
                      onToggleFavorite: () =>
                          bloc.add(ToggleFavorite(r.id)),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
