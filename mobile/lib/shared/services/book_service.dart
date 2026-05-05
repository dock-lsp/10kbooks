import '../../core/network/api_client.dart';
import '../../core/network/storage_service.dart';
import '../models/book_model.dart';

/// Book Service
class BookService {
  final ApiClient _api;
  final StorageService _storage;

  BookService(this._api, this._storage);

  // Get book list
  Future<ApiResult<PaginatedData<Book>>> getBooks({
    String? categoryId,
    String? category,
    String? tag,
    String? keyword,
    int page = 1,
    int size = 20,
    String? sort,
  }) async {
    try {
      final response = await _api.get('/books', queryParameters: {
        if (categoryId != null) 'categoryId': categoryId,
        if (category != null) 'category': category,
        if (tag != null) 'tag': tag,
        if (keyword != null) 'keyword': keyword,
        'page': page,
        'size': size,
        if (sort != null) 'sort': sort,
      });

      final data = response.data['data'] as Map<String, dynamic>;
      final items = (data['items'] as List)
          .map((e) => Book.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResult.success(PaginatedData(
        items: items,
        total: data['total'] as int,
        page: data['page'] as int,
        size: data['size'] as int,
      ));
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Get book by ID
  Future<ApiResult<Book>> getBookById(String bookId) async {
    try {
      final response = await _api.get('/books/$bookId');
      final book = Book.fromJson(response.data['data'] as Map<String, dynamic>);
      return ApiResult.success(book);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Get chapters
  Future<ApiResult<PaginatedData<Chapter>>> getChapters(
    String bookId, {
    String? status,
    int page = 1,
    int size = 50,
  }) async {
    try {
      final response = await _api.get('/books/$bookId/chapters', queryParameters: {
        if (status != null) 'status': status,
        'page': page,
        'size': size,
      });

      final data = response.data['data'] as Map<String, dynamic>;
      final items = (data['items'] as List)
          .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResult.success(PaginatedData(
        items: items,
        total: data['total'] as int,
        page: data['page'] as int,
        size: data['size'] as int,
      ));
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Get chapter content
  Future<ApiResult<Chapter>> getChapter(
    String bookId,
    String chapterId, {
    bool skipPay = false,
  }) async {
    try {
      final response = await _api.get(
        '/books/$bookId/chapters/$chapterId',
        queryParameters: {'skipPay': skipPay},
      );
      final chapter = Chapter.fromJson(response.data['data'] as Map<String, dynamic>);
      return ApiResult.success(chapter);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Get chapter content (wrapper for reader bloc compatibility)
  Future<Map<String, dynamic>> getChapterContent(
    String bookId, {
    String? chapterId,
  }) async {
    final targetChapterId = chapterId ?? '';
    if (targetChapterId.isEmpty) {
      // Get first chapter
      final chaptersResult = await getChapters(bookId);
      if (chaptersResult.success && chaptersResult.data != null && chaptersResult.data!.items.isNotEmpty) {
        final firstChapter = chaptersResult.data!.items.first;
        final chapterResult = await getChapter(bookId, firstChapter.id);
        return {
          'chapter': chapterResult.data!.toJson(),
          'book': null,
          'chapters': chaptersResult.data!.items.map((c) => c.toJson()).toList(),
        };
      }
      throw Exception('No chapters found');
    }
    final chapterResult = await getChapter(bookId, targetChapterId);
    return {
      'chapter': chapterResult.data!.toJson(),
    };
  }

  // Search books
  Future<ApiResult<PaginatedData<Book>>> searchBooks({
    required String keyword,
    int page = 1,
    int size = 20,
  }) async {
    try {
      final response = await _api.get('/books', queryParameters: {
        'keyword': keyword,
        'page': page,
        'size': size,
      });

      final data = response.data['data'] as Map<String, dynamic>;
      final items = (data['items'] as List)
          .map((e) => Book.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResult.success(PaginatedData(
        items: items,
        total: data['total'] as int,
        page: data['page'] as int,
        size: data['size'] as int,
      ));
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Get reading progress
  Future<ApiResult<ReadingProgress>> getReadingProgress(String bookId) async {
    try {
      final response = await _api.get('/reading/$bookId/progress');
      final progress = ReadingProgress.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
      return ApiResult.success(progress);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Update reading progress
  Future<ApiResult<bool>> updateReadingProgress(
    String bookId, {
    required String chapterId,
    required int position,
    required double percentage,
    int currentChapter = 0,
    int totalChapters = 0,
  }) async {
    try {
      final response = await _api.put('/reading/$bookId/progress', data: {
        'chapterId': chapterId,
        'position': position,
        'percentage': percentage,
      });

      // Save locally as backup
      await _storage.saveReadingProgress(bookId, {
        'chapterId': chapterId,
        'position': position,
        'percentage': percentage,
        'lastReadAt': DateTime.now().toIso8601String(),
      });

      return ApiResult.success(response.data['success'] as bool);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Get categories
  Future<ApiResult<List<Category>>> getCategories() async {
    try {
      final response = await _api.get('/categories');
      final categories = (response.data['data'] as List)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResult.success(categories);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Get book detail with chapters, comments, and recommendations
  Future<ApiResult<Map<String, dynamic>>> getBookDetail(String bookId) async {
    try {
      final response = await _api.get('/books/$bookId/detail');
      final data = response.data['data'] as Map<String, dynamic>;
      return ApiResult.success(data);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Create a new book
  Future<ApiResult<Book>> createBook(Map<String, dynamic> data) async {
    try {
      final response = await _api.post('/books', data: data);
      final book = Book.fromJson(response.data['data'] as Map<String, dynamic>);
      return ApiResult.success(book);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Update a book
  Future<ApiResult<Book>> updateBook(String bookId, Map<String, dynamic> data) async {
    try {
      final response = await _api.patch('/books/$bookId', data: data);
      final book = Book.fromJson(response.data['data'] as Map<String, dynamic>);
      return ApiResult.success(book);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Delete a book
  Future<ApiResult<bool>> deleteBook(String bookId) async {
    try {
      await _api.delete('/books/$bookId');
      return ApiResult.success(true);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Publish a book
  Future<ApiResult<Book>> publishBook(String bookId) async {
    try {
      final response = await _api.post('/books/$bookId/publish');
      final book = Book.fromJson(response.data['data'] as Map<String, dynamic>);
      return ApiResult.success(book);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Translate content using AI
  Future<String> translateContent(String content, {String targetLang = 'en'}) async {
    try {
      final response = await _api.post('/ai/translate', data: {
        'content': content,
        'targetLang': targetLang,
      });
      return response.data['data']['translated'] as String;
    } catch (e) {
      return 'Translation unavailable: $e';
    }
  }

  // Summarize content using AI
  Future<String> summarizeContent(String content) async {
    try {
      final response = await _api.post('/ai/summarize', data: {'content': content});
      return response.data['data']['summary'] as String;
    } catch (e) {
      return 'Summary unavailable: $e';
    }
  }

  // Answer question about book content using AI
  Future<String> answerQuestion({
    required String bookId,
    required String question,
    required String context,
  }) async {
    try {
      final response = await _api.post('/ai/qa', data: {
        'bookId': bookId,
        'question': question,
        'context': context,
      });
      return response.data['data']['answer'] as String;
    } catch (e) {
      return 'Answer unavailable: $e';
    }
  }
}

/// Paginated data wrapper
class PaginatedData<T> {
  final List<T> items;
  final int total;
  final int page;
  final int size;

  PaginatedData({
    required this.items,
    required this.total,
    required this.page,
    required this.size,
  });

  int get totalPages => (total / size).ceil();
  bool get hasMore => page < totalPages;
}
