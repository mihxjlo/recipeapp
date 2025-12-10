import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/models/meal.dart';
import 'package:recipe_app/services/favorites_service.dart';

import '../widgets/meal_card.dart';
import 'meal_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  List<Meal> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async{
    setState(() {
      _isLoading = true;
    });

    try{
      final favorites = await _favoritesService.getFavorites();
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch(e) {
      setState(() {
        _isLoading = false;
      });
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading: $e')),
        );
      }
    }
  }

  Future<void> _removeFavorite(String mealId) async {
    await _favoritesService.removeFavorite(mealId);
    _loadFavorites();

    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Removed from favorites'),
            duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Recipes'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: _isLoading
      ? const Center(child: CircularProgressIndicator())
      : _favorites.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text('No favorite recipes!',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text('Favorite a recipe by clicking the <3',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[500],
                      ),
                ),
              ],
            ),
      )
      : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final meal = _favorites[index];
          return Stack(
            children: [
              MealCard(
                meal: meal,
                onTap: () async {
                  // Navigate to details
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MealDetailScreen(
                        mealId: meal.idMeal,
                      ),
                    ),
                  );
                  // Refresh list
                  _loadFavorites();
                },
              ),
              // Remove button
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      _removeFavorite(meal.idMeal);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }


}
