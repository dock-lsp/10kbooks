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
    String? category,
    String? tag,
    String? keyword,
    int page = 1,
    int size = 20,
    String? sort,
  }) async {
    try {
      final response = await _api.get('/books', queryParameters: {
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

  // Get book detail
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
