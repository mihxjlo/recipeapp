import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:recipe_app/models/meal.dart';
import 'package:recipe_app/services/favorites_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/meal_detail.dart';
import '../services/api_service.dart';

class MealDetailScreen extends StatefulWidget {
  final String mealId;

  const MealDetailScreen({
    Key? key,
    required this.mealId,
  }) : super(key: key);

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final ApiService _apiService = ApiService();
  final FavoritesService _favoritesService = FavoritesService();
  MealDetail? _mealDetail;
  bool _isLoading = true;
  bool _isFavorite = true;

  @override
  void initState() {
    super.initState();
    _loadMealDetail();
  }

  Future<void> _loadMealDetail() async {
    try {
      final mealDetail = await _apiService.getMealDetail(widget.mealId);
      final isFav = await _favoritesService.isFavorite(widget.mealId);
      setState(() {
        _mealDetail = mealDetail;
        _isFavorite = isFav;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading: $e')),
        );
      }
    }
  }

  Future<void> _openYouTube(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot open YouTube')),
        );
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if(_mealDetail == null) return;

    final meal = Meal(
        idMeal: _mealDetail!.idMeal,
        strMeal: _mealDetail!.strMeal,
        strMealThumb: _mealDetail!.strMealThumb,
    );

    final newStatus = await _favoritesService.toggleFavorite(meal);
    setState(() {
      _isFavorite = newStatus;
    });

    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
              newStatus
              ? 'Added to favorites'
              : 'Removed from favorites'
            ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _mealDetail == null
          ? const Center(child: Text('Recipe not found!'))
          : CustomScrollView(
        slivers: [
          // AppBar wiht image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.orange,
            actions: [
              IconButton(
                  icon: Icon(_isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
                  ),
                color: _isFavorite ? Colors.red : Colors.white,
                tooltip: _isFavorite
                ? 'Remove from favorites'
                : 'Add to favorites',
                onPressed: _toggleFavorite,
                  ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _mealDetail!.strMeal,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              background: CachedNetworkImage(
                imageUrl: _mealDetail!.strMealThumb,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and country
                  Row(
                    children: [
                      Chip(
                        avatar: const Icon(
                          Icons.category,
                          size: 18,
                        ),
                        label: Text(_mealDetail!.strCategory),
                        backgroundColor: Colors.orange[100],
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        avatar: const Icon(
                          Icons.public,
                          size: 18,
                        ),
                        label: Text(_mealDetail!.strArea),
                        backgroundColor: Colors.blue[100],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Ingredients
                  const Text(
                    'Ingredients',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _mealDetail!.ingredients.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4.0,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 8,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _mealDetail!.ingredients[index],
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Text(
                                _mealDetail!.measures[index],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Instructions
                  const Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _mealDetail!.strInstructions,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // YouTube btn
                  if (_mealDetail!.strYoutube.isNotEmpty)
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _openYouTube(_mealDetail!.strYoutube);
                        },
                        icon: const Icon(Icons.play_circle_outline),
                        label: const Text('Watch on Youtube'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}