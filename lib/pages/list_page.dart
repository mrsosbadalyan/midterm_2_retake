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

  @override
  void initState() {
    super.initState();

    _scroll.addListener(() {
      final bloc = context.read<RecipeBloc>();
      final pos = _scroll.position;
      final nearBottom = pos.pixels >= (pos.maxScrollExtent - 120);

      if (nearBottom && bloc.state.canLoadMore && !bloc.state.isLoading) {
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

              // Category
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
                        onSelected: (_) => bloc.add(
                          CategoryChanged(isAll ? null : c),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 8),

              // List + loader row at bottom while paging
              Expanded(
                child: state.visible.isEmpty
                    ? const Center(child: Text('No items match your filters.'))
                    : ListView.builder(
                  controller: _scroll,
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 12,
                  ),
                  itemCount:
                  state.visible.length + (state.isLoading ? 1 : 0),
                  itemBuilder: (context, i) {
                    // loader row at end while fetching next page
                    if (i >= state.visible.length) {
                      return const SafeArea(
                        top: false,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.6,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

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
