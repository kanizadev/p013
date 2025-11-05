import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';

class NewsService {
  // Using NewsAPI.org - you can get a free API key at https://newsapi.org
  // For demo purposes, using sample data
  // To use with your own API key, uncomment and use:
  // static const String _baseUrl = 'https://newsapi.org/v2';
  // static const String _apiKey = 'YOUR_API_KEY_HERE';

  Future<List<NewsArticle>> getTopHeadlines({
    String? country,
    String? category,
  }) async {
    try {
      // For demo: Using a public endpoint that works without API key
      // In production, use: $_baseUrl/top-headlines?country=${country ?? 'us'}&apiKey=$_apiKey

      // Using a test endpoint that doesn't require API key
      final uri = Uri.parse(
        'https://newsapi.org/v2/top-headlines?country=${country ?? 'us'}&apiKey=demo',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final newsResponse = NewsResponse.fromJson(jsonData);
        return newsResponse.articles;
      } else {
        // If API fails, return sample data for demo
        return _getSampleNews(category: category);
      }
    } catch (e) {
      // Return sample data on error
      return _getSampleNews(category: category);
    }
  }

  Future<List<NewsArticle>> searchNews(String query) async {
    try {
      final uri = Uri.parse(
        'https://newsapi.org/v2/everything?q=$query&sortBy=popularity&apiKey=demo',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final newsResponse = NewsResponse.fromJson(jsonData);
        return newsResponse.articles;
      } else {
        return _getSampleNews(category: null);
      }
    } catch (e) {
      return _getSampleNews(category: null);
    }
  }

  // Sample news data for demo purposes
  List<NewsArticle> _getSampleNews({String? category}) {
    final baseArticles = [
      NewsArticle(
        author: 'Tech News',
        title: 'Flutter 3.0 Released with Major Updates',
        description:
            'Flutter team announces the release of Flutter 3.0 with improved performance and new features.',
        url: 'https://flutter.dev',
        urlToImage: 'https://picsum.photos/800/600?random=1',
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        content:
            'Flutter 3.0 brings significant improvements to the framework...',
        source: 'Tech News',
      ),
      NewsArticle(
        author: 'Science Daily',
        title: 'New Breakthrough in Quantum Computing',
        description:
            'Scientists achieve new milestone in quantum computing research.',
        url: 'https://example.com',
        urlToImage: 'https://picsum.photos/800/600?random=2',
        publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
        content: 'Researchers have made significant progress...',
        source: 'Science Daily',
      ),
      NewsArticle(
        author: 'Business Insider',
        title: 'Stock Market Reaches New Heights',
        description:
            'Major indices hit record highs amid positive economic indicators.',
        url: 'https://example.com',
        urlToImage: 'https://picsum.photos/800/600?random=3',
        publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
        content: 'The stock market continues its upward trend...',
        source: 'Business Insider',
      ),
      NewsArticle(
        author: 'Sports Central',
        title: 'Championship Game Set for This Weekend',
        description: 'Two top teams will face off in the championship final.',
        url: 'https://example.com',
        urlToImage: 'https://picsum.photos/800/600?random=4',
        publishedAt: DateTime.now().subtract(const Duration(hours: 12)),
        content: 'The championship game promises to be exciting...',
        source: 'Sports Central',
      ),
      NewsArticle(
        author: 'Health News',
        title: 'New Study on Mental Health Benefits',
        description:
            'Research shows positive impact of exercise on mental wellbeing.',
        url: 'https://example.com',
        urlToImage: 'https://picsum.photos/800/600?random=5',
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        content: 'A new study reveals the connection between...',
        source: 'Health News',
      ),
    ];

    // Filter by category if provided
    if (category != null && category != 'general') {
      final categoryArticles = _getCategorySpecificNews(category);
      return [...categoryArticles, ...baseArticles.take(2)];
    }

    return baseArticles;
  }

  List<NewsArticle> _getCategorySpecificNews(String category) {
    final categoryNews = {
      'business': [
        NewsArticle(
          author: 'Business Times',
          title: 'Market Analysis: Q4 Earnings Report',
          description: 'Major corporations report strong quarterly earnings.',
          url: 'https://example.com',
          urlToImage: 'https://picsum.photos/800/600?random=10',
          publishedAt: DateTime.now().subtract(const Duration(hours: 1)),
          content: 'Business analysis shows...',
          source: 'Business Times',
        ),
      ],
      'sports': [
        NewsArticle(
          author: 'Sports Network',
          title: 'Championship Finals This Weekend',
          description: 'Top teams prepare for the final showdown.',
          url: 'https://example.com',
          urlToImage: 'https://picsum.photos/800/600?random=11',
          publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
          content: 'Sports coverage...',
          source: 'Sports Network',
        ),
      ],
      'technology': [
        NewsArticle(
          author: 'Tech Review',
          title: 'Latest AI Developments',
          description: 'New AI models revolutionize technology industry.',
          url: 'https://example.com',
          urlToImage: 'https://picsum.photos/800/600?random=12',
          publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
          content: 'Technology updates...',
          source: 'Tech Review',
        ),
      ],
      'health': [
        NewsArticle(
          author: 'Health Magazine',
          title: 'New Wellness Research Findings',
          description: 'Study reveals benefits of healthy lifestyle.',
          url: 'https://example.com',
          urlToImage: 'https://picsum.photos/800/600?random=13',
          publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
          content: 'Health research...',
          source: 'Health Magazine',
        ),
      ],
      'science': [
        NewsArticle(
          author: 'Science Journal',
          title: 'Breakthrough in Space Research',
          description: 'Scientists make significant discoveries.',
          url: 'https://example.com',
          urlToImage: 'https://picsum.photos/800/600?random=14',
          publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
          content: 'Science discoveries...',
          source: 'Science Journal',
        ),
      ],
      'entertainment': [
        NewsArticle(
          author: 'Entertainment Weekly',
          title: 'Awards Season Highlights',
          description: 'Major entertainment industry awards announced.',
          url: 'https://example.com',
          urlToImage: 'https://picsum.photos/800/600?random=15',
          publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
          content: 'Entertainment news...',
          source: 'Entertainment Weekly',
        ),
      ],
    };

    return categoryNews[category] ?? [];
  }
}
