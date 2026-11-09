import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/favorite_service.dart';
import '../services/news_service.dart';
import 'article_detail_page.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final NewsService _newsService = NewsService();
  final FavoriteService _favoriteService = FavoriteService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _localFilterController = TextEditingController();
  late Future<List<Article>> _newsFuture;
  final List<Article> _favorites = [];
  bool _favoritesLoading = true;
  int _selectedTab = 0;
  String _selectedCategory = 'general';
  String _localKeyword = '';

  final List<Map<String, String>> _categories = [
    {'label': 'Umum', 'value': 'general'},
    {'label': 'Bisnis', 'value': 'business'},
    {'label': 'Hiburan', 'value': 'entertainment'},
    {'label': 'Kesehatan', 'value': 'health'},
    {'label': 'Sains', 'value': 'science'},
    {'label': 'Olahraga', 'value': 'sports'},
    {'label': 'Teknologi', 'value': 'technology'},
  ];

  @override
  void initState() {
    super.initState();
    _newsFuture = _newsService.fetchTopHeadlines();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await _favoriteService.loadFavorites();
    if (!mounted) return;
    setState(() {
      _favorites
        ..clear()
        ..addAll(favorites);
      _favoritesLoading = false;
    });
  }

  Future<void> _toggleFavorite(Article article) async {
    setState(() {
      final index = _favorites.indexWhere((item) => item.url == article.url);
      if (index >= 0) {
        _favorites.removeAt(index);
      } else {
        _favorites.insert(0, article);
      }
    });
    await _favoriteService.saveFavorites(_favorites);
  }

  List<Article> _filterByTitle(List<Article> articles) {
    final keyword = _localKeyword.trim().toLowerCase();
    if (keyword.isEmpty) return articles;
    return articles
        .where((article) => article.title.toLowerCase().contains(keyword))
        .toList();
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _searchController.clear();
      _newsFuture = _newsService.fetchTopHeadlines(category: category);
    });
  }

  void _searchNews() {
    final query = _searchController.text.trim();
    setState(() {
      _newsFuture = query.isEmpty
          ? _newsService.fetchTopHeadlines(category: _selectedCategory)
          : _newsService.searchArticles(query: query);
    });
  }

  void _retryFetch() {
    setState(() {
      _newsFuture = _newsService.fetchTopHeadlines(category: _selectedCategory);
    });
  }

  void _openArticle(Article article, List<Article> articles) {
    final relatedArticles = articles
        .where((item) => item.url != article.url)
        .toList();
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ArticleDetailPage(
          article: article,
          relatedArticles: relatedArticles,
          isFavorite: _isFavorite(article),
          isFavoriteForArticle: _isFavorite,
          onToggleFavorite: _toggleFavorite,
        ),
      ),
    );
  }

  bool _isFavorite(Article article) =>
      _favorites.any((item) => item.url == article.url);

  @override
  void dispose() {
    _searchController.dispose();
    _localFilterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 18,
        title: const Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFE8EEFF),
                borderRadius: BorderRadius.all(Radius.circular(11)),
              ),
              child: Padding(
                padding: EdgeInsets.all(7),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF2457D6),
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: 10),
            Text('News App'),
          ],
        ),
        actions: [
          if (_selectedTab == 0)
            IconButton(
              tooltip: 'Muat ulang berita',
              onPressed: _retryFetch,
              icon: const Icon(Icons.refresh),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _selectedTab == 0 ? _buildHome(theme) : _buildFavorites(theme),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) {
          setState(() => _selectedTab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Favorit',
          ),
        ],
      ),
    );
  }

  Widget _buildHome(ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 17, 18, 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1F4FC7), Color(0xFF4779EF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF315ED0).withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KABAR TERKINI',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.76),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Tetap terhubung\\ndengan dunia.',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              height: 1.12,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Temukan kabar terbaru pilihan untukmu.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.86),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.public_rounded,
                      size: 58,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _searchNews(),
                decoration: InputDecoration(
                  hintText: 'Cari berita...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    tooltip: 'Cari',
                    icon: const Icon(Icons.arrow_forward_rounded),
                    onPressed: _searchNews,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    'Jelajahi topik',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF202B43),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Geser untuk melihat',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _categories.map((category) {
                    final selected = _selectedCategory == category['value'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category['label']!),
                        selected: selected,
                        showCheckmark: false,
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : const Color(0xFF596276),
                          fontWeight: FontWeight.w600,
                        ),
                        selectedColor: const Color(0xFF2457D6),
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: selected
                              ? const Color(0xFF2457D6)
                              : const Color(0xFFE7EAF1),
                        ),
                        onSelected: (_) => _selectCategory(category['value']!),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _localFilterController,
                onChanged: (value) => setState(() => _localKeyword = value),
                decoration: InputDecoration(
                  labelText: 'Filter judul berita',
                  hintText: 'Contoh: AI, technology, sports',
                  prefixIcon: const Icon(Icons.filter_alt_outlined),
                  suffixIcon: IconButton(
                    tooltip: 'Hapus filter',
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _localFilterController.clear();
                      setState(() => _localKeyword = '');
                    },
                  ),
                  isDense: true,
                  filled: false,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Article>>(
            future: _newsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _buildErrorState();
              }
              final articles = snapshot.data ?? [];
              final filteredArticles = _filterByTitle(articles);
              if (filteredArticles.isEmpty) {
                return _buildNoResults(theme);
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                itemCount: filteredArticles.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(4, 2, 4, 12),
                      child: Row(
                        children: [
                          Text(
                            'Headline terbaru',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.35,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8EEFF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${filteredArticles.length} berita',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF2457D6),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final article = filteredArticles[index - 1];
                  return _ArticleCard(
                    article: article,
                    isFavorite: _isFavorite(article),
                    featured: index == 1,
                    onTap: () => _openArticle(article, articles),
                    onToggleFavorite: () => _toggleFavorite(article),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoResults(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFE8EEFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 36,
                color: Color(0xFF2457D6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Berita tidak ditemukan',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Coba kata kunci atau topik lainnya.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavorites(ThemeData theme) {
    if (_favoritesLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bookmark_add_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada berita tersimpan',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Simpan berita yang menarik agar mudah dibaca kembali.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          sliver: SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KOLEKSI PRIBADI',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Berita Favorit',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EEFF),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    '${_favorites.length} tersimpan',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF2457D6),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final article = _favorites[index];
              return _ArticleCard(
                article: article,
                isFavorite: true,
                onTap: () => _openArticle(article, _favorites),
                onToggleFavorite: () => _toggleFavorite(article),
              );
            }, childCount: _favorites.length),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 48),
            const SizedBox(height: 10),
            const Text(
              'Berita gagal dimuat. Periksa koneksi lalu coba lagi.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _retryFetch,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({
    required this.article,
    required this.isFavorite,
    this.featured = false,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final Article article;
  final bool isFavorite;
  final bool featured;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFFE9ECF3)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl.isNotEmpty)
              Stack(
                children: [
                  Image.network(
                    article.imageUrl,
                    width: double.infinity,
                    height: featured ? 220 : 170,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: featured ? 220 : 170,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 34,
                        ),
                      ),
                    ),
                  ),
                  if (featured)
                    Positioned(
                      left: 14,
                      bottom: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2457D6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'HEADLINE',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.94),
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: isFavorite
                            ? 'Hapus dari favorit'
                            : 'Simpan ke favorit',
                        onPressed: onToggleFavorite,
                        icon: Icon(
                          isFavorite ? Icons.bookmark : Icons.bookmark_border,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          article.sourceName.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: const Color(0xFF2457D6),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ),
                      if (article.publishedAt.isNotEmpty)
                        Text(
                          article.publishedAt.split('T').first,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.28,
                      letterSpacing: -0.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.description.isEmpty
                        ? 'Deskripsi tidak tersedia.'
                        : article.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (article.imageUrl.isEmpty)
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        tooltip: isFavorite
                            ? 'Hapus dari favorit'
                            : 'Simpan ke favorit',
                        onPressed: onToggleFavorite,
                        icon: Icon(
                          isFavorite ? Icons.bookmark : Icons.bookmark_border,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
