import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/news_article.dart';
import '../services/bookmark_service.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

class NewsDetailScreen extends StatefulWidget {
  final NewsArticle article;

  const NewsDetailScreen({super.key, required this.article});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  final BookmarkService _bookmarkService = BookmarkService();
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _checkBookmark();
  }

  Future<void> _checkBookmark() async {
    final isBookmarked = await _bookmarkService.isBookmarked(widget.article);
    setState(() {
      _isBookmarked = isBookmarked;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM d, y • h:mm a').format(date);
  }

  Future<void> _launchURL(String? url) async {
    if (url == null || url.isEmpty) return;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open link')));
      }
    }
  }

  Future<void> _toggleBookmark() async {
    if (_isBookmarked) {
      await _bookmarkService.removeBookmark(widget.article);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Bookmark removed')));
      }
    } else {
      await _bookmarkService.addBookmark(widget.article);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Bookmarked')));
      }
    }
    _checkBookmark();
  }

  Future<void> _shareArticle() async {
    try {
      await Share.share(
        '${widget.article.title}\n\n${widget.article.description ?? ''}\n\n${widget.article.url ?? ''}',
        subject: widget.article.title,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sharing: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background:
                  widget.article.urlToImage != null &&
                      widget.article.urlToImage!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: widget.article.urlToImage!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: SageGreenColors.sageGreenLight30,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: SageGreenColors.sageGreenLight30,
                        child: const Icon(Icons.image_not_supported, size: 64),
                      ),
                    )
                  : Container(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: const Icon(
                        Icons.article,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_outlined),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isBookmarked
                      ? Icons.bookmark_outlined
                      : Icons.bookmark_border_outlined,
                ),
                onPressed: _toggleBookmark,
                tooltip: _isBookmarked ? 'Remove bookmark' : 'Bookmark',
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: _shareArticle,
                tooltip: 'Share',
              ),
            ],
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
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
                            horizontal: 12,
                            vertical: 6,
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
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      const Spacer(),
                      if (widget.article.publishedAt != null)
                        Text(
                          _formatDate(widget.article.publishedAt),
                          style: TextStyle(
                            fontSize: 14,
                            color: SageGreenColors.sageGreen,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    widget.article.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  if (widget.article.author != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 20,
                          color: SageGreenColors.sageGreen,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.article.author!,
                          style: TextStyle(
                            fontSize: 16,
                            color: SageGreenColors.sageGreenDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Description
                  if (widget.article.description != null &&
                      widget.article.description!.isNotEmpty)
                    Text(
                      widget.article.description!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Content
                  if (widget.article.content != null &&
                      widget.article.content!.isNotEmpty)
                    Text(
                      widget.article.content!
                          .replaceAll(RegExp(r'\[.*?\]'), '')
                          .trim(),
                      style: const TextStyle(fontSize: 16, height: 1.6),
                    ),
                  const SizedBox(height: 32),
                  // Read More Button
                  if (widget.article.url != null &&
                      widget.article.url!.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _launchURL(widget.article.url),
                        icon: const Icon(Icons.open_in_new_outlined),
                        label: const Text('Read Full Article'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
