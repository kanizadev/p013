import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_article.dart';

class BookmarkService {
  static const String _bookmarksKey = 'bookmarked_articles';

  Future<List<NewsArticle>> getBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? bookmarksJson = prefs.getString(_bookmarksKey);

      if (bookmarksJson == null) return [];

      final List<dynamic> jsonList =
          json.decode(bookmarksJson) as List<dynamic>;
      return jsonList
          .map((json) => NewsArticle.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> addBookmark(NewsArticle article) async {
    try {
      final bookmarks = await getBookmarks();

      // Check if already bookmarked
      if (bookmarks.any((a) => a.url == article.url)) {
        return false;
      }

      bookmarks.add(article);
      return await _saveBookmarks(bookmarks);
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeBookmark(NewsArticle article) async {
    try {
      final bookmarks = await getBookmarks();
      bookmarks.removeWhere((a) => a.url == article.url);
      return await _saveBookmarks(bookmarks);
    } catch (e) {
      return false;
    }
  }

  Future<bool> isBookmarked(NewsArticle article) async {
    try {
      final bookmarks = await getBookmarks();
      return bookmarks.any((a) => a.url == article.url);
    } catch (e) {
      return false;
    }
  }

  Future<bool> _saveBookmarks(List<NewsArticle> bookmarks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = bookmarks.map((article) => article.toJson()).toList();
      final String jsonString = json.encode(jsonList);
      return await prefs.setString(_bookmarksKey, jsonString);
    } catch (e) {
      return false;
    }
  }
}
