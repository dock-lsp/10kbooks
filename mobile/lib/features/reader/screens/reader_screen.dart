import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/models/book_model.dart';
import '../../../shared/services/book_service.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/config/app_config.dart';

/// Reader Screen - Main reading interface
class ReaderScreen extends StatefulWidget {
  final String bookId;
  final String chapterId;
  final int chapterIndex;

  const ReaderScreen({
    super.key,
    required this.bookId,
    required this.chapterId,
    required this.chapterIndex,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final BookService _bookService = getIt<BookService>();
  final ScrollController _scrollController = ScrollController();

  Chapter? _chapter;
  List<Chapter> _chapters = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _showControls = true;
  bool _isNightMode = false;
  double _fontSize = AppConfig.defaultFontSize;
  double _lineHeight = AppConfig.defaultLineHeight;

  // Reading progress
  double _readProgress = 0;
  int _readPosition = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.chapterIndex;
    _enterImmersiveMode();
    _loadChapter();
  }

  @override
  void dispose() {
    _exitImmersiveMode();
    _scrollController.dispose();
    super.dispose();
  }

  void _enterImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _exitImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  Future<void> _loadChapter() async {
    setState(() => _isLoading = true);

    // Load chapters if not loaded
    if (_chapters.isEmpty) {
      final chaptersResult = await _bookService.getChapters(
        widget.bookId,
        status: 'published',
      );
      if (chaptersResult.success) {
        _chapters = (chaptersResult.data as PaginatedData<Chapter>).items;
      }
    }

    // Load current chapter
    final chapterResult = await _bookService.getChapter(
      widget.bookId,
      widget.chapterId,
    );

    // Load reading progress
    final progressResult = await _bookService.getReadingProgress(widget.bookId);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (chapterResult.success) {
          _chapter = chapterResult.data;
        }
        if (progressResult.success && progressResult.data != null) {
          _readPosition = progressResult.data!.position;
          _readProgress = progressResult.data!.percentage;
        }
      });
    }
  }

  Future<void> _saveProgress() async {
    if (_chapter == null) return;

    await _bookService.updateReadingProgress(
      widget.bookId,
      chapterId: _chapter!.id,
      position: _readPosition,
      percentage: _readProgress,
    );
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _previousChapter() {
    if (_currentIndex > 0) {
      _saveProgress();
      _currentIndex--;
      final chapter = _chapters[_currentIndex];
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.reader,
        arguments: {
          'bookId': widget.bookId,
          'chapterId': chapter.id,
          'chapterIndex': _currentIndex,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已经是第一章了')),
      );
    }
  }

  void _nextChapter() {
    if (_currentIndex < _chapters.length - 1) {
      _saveProgress();
      _currentIndex++;
      final chapter = _chapters[_currentIndex];
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.reader,
        arguments: {
          'bookId': widget.bookId,
          'chapterId': chapter.id,
          'chapterIndex': _currentIndex,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已经是最后一章了')),
      );
    }
  }

  void _openChapterList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildChapterListSheet(),
    );
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildSettingsSheet(),
    );
  }

  void _showAIMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildAISheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isNightMode ? Colors.black : Colors.white,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Content
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(),

            // Top Bar
            if (_showControls) _buildTopBar(),

            // Bottom Bar
            if (_showControls) _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_chapter == null) {
      return const Center(child: Text('加载失败'));
    }

    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 60,
        bottom: MediaQuery.of(context).padding.bottom + 120,
        left: 20,
        right: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chapter Title
          Text(
            _chapter!.title,
            style: TextStyle(
              fontSize: _fontSize + 8,
              fontWeight: FontWeight.bold,
              color: _isNightMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          // Chapter Content
          Text(
            _chapter!.content ?? '暂无内容',
            style: TextStyle(
              fontSize: _fontSize,
              height: _lineHeight,
              color: _isNightMode ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 48),
          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentIndex > 0)
                TextButton.icon(
                  onPressed: _previousChapter,
                  icon: const Icon(Icons.chevron_left),
                  label: Text('上一章'),
                  style: TextButton.styleFrom(
                    foregroundColor: _isNightMode ? Colors.white70 : Colors.grey[700],
                  ),
                )
              else
                const SizedBox(),
              if (_currentIndex < _chapters.length - 1)
                TextButton.icon(
                  onPressed: _nextChapter,
                  icon: const Icon(Icons.chevron_right),
                  label: const Text('下一章'),
                  style: TextButton.styleFrom(
                    foregroundColor: _isNightMode ? Colors.white70 : Colors.grey[700],
                  ),
                )
              else
                const SizedBox(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _isNightMode ? Colors.black : Colors.white,
              _isNightMode ? Colors.black.withOpacity(0.9) : Colors.white.withOpacity(0.9),
              Colors.transparent,
            ],
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: _isNightMode ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              _saveProgress();
              Navigator.pop(context);
            },
          ),
          title: Text(
            '${_currentIndex + 1}/${_chapters.length}',
            style: TextStyle(
              color: _isNightMode ? Colors.white : Colors.black87,
              fontSize: 14,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.list,
                color: _isNightMode ? Colors.white : Colors.black87,
              ),
              onPressed: _openChapterList,
            ),
            IconButton(
              icon: Icon(
                Icons.more_vert,
                color: _isNightMode ? Colors.white : Colors.black87,
              ),
              onPressed: _openSettings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              _isNightMode ? Colors.black : Colors.white,
              _isNightMode ? Colors.black.withOpacity(0.9) : Colors.white.withOpacity(0.9),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    '${(_readProgress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: _isNightMode ? Colors.white70 : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: _readProgress,
                      onChanged: (value) {
                        setState(() => _readProgress = value);
                      },
                      onChangeEnd: (value) {
                        _saveProgress();
                      },
                      activeColor: Theme.of(context).primaryColor,
                      inactiveColor: _isNightMode ? Colors.white24 : Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomButton(
                    icon: Icons.nightlight_round,
                    label: '夜间',
                    isActive: _isNightMode,
                    onTap: () => setState(() => _isNightMode = !_isNightMode),
                    color: _isNightMode,
                  ),
                  _buildBottomButton(
                    icon: Icons.text_fields,
                    label: '字号',
                    onTap: _openSettings,
                    color: _isNightMode,
                  ),
                  _buildBottomButton(
                    icon: Icons.auto_awesome,
                    label: 'AI助手',
                    onTap: _showAIMenu,
                    color: _isNightMode,
                  ),
                  _buildBottomButton(
                    icon: Icons.share,
                    label: '分享',
                    onTap: _shareContent,
                    color: _isNightMode,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required bool color,
    VoidCallback? onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive
                ? Theme.of(context).primaryColor
                : (color ? Colors.white70 : Colors.grey[600]),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? Theme.of(context).primaryColor
                  : (color ? Colors.white70 : Colors.grey[600]),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterListSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: _isNightMode ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: _isNightMode ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '目录',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isNightMode ? Colors.white : Colors.black87,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: _isNightMode ? Colors.white : Colors.black87,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _chapters.length,
              itemBuilder: (context, index) {
                final chapter = _chapters[index];
                final isCurrentChapter = index == _currentIndex;

                return ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCurrentChapter
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isCurrentChapter
                              ? Colors.white
                              : (_isNightMode ? Colors.white70 : Colors.grey[600]),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    chapter.title,
                    style: TextStyle(
                      color: isCurrentChapter
                          ? Theme.of(context).primaryColor
                          : (_isNightMode ? Colors.white : Colors.black87),
                      fontWeight: isCurrentChapter ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    '${chapter.wordCount}字',
                    style: TextStyle(
                      color: _isNightMode ? Colors.white54 : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  trailing: isCurrentChapter
                      ? Icon(
                          Icons.play_circle_filled,
                          color: Theme.of(context).primaryColor,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    if (!isCurrentChapter) {
                      _saveProgress();
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.reader,
                        arguments: {
                          'bookId': widget.bookId,
                          'chapterId': chapter.id,
                          'chapterIndex': index,
                        },
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _isNightMode ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '阅读设置',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _isNightMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          // Font size
          Row(
            children: [
              Text(
                '字号',
                style: TextStyle(
                  color: _isNightMode ? Colors.white70 : Colors.grey[700],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _fontSize > AppConfig.minFontSize
                    ? () => setState(() => _fontSize--)
                    : null,
                color: _isNightMode ? Colors.white : Colors.grey[700],
              ),
              Text(
                '${_fontSize.toInt()}',
                style: TextStyle(
                  color: _isNightMode ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: _fontSize < AppConfig.maxFontSize
                    ? () => setState(() => _fontSize++)
                    : null,
                color: _isNightMode ? Colors.white : Colors.grey[700],
              ),
            ],
          ),
          // Line height
          Row(
            children: [
              Text(
                '行间距',
                style: TextStyle(
                  color: _isNightMode ? Colors.white70 : Colors.grey[700],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _lineHeight > AppConfig.minLineHeight
                    ? () => setState(() => _lineHeight -= 0.1)
                    : null,
                color: _isNightMode ? Colors.white : Colors.grey[700],
              ),
              Text(
                _lineHeight.toStringAsFixed(1),
                style: TextStyle(
                  color: _isNightMode ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: _lineHeight < AppConfig.maxLineHeight
                    ? () => setState(() => _lineHeight += 0.1)
                    : null,
                color: _isNightMode ? Colors.white : Colors.grey[700],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Theme options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildThemeOption('white', '白色', Colors.white, Colors.black87),
              _buildThemeOption('sepia', '护眼', const Color(0xFFF5E6D3), Colors.brown[800]!),
              _buildThemeOption('dark', '夜间', Colors.grey[800]!, Colors.white70),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String key, String label, Color bgColor, Color textColor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isNightMode = key == 'dark';
        });
      },
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isNightMode == (key == 'dark')
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                'Aa',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: _isNightMode ? Colors.white70 : Colors.grey[700],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _isNightMode ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'AI助手',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _isNightMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          _buildAIButton(
            icon: Icons.translate,
            title: '翻译',
            subtitle: '翻译选中文本',
            onTap: () => Navigator.pop(context),
            color: _isNightMode,
          ),
          _buildAIButton(
            icon: Icons.summarize,
            title: '摘要',
            subtitle: '生成章节摘要',
            onTap: () => Navigator.pop(context),
            color: _isNightMode,
          ),
          _buildAIButton(
            icon: Icons.question_answer,
            title: '问答',
            subtitle: '基于内容智能问答',
            onTap: () => Navigator.pop(context),
            color: _isNightMode,
          ),
          _buildAIButton(
            icon: Icons.bookmark_add,
            title: '收藏',
            subtitle: '收藏精彩段落',
            onTap: () => Navigator.pop(context),
            color: _isNightMode,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAIButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool color,
  }) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: color ? Colors.white54 : Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: color ? Colors.white54 : Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  void _shareContent() {
    // TODO: Implement share
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('分享功能开发中')),
    );
  }
}
