import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:recipe_app/screens/meals_screen.dart';
import 'package:recipe_app/screens/random_meal_screen.dart';
import 'package:recipe_app/services/api_service.dart';
import 'package:recipe_app/widgets/category_card.dart';
import '../models/category.dart';
import 'favorites_screen.dart';

class CategoriesScreen extends StatefulWidget {

const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();


}

class _CategoriesScreenState extends State<CategoriesScreen>{
  final ApiService _apiService = ApiService();
  List<Category> _categories = [];
  List<Category> _filteredCategories = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState(){
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async{
    try{
      final categories = await _apiService.getCategories();
      setState(() {
        _categories = categories;
        _filteredCategories = categories;
        _isLoading = false;
      });
    } catch(e){
      setState(() {
        _isLoading = false;
      });
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error while loading: $e')),
        );
      }
    }
  }

  void _filterCategories(String query) {
    setState(() {
      _searchQuery = query;
      if(query.isEmpty){
        _filteredCategories = _categories;
      }else {
        _filteredCategories = _categories
            .where((category) => category.strCategory
            .toLowerCase()
            .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Categories'),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Омилени рецепти',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Random Recipe',
            onPressed:(){
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RandomMealScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          //Search bar
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: _filterCategories,
                decoration: InputDecoration(
                  hintText: 'Search category...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
          ),
          //List of categories
          Expanded(child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                : _filteredCategories.isEmpty
                ? Center(
            child: Text(_searchQuery.isEmpty
            ? 'No Categories'
            : 'No results for "$_searchQuery"',
            style: const TextStyle(fontSize: 18),
            ),
          )
        : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredCategories.length,
              itemBuilder: (context, index) {
                final category = _filteredCategories[index];
                return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: CategoryCard(
                        category: category,
                        onTap: (){

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MealsScreen(
                                categoryName: category.strCategory,
                              ),
                            ),
                          );
                        },
                    ),
                );
              },
          ),
          ),
        ],
      ),
    );
  }
}