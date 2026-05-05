import 'package:flutter/material.dart';
import '../../shared/models/book_model.dart';
import '../../shared/services/book_service.dart';
import '../../core/di/service_locator.dart';
import '../../core/config/app_config.dart';

/// Book Detail Screen
class BookDetailScreen extends StatefulWidget {
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen>
    with SingleTickerProviderStateMixin {
  final BookService _bookService = getIt<BookService>();
  late TabController _tabController;
  Book? _book;
  List<Chapter> _chapters = [];
  bool _isLoading = true;
  bool _hasPurchased = false;
  int _selectedChapterIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookDetail();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookDetail() async {
    setState(() => _isLoading = true);

    final results = await Future.wait([
      _bookService.getBookById(widget.bookId),
      _bookService.getChapters(widget.bookId, status: 'published'),
    ]);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (results[0].success) {
          _book = results[0].data;
        }
        if (results[1].success) {
          _chapters = (results[1].data as PaginatedData<Chapter>).items;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_book == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('加载失败')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildBookInfo()),
          SliverToBoxAdapter(child: _buildTabBar()),
          SliverFillRemaining(child: _buildTabContent()),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            // Book info overlay
            Positioned(
              bottom: 60,
              left: 16,
              right: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Cover
                  Container(
                    width: 120,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _book!.coverUrl != null
                          ? Image.network(
                              _book!.coverUrl!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.menu_book, size: 48),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _book!.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _book!.author?.penName ?? '未知作者',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildStatChip(
                              Icons.visibility,
                              '${_book!.viewCount}',
                            ),
                            const SizedBox(width: 8),
                            _buildStatChip(
                              Icons.star,
                              _book!.ratingAvg.toStringAsFixed(1),
                            ),
                            const SizedBox(width: 8),
                            _buildStatChip(
                              Icons.book,
                              '${_book!.chapterCount}章',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: _shareBook,
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_border),
          onPressed: _addToBookshelf,
        ),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBookInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_book!.isVipOnly)
                _buildTag('VIP专属', Colors.amber),
              if (_book!.isFree) _buildTag('免费', Colors.green),
              _buildTag('${_book!.wordCount}字', Colors.blue),
              _buildTag(_book!.language, Colors.purple),
            ],
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            _book!.description ?? '暂无简介',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Read more
          GestureDetector(
            onTap: () {},
            child: Text(
              '展开全部',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: Theme.of(context).primaryColor,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Theme.of(context).primaryColor,
      tabs: const [
        Tab(text: '目录'),
        Tab(text: '评论'),
        Tab(text: '详情'),
      ],
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildChapterList(),
        _buildCommentList(),
        _buildBookDetails(),
      ],
    );
  }

  Widget _buildChapterList() {
    if (_chapters.isEmpty) {
      return const Center(child: Text('暂无章节'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _chapters.length,
      itemBuilder: (context, index) {
        final chapter = _chapters[index];
        final canRead = _hasPurchased ||
            chapter.isFree ||
            _book!.isFree ||
            (chapter.isVipOnly == false && chapter.price == 0);

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: Text(
            chapter.title,
            style: const TextStyle(fontSize: 15),
          ),
          subtitle: Text(
            '${chapter.wordCount}字',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          trailing: canRead
              ? const Icon(Icons.chevron_right)
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '付费',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
          onTap: () => _openChapter(chapter, index, canRead),
        );
      },
    );
  }

  Widget _buildCommentList() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.comment_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('暂无评论'),
        ],
      ),
    );
  }

  Widget _buildBookDetails() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('作者', _book!.author?.penName ?? '未知'),
          _buildDetailRow('分类', _book!.category?.name ?? '未分类'),
          _buildDetailRow('字数', '${_book!.wordCount}'),
          _buildDetailRow('章节', '${_book!.chapterCount}'),
          _buildDetailRow('评分', '${_book!.ratingAvg} (${_book!.ratingCount}人)'),
          _buildDetailRow('阅读', '${_book!.viewCount}'),
          _buildDetailRow('订阅', '${_book!.subscriberCount}'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _addToBookshelf,
                icon: const Icon(Icons.bookmark_border),
                label: const Text('加入书架'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _startReading,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: const Text('开始阅读'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareBook() {
    // TODO: Implement share functionality
  }

  void _addToBookshelf() {
    // TODO: Implement add to bookshelf
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已加入书架')),
    );
  }

  void _startReading() {
    if (_chapters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无可阅读章节')),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.reader,
      arguments: {
        'bookId': widget.bookId,
        'chapterId': _chapters[0].id,
        'chapterIndex': 0,
      },
    );
  }

  void _openChapter(Chapter chapter, int index, bool canRead) {
    if (canRead) {
      Navigator.pushNamed(
        context,
        AppRoutes.reader,
        arguments: {
          'bookId': widget.bookId,
          'chapterId': chapter.id,
          'chapterIndex': index,
        },
      );
    } else {
      _showPurchaseDialog(chapter, index);
    }
  }

  void _showPurchaseDialog(Chapter chapter, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '解锁章节',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('本章价格: ¥${chapter.price.toStringAsFixed(2)}'),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _purchaseChapter(chapter, index);
                    },
                    child: const Text('立即购买'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _purchaseChapter(Chapter chapter, int index) {
    // TODO: Implement purchase flow
  }
}
