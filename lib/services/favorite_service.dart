import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/article.dart';

class FavoriteService {
  static const _storageKey = 'favorite_articles';

  Future<List<Article>> loadFavorites() async {
    final preferences = await SharedPreferences.getInstance();
    final savedArticles = preferences.getStringList(_storageKey) ?? [];
    return savedArticles
        .map(
          (article) =>
              Article.fromJson(jsonDecode(article) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> saveFavorites(List<Article> articles) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _storageKey,
      articles.map((article) => jsonEncode(article.toJson())).toList(),
    );
  }
}
