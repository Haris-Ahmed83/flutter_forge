import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// 1. Data Model for a Recipe
class Recipe {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final String prepTime;
  final String cookTime;
  final String servings;

  const Recipe({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
  });
}

/// 2. Sample Data for the Recipe App
final List<Recipe> sampleRecipes = [
  Recipe(
    id: 'r1',
    name: 'Classic Spaghetti Carbonara',
    imageUrl: 'https://images.unsplash.com/photo-1588013277068-6d5f94086e61?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    description: 'A traditional Italian pasta dish from Rome, made with eggs, hard cheese, cured pork (guanciale or pancetta), and black pepper.',
    ingredients: [
      '200g spaghetti',
      '100g guanciale (or pancetta)',
      '2 large eggs',
      '50g Pecorino Romano cheese, grated',
      'Freshly ground black pepper',
      'Salt for pasta water',
    ],
    steps: [
      'Bring a large pot of salted water to a boil. Add spaghetti and cook according to package directions until al dente.',
      'While pasta cooks, cut guanciale into small cubes. Cook in a dry skillet over medium heat until crispy. Remove guanciale, leaving rendered fat in the pan.',
      'In a bowl, whisk eggs with grated Pecorino Romano and a generous amount of black pepper.',
      'Drain spaghetti, reserving about 1/2 cup of pasta water. Add hot spaghetti directly to the skillet with guanciale fat. Toss to coat.',
      'Remove skillet from heat. Quickly add the egg mixture and a splash of reserved pasta water. Toss vigorously until a creamy sauce forms. Add more pasta water if needed to reach desired consistency.',
      'Stir in crispy guanciale. Serve immediately with extra Pecorino Romano and black pepper.',
    ],
    prepTime: '10 min',
    cookTime: '15 min',
    servings: '2',
  ),
  Recipe(
    id: 'r2',
    name: 'Homemade Margherita Pizza',
    imageUrl: 'https://images.unsplash.com/photo-1593560708920-61dd98c8c589?q=80&w=1935&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    description: 'A classic Neapolitan pizza, simple yet delicious, featuring San Marzano tomatoes, fresh mozzarella, basil, salt, and olive oil.',
    ingredients: [
      '1 pizza dough ball (store-bought or homemade)',
      '1/2 cup San Marzano crushed tomatoes',
      '125g fresh mozzarella, torn or sliced',
      'Fresh basil leaves',
      'Extra virgin olive oil',
      'Salt to taste',
    ],
    steps: [
      'Preheat oven to 220°C (425°F) with a pizza stone or baking steel if you have one.',
      'Lightly flour a surface and roll out the pizza dough into a roughly 10-12 inch circle.',
      'Transfer dough to a parchment-lined baking sheet or a pizza peel dusted with semolina.',
      'Spread crushed tomatoes evenly over the dough, leaving a small border for the crust.',
      'Distribute torn mozzarella over the sauce.',
      'Bake for 10-15 minutes, or until the crust is golden brown and the cheese is bubbly and slightly browned.',
      'Remove from oven, scatter fresh basil leaves, drizzle with olive oil, and sprinkle with a pinch of salt. Slice and serve hot.',
    ],
    prepTime: '20 min',
    cookTime: '15 min',
    servings: '2-3',
  ),
  Recipe(
    id: 'r3',
    name: 'Creamy Tomato Pasta',
    imageUrl: 'https://images.unsplash.com/photo-1608889100050-424026384a6c?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    description: 'A comforting and rich pasta dish with a creamy tomato sauce, perfect for a quick weeknight meal.',
    ingredients: [
      '300g pasta (penne, fusilli, or rigatoni)',
      '1 tbsp olive oil',
      '1 onion, finely chopped',
      '2 cloves garlic, minced',
      '400g can crushed tomatoes',
      '1/2 cup heavy cream',
      '1/4 cup grated Parmesan cheese',
      'Fresh basil or parsley for garnish',
      'Salt and black pepper to taste',
    ],
    steps: [
      'Cook pasta according to package directions until al dente. Reserve 1/2 cup pasta water before draining.',
      'While pasta cooks, heat olive oil in a large skillet over medium heat. Add onion and cook until softened, about 5 minutes.',
      'Add minced garlic and cook for another minute until fragrant.',
      'Stir in crushed tomatoes, salt, and pepper. Bring to a simmer and cook for 10-15 minutes, allowing sauce to thicken slightly.',
      'Reduce heat to low, stir in heavy cream and Parmesan cheese. Mix well until cheese is melted and sauce is creamy.',
      'Add drained pasta to the sauce. Toss to coat thoroughly. If the sauce is too thick, add a little reserved pasta water until desired consistency is reached.',
      'Serve hot, garnished with fresh basil or parsley and extra Parmesan if desired.',
    ],
    prepTime: '15 min',
    cookTime: '20 min',
    servings: '3-4',
  ),
  Recipe(
    id: 'r4',
    name: 'Chicken and Vegetable Stir-fry',
    imageUrl: 'https://images.unsplash.com/photo-1512058564619-f9b15b63b2f8?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    description: 'A quick and healthy stir-fry packed with lean protein and colorful vegetables, tossed in a savory sauce.',
    ingredients: [
      '2 chicken breasts, sliced into strips',
      '1 tbsp soy sauce',
      '1 tsp cornstarch',
      '1 tbsp sesame oil',
      '1 red bell pepper, sliced',
      '1 broccoli head, cut into florets',
      '2 carrots, julienned',
      '2 cloves garlic, minced',
      '1 tbsp ginger, grated',
      'For the sauce:',
      '2 tbsp soy sauce',
      '1 tbsp oyster sauce (optional)',
      '1 tbsp rice vinegar',
      '1 tsp sugar',
      '1/4 cup chicken broth',
      '1 tsp cornstarch',
    ],
    steps: [
      'Marinate chicken: In a bowl, toss chicken strips with 1 tbsp soy sauce and 1 tsp cornstarch. Set aside for 10 minutes.',
      'Prepare sauce: In a small bowl, whisk together all sauce ingredients.',
      'Heat sesame oil in a large wok or skillet over high heat. Add chicken and stir-fry until cooked through and lightly browned. Remove chicken from wok and set aside.',
      'Add bell pepper, broccoli, and carrots to the wok. Stir-fry for 3-5 minutes until vegetables are tender-crisp.',
      'Add garlic and ginger to the wok and stir-fry for 30 seconds until fragrant.',
      'Return chicken to the wok. Pour in the prepared sauce. Bring to a simmer and cook, stirring constantly, until sauce thickens, about 1-2 minutes.',
      'Serve immediately over rice or noodles.',
    ],
    prepTime: '20 min',
    cookTime: '15 min',
    servings: '2-3',
  ),
];

