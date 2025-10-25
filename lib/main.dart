import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/recipe_bloc.dart';
import 'bloc/recipe_event.dart';
import 'pages/list_page.dart';
import 'pages/detail_page.dart';

void main() {
  runApp(const RecipeExplorerApp());
}

class RecipeExplorerApp extends StatelessWidget {
  const RecipeExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RecipeBloc()..add(LoadInitial()),
      child: MaterialApp(
        title: 'Recipe Explorer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.teal,
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const ListPage(),
          '/details': (_) => const DetailPage(),
        },
      ),
    );
  }
}
