import 'package:flutter/material.dart';
import '../models/news_article.dart';
import '../services/bookmark_service.dart';
import '../screens/news_detail_screen.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class BookmarksScreenStateKey {
  static VoidCallback? _refreshCallback;

  static void setRefreshCallback(VoidCallback? callback) {
    _refreshCallback = callback;
  }

  static void refresh() {
    _refreshCallback?.call();
  }
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final BookmarkService _bookmarkService = BookmarkService();
  List<NewsArticle> _bookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    BookmarksScreenStateKey.setRefreshCallback(_loadBookmarks);
    _loadBookmarks();
  }

  @override
  void dispose() {
    BookmarksScreenStateKey.setRefreshCallback(null);
    super.dispose();
  }

  void refreshBookmarks() {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bookmarks = await _bookmarkService.getBookmarks();
      setState(() {
        _bookmarks = bookmarks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return DateFormat('MMM d, y').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _removeBookmark(NewsArticle article) async {
    await _bookmarkService.removeBookmark(article);
    _loadBookmarks();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bookmark removed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookmarks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border_outlined,
                    size: 64,
                    color: SageGreenColors.sageGreenLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No bookmarks yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: SageGreenColors.sageGreenDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Save articles to read them later',
                    style: TextStyle(
                      fontSize: 14,
                      color: SageGreenColors.sageGreen,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadBookmarks,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _bookmarks.length,
                itemBuilder: (context, index) {
                  final article = _bookmarks[index];
                  return _BookmarkCard(
                    article: article,
                    formatDate: _formatDate,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NewsDetailScreen(article: article),
                        ),
                      );
                      _loadBookmarks();
                    },
                    onRemove: () => _removeBookmark(article),
                  );
                },
              ),
            ),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  final NewsArticle article;
  final String Function(DateTime?) formatDate;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _BookmarkCard({
    required this.article,
    required this.formatDate,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                if (article.urlToImage != null &&
                    article.urlToImage!.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: article.urlToImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 200,
                        color: SageGreenColors.sageGreenLight30,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 200,
                        color: SageGreenColors.sageGreenLight30,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Source and Date
                      Row(
                        children: [
                          if (article.source != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: SageGreenColors.sageGreen20,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                article.source!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: SageGreenColors.sageGreenDark,
                                ),
                              ),
                            ),
                          const Spacer(),
                          if (article.publishedAt != null)
                            Text(
                              formatDate(article.publishedAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: SageGreenColors.sageGreen,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Title
                      Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (article.description != null &&
                          article.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          article.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: SageGreenColors.sageGreenDark,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            // Bookmark button - positioned at top right
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: SageGreenColors.sageGreenDark80,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onRemove,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.bookmark,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