/// The root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
      // Define named routes for navigation.
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (context) => const RecipeListScreen());
        }
        if (settings.name == '/recipe-detail') {
          // Extract the Recipe object passed as an argument for the detail page.
          final args = settings.arguments as Recipe;
          return MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: args),
          );
        }
        // Fallback for unknown routes
        return MaterialPageRoute(builder: (context) => const Text('Error: Unknown Route'));
      },
    );
  }
}

/// 3. Recipe List Screen - Displays a list of available recipes.
class RecipeListScreen extends StatelessWidget {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipes'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: sampleRecipes.length,
        itemBuilder: (context, index) {
          final recipe = sampleRecipes[index];
          return RecipeCard(recipe: recipe);
        },
      ),
    );
  }
}

/// Widget for a single recipe item in the list, designed as a Card.
class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 20.0),
      child: InkWell(
        onTap: () {
          // Navigate to the detail screen, passing the recipe object as an argument.
          Navigator.pushNamed(context, '/recipe-detail', arguments: recipe);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero widget for shared element transition animation to the detail screen.
            Hero(
              tag: recipe.id, // Unique tag for Hero animation, must match on detail screen.
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  recipe.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // Fallback for image loading errors
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: colorScheme.surfaceVariant,
                    child: Center(
                      child: Icon(Icons.broken_image, color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recipe.description,
                    style: textTheme.bodyMedium!.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  _buildRecipeInfoRow(context, recipe),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper to build a row of recipe info (prep time, cook time, servings).
  Widget _buildRecipeInfoRow(BuildContext context, Recipe recipe) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildInfoColumn(Icons.timer_outlined, 'Prep', recipe.prepTime),
        _buildInfoColumn(Icons.kitchen_outlined, 'Cook', recipe.cookTime),
        _buildInfoColumn(Icons.people_outline, 'Servings', recipe.servings),
      ],
    );
  }

  /// Helper to build a single info column (icon, label, value).
  Widget _buildInfoColumn(IconData icon, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(icon, color: colorScheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.labelSmall!.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        Text(
          value,
          style: textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        ),
      ],
    );
  }
}

/// 4. Recipe Detail Screen - Displays the full details of a selected recipe.
class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
