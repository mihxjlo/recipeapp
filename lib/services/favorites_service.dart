import 'dart:convert';
import 'dart:ffi';

import 'package:recipe_app/models/meal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_meals';

  Future<void> saveFavorites(List<Meal> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoritesJson = favorites
    .map((meal) => json.encode(meal.toJson()))
    .toList();
    await prefs.setStringList(_favoritesKey, favoritesJson);
  }

  Future<List<Meal>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favoritesJson = prefs.getStringList(_favoritesKey);

    if(favoritesJson == null) {
      return [];
    }

    return favoritesJson
        .map((jsonStr) => Meal.fromJson(json.decode(jsonStr)))
        .toList();
  }

  Future<bool> isFavorite(String mealId) async {
    final favorites = await getFavorites();
    return favorites.any((meal) => meal.idMeal == mealId);
  }

  Future<void> addFavorite(Meal meal) async {
    final favorites = await getFavorites();

    if(!favorites.any((m) => m.idMeal == meal.idMeal)) {
      favorites.add(meal);
      await saveFavorites(favorites);
    }
  }

  Future<void> removeFavorite(String mealId) async {
    final favorites = await getFavorites();
    favorites.removeWhere((meal) => meal.idMeal == mealId);
    await saveFavorites(favorites);
  }

  Future<bool> toggleFavorite(Meal meal) async {
    final isFav = await isFavorite(meal.idMeal);

    if(isFav){
      await removeFavorite(meal.idMeal);
      return false;
    } else {
      await addFavorite(meal);
      return true;
    }
  }

}