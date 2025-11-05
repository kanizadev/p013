import 'dart:async';
import 'package:flutter/material.dart';
import '../models/news_article.dart';
import '../services/news_service.dart';
import '../services/bookmark_service.dart';
import '../screens/news_detail_screen.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';

class NewsListScreen extends StatefulWidget {
  final VoidCallback? onThemeToggle;
  final bool? isDarkMode;

  const NewsListScreen({super.key, this.onThemeToggle, this.isDarkMode});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen>
    with SingleTickerProviderStateMixin {
  final NewsService _newsService = NewsService();
  final BookmarkService _bookmarkService = BookmarkService();
  final ScrollController _scrollController = ScrollController();

  List<NewsArticle> _articles = [];
  List<NewsArticle> _allArticles = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _selectedCategory = 'general';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: NewsCategories.categories.length,
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);
    _loadNews();
    _scrollController.addListener(_onScroll);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _selectedCategory = NewsCategories.categories[_tabController.index];
      _loadNews();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreNews();
    }
  }

  Future<void> _loadNews({bool refresh = false}) async {
    if (refresh) {
      _allArticles.clear();
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final articles = await _newsService.getTopHeadlines(
        category: _selectedCategory,
      );
      setState(() {
        _allArticles = articles;
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadMoreNews() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      // Simulate loading more (in real app, you'd fetch next page)
      await Future.delayed(const Duration(seconds: 1));

      // For demo, we'll just duplicate articles
      // In production, implement proper pagination
      final moreArticles = await _newsService.getTopHeadlines(
        category: _selectedCategory,
      );

      setState(() {
        _allArticles.addAll(moreArticles);
        _articles = List.from(_allArticles);
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (value.isEmpty) {
        setState(() {
          _articles = List.from(_allArticles);
        });
      } else {
        _searchNews(value);
      }
    });
  }

  Future<void> _searchNews(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final articles = await _newsService.searchNews(query);
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _toggleBookmark(NewsArticle article) async {
    final isBookmarked = await _bookmarkService.isBookmarked(article);

    if (isBookmarked) {
      await _bookmarkService.removeBookmark(article);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Bookmark removed')));
      }
    } else {
      await _bookmarkService.addBookmark(article);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Bookmarked')));
      }
    }
    setState(() {});
  }

  Future<void> _shareArticle(NewsArticle article) async {
    try {
      await Share.share(
        '${article.title}\n\n${article.description ?? ''}\n\n${article.url ?? ''}',
        subject: article.title,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sharing: $e')));
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'News App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (widget.onThemeToggle != null)
            IconButton(
              icon: Icon(
                widget.isDarkMode == true
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              onPressed: widget.onThemeToggle,
              tooltip: 'Toggle Theme',
            ),
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => _loadNews(refresh: true),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search news...',
                prefixIcon: const Icon(Icons.search_outlined),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_outlined),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _articles = List.from(_allArticles);
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          // Category Tabs
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: NewsCategories.categories
                .map((cat) => Tab(text: NewsCategories.getCategoryLabel(cat)))
                .toList(),
          ),
          // News List
          Expanded(
            child: _isLoading && _articles.isEmpty
                ? _buildSkeletonLoader()
                : _hasError && _articles.isEmpty
                ? _buildErrorWidget()
                : _articles.isEmpty
                ? _buildEmptyWidget()
                : RefreshIndicator(
                    onRefresh: () => _loadNews(refresh: true),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _articles.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _articles.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final article = _articles[index];
                        return _NewsCard(
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
                          },
                          onBookmark: () => _toggleBookmark(article),
                          onShare: () => _shareArticle(article),
                          bookmarkService: _bookmarkService,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => _SkeletonCard(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error loading news',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: SageGreenColors.sageGreenDark,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: SageGreenColors.sageGreen,
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadNews(),
              icon: const Icon(Icons.refresh_outlined),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: SageGreenColors.sageGreenLight,
          ),
          const SizedBox(height: 16),
          Text(
            'No news found',
            style: TextStyle(fontSize: 18, color: SageGreenColors.sageGreen),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

class _NewsCard extends StatefulWidget {
  final NewsArticle article;
  final String Function(DateTime?) formatDate;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  final VoidCallback onShare;
  final BookmarkService bookmarkService;

  const _NewsCard({
    required this.article,
    required this.formatDate,
    required this.onTap,
    required this.onBookmark,
    required this.onShare,
    required this.bookmarkService,
  });

  @override
  State<_NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<_NewsCard> {
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _checkBookmark();
  }

  Future<void> _checkBookmark() async {
    final isBookmarked = await widget.bookmarkService.isBookmarked(
      widget.article,
    );
    setState(() {
      _isBookmarked = isBookmarked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (widget.article.urlToImage != null &&
                widget.article.urlToImage!.isNotEmpty)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.article.urlToImage!,
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
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _isBookmarked
                                ? Icons.bookmark_outlined
                                : Icons.bookmark_border_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            widget.onBookmark();
                            _checkBookmark();
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(
                            Icons.share_outlined,
                            color: Colors.white,
                          ),
                          onPressed: widget.onShare,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                      if (widget.article.source != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.article.source!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      const Spacer(),
                      if (widget.article.publishedAt != null)
                        Text(
                          widget.formatDate(widget.article.publishedAt),
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
                    widget.article.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.article.description != null &&
                      widget.article.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.article.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: SageGreenColors.sageGreenDark,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (widget.article.author != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: SageGreenColors.sageGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.article.author!,
                          style: TextStyle(
                            fontSize: 12,
                            color: SageGreenColors.sageGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            color: SageGreenColors.sageGreenLight30,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12,
                  width: 80,
                  color: SageGreenColors.sageGreenLight30,
                ),
                const SizedBox(height: 12),
                Container(
                  height: 16,
                  width: double.infinity,
                  color: SageGreenColors.sageGreenLight30,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 16,
                  width: double.infinity,
                  color: SageGreenColors.sageGreenLight30,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 200,
                  color: SageGreenColors.sageGreenLight30,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
