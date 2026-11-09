import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/article.dart';

Future<void> openOriginalArticle(Article article) async {
  final uri = Uri.tryParse(article.url);
  if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
    return;
  }
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class ArticleDetailPage extends StatefulWidget {
  const ArticleDetailPage({
    super.key,
    required this.article,
    this.relatedArticles = const [],
    this.isFavorite = false,
    this.isFavoriteForArticle,
    this.onToggleFavorite,
  });

  final Article article;
  final List<Article> relatedArticles;
  final bool isFavorite;
  final bool Function(Article article)? isFavoriteForArticle;
  final ValueChanged<Article>? onToggleFavorite;

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  late bool _isFavorite = widget.isFavorite;

  void _toggleFavorite(Article article) {
    if (article.url == widget.article.url) {
      setState(() => _isFavorite = !_isFavorite);
    }
    widget.onToggleFavorite?.call(article);
  }

  Future<void> _shareArticle(Article article) async {
    final shareText = article.url.isEmpty
        ? article.title
        : '${article.title}\n${article.url}';
    await SharePlus.instance.share(
      ShareParams(text: shareText, subject: article.title),
    );
  }

  void _openRelatedArticle(Article article) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ArticleDetailPage(
          article: article,
          relatedArticles: widget.relatedArticles
              .where((related) => related.url != article.url)
              .toList(),
          isFavorite: widget.isFavoriteForArticle?.call(article) ?? false,
          isFavoriteForArticle: widget.isFavoriteForArticle,
          onToggleFavorite: widget.onToggleFavorite,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 270,
            title: const Text('Detail Berita'),
            flexibleSpace: FlexibleSpaceBar(
              background: widget.article.imageUrl.isEmpty
                  ? Container(
                      color: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.article_outlined,
                        size: 72,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : Image.network(
                      widget.article.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
            ),
            actions: [
              IconButton(
                tooltip: _isFavorite
                    ? 'Hapus dari favorit'
                    : 'Simpan ke favorit',
                onPressed: () => _toggleFavorite(widget.article),
                icon: Icon(
                  _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                ),
              ),
              IconButton(
                tooltip: 'Bagikan berita',
                onPressed: () => _shareArticle(widget.article),
                icon: const Icon(Icons.share_outlined),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  widget.article.sourceName.toUpperCase(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.article.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.article.publishedAt.isEmpty
                          ? 'Tanggal publikasi tidak tersedia'
                          : 'Dipublikasikan ${widget.article.publishedAt.replaceFirst('T', ' ').split('.').first.replaceFirst('Z', '')}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  widget.article.description.isEmpty
                      ? 'Deskripsi berita tidak tersedia.'
                      : widget.article.description,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.65),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => openOriginalArticle(widget.article),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Baca Artikel Asli'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                if (widget.relatedArticles.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Text(
                    'Berita Terkait',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.relatedArticles.length.clamp(0, 8),
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final article = widget.relatedArticles[index];
                        return _RelatedArticleCard(
                          article: article,
                          onTap: () => _openRelatedArticle(article),
                          onShare: () => _shareArticle(article),
                        );
                      },
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedArticleCard extends StatelessWidget {
  const _RelatedArticleCard({
    required this.article,
    required this.onTap,
    required this.onShare,
  });

  final Article article;
  final VoidCallback onTap;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 235,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.imageUrl.isNotEmpty)
                Image.network(
                  article.imageUrl,
                  width: double.infinity,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                )
              else
                Container(
                  height: 100,
                  color: theme.colorScheme.primaryContainer,
                  child: Center(
                    child: Icon(
                      Icons.article_outlined,
                      color: theme.colorScheme.primary,
                      size: 36,
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 4, 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.sourceName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              article.title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Bagikan berita',
                        visualDensity: VisualDensity.compact,
                        onPressed: onShare,
                        icon: const Icon(Icons.share_outlined, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
