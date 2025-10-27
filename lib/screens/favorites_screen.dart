import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../services/database_helper.dart';

class FavoritesScreen extends StatefulWidget {
  final VoidCallback onBack;

  const FavoritesScreen({super.key, required this.onBack});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    final db = DatabaseHelper.instance;
    final favorites = await db.getFavoriteAffirmations();

    setState(() {
      _favorites = favorites;
      _isLoading = false;
    });
  }

  Future<void> _deleteFavorite(int id, int index) async {
    HapticFeedback.lightImpact();

    final db = DatabaseHelper.instance;
    await db.deleteFavoriteAffirmation(id);

    setState(() {
      _favorites.removeAt(index);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Removed from favorites'),
          duration: const Duration(seconds: 1),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        backgroundColor: AppColors.base,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: widget.onBack,
        ),
        title: Text(
          'Favorite Affirmations',
          style: AppTextStyles.heading3,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.lavender,
              ),
            )
          : _favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: AppColors.overlay0,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No favorites yet',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.overlay0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Save affirmations to see them here',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final favorite = _favorites[index];
                    final id = favorite['id'] as int;
                    final text = favorite['text'] as String;
                    final savedAt = DateTime.parse(favorite['saved_at'] as String);

                    return Dismissible(
                      key: Key(id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(
                          Icons.delete,
                          color: AppColors.base,
                          size: 28,
                        ),
                      ),
                      onDismissed: (direction) {
                        _deleteFavorite(id, index);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface0,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.lavender.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.favorite,
                                  color: AppColors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    text,
                                    style: AppTextStyles.body.copyWith(
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.overlay0,
                                    size: 20,
                                  ),
                                  onPressed: () => _deleteFavorite(id, index),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Saved ${_formatDate(savedAt)}',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.overlay0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}
