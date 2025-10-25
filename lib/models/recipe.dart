class Recipe {
  final String id;
  final String title;
  final String category;
  final String description;
  final List<String> ingredients;

  const Recipe({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.ingredients,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'category': category,
    'description': description,
    'ingredients': ingredients,
  };

  factory Recipe.fromMap(Map<String, dynamic> m) => Recipe(
    id: m['id'] as String,
    title: m['title'] as String,
    category: m['category'] as String,
    description: m['description'] as String,
    ingredients: (m['ingredients'] as List).cast<String>(),
  );
}
