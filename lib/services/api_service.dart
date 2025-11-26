import 'dart:convert';

import 'package:flutter/foundation.dart' hide Category;
import 'package:http/http.dart' as http;
import 'package:recipe_app/models/meal.dart';
import 'package:recipe_app/models/meal_detail.dart';
import '../models/category.dart';
class ApiService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Category>> getCategories() async{
    try{
      final response = await http.get(
        Uri.parse('$baseUrl/categories.php'),
      );

      if(response.statusCode == 200){
        final data = json.decode(response.body);
        final List categoriesJson = data['categories'] ?? [];

        return categoriesJson
            .map((json) => Category.fromJson(json))
            .toList();
      }else {
        throw Exception('Loading categories unsuccessful');
      }

    } catch(e){
      throw Exception('Error $e');
    }
  }

  Future<List<Meal>> getMealsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/filter.php?c=$category'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List mealsJson = data['meals'] ?? [];

        return mealsJson.map((json) => Meal.fromJson(json)).toList();
      } else {
        throw Exception('Unsuccessful loading meals');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Meal>> searchMeals(String query) async{
    try{
      final response = await http.get(
        Uri.parse('$baseUrl/search.php?s=$query')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List? mealsJson = data['meals'];

        if(mealsJson == null) {
          return [];
        }

        return mealsJson.map((json) => Meal.fromJson(json)).toList();
      } else {
        throw Exception('Unsuccessful search');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<MealDetail> getMealDetail(String id) async{
    try{
      final response = await http.get(
        Uri.parse('$baseUrl/lookup.php?i=$id')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List mealsJson = data['meals'] ?? [];

        if (mealsJson.isEmpty) {
          throw Exception('Meal not found!');
        }

        return MealDetail.fromJson(mealsJson[0]);
      } else {
        throw Exception('Unsuccessful loading details!');
      }
    } catch (e){
      throw Exception('Error: $e');
    }
  }

  Future<MealDetail> getRandomMeal() async{
    try{
      final response = await http.get(
          Uri.parse('$baseUrl/random.php')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List mealsJson = data['meals'] ?? [];

        if (mealsJson.isEmpty) {
          throw Exception('Random meal could not be loaded!');
        }

        return MealDetail.fromJson(mealsJson[0]);
      } else {
        throw Exception('Unsuccessful loading random meal!');
      }
    } catch (e){
      throw Exception('Error: $e');
    }
  }
}