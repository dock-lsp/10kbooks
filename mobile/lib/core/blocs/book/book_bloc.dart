import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../shared/models/book_model.dart';
import '../../../shared/services/book_service.dart';
import '../../di/service_locator.dart';

// Events
abstract class BookEvent extends Equatable {
  const BookEvent();

  @override
  List<Object?> get props => [];
}

class BookListRequested extends BookEvent {
  final String? categoryId;
  final String? tag;
  final String? keyword;
  final String? sort;
  final int page;
  final int size;

  const BookListRequested({
    this.categoryId,
    this.tag,
    this.keyword,
    this.sort,
    this.page = 1,
    this.size = 20,
  });

  @override
  List<Object?> get props => [categoryId, tag, keyword, sort, page, size];
}

class BookDetailRequested extends BookEvent {
  final String bookId;

  const BookDetailRequested({required this.bookId});

  @override
  List<Object?> get props => [bookId];
}

class BookCreateRequested extends BookEvent {
  final String title;
  final String? subtitle;
  final String? description;
  final String? categoryId;
  final List<String>? tags;
  final String? cover;
  final String? language;

  const BookCreateRequested({
    required this.title,
    this.subtitle,
    this.description,
    this.categoryId,
    this.tags,
    this.cover,
    this.language,
  });

  @override
  List<Object?> get props => [title, subtitle, description, categoryId, tags, cover, language];
}

class BookUpdateRequested extends BookEvent {
  final String bookId;
  final String? title;
  final String? subtitle;
  final String? description;
  final String? categoryId;
  final List<String>? tags;
  final String? cover;
  final String? language;

  const BookUpdateRequested({
    required this.bookId,
    this.title,
    this.subtitle,
    this.description,
    this.categoryId,
    this.tags,
    this.cover,
    this.language,
  });

  @override
  List<Object?> get props => [bookId, title, subtitle, description, categoryId, tags, cover, language];
}

class BookDeleteRequested extends BookEvent {
  final String bookId;

  const BookDeleteRequested({required this.bookId});

  @override
  List<Object?> get props => [bookId];
}

class BookPublishRequested extends BookEvent {
  final String bookId;

  const BookPublishRequested({required this.bookId});

  @override
  List<Object?> get props => [bookId];
}

// States
abstract class BookState extends Equatable {
  const BookState();

  @override
  List<Object?> get props => [];
}

class BookInitial extends BookState {}

class BookLoading extends BookState {}

class BookListLoaded extends BookState {
  final List<Book> books;
  final int total;
  final int page;
  final int size;
  final bool hasMore;

  const BookListLoaded({
    required this.books,
    required this.total,
    required this.page,
    required this.size,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [books, total, page, size, hasMore];
}

class BookDetailLoaded extends BookState {
  final Book book;
  final List<Chapter> chapters;
  final List<Comment> comments;
  final List<Book> recommendations;

  const BookDetailLoaded({
    required this.book,
    this.chapters = const [],
    this.comments = const [],
    this.recommendations = const [],
  });

  @override
  List<Object?> get props => [book, chapters, comments, recommendations];
}

class BookOperationSuccess extends BookState {
  final String message;
  final Book? book;

  const BookOperationSuccess({required this.message, this.book});

  @override
  List<Object?> get props => [message, book];
}

class BookError extends BookState {
  final String message;
  final int? code;

  const BookError({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

// BLoC
class BookBloc extends Bloc<BookEvent, BookState> {
  final BookService _bookService;

  BookBloc({BookService? bookService})
      : _bookService = bookService ?? getIt<BookService>(),
        super(BookInitial()) {
    on<BookListRequested>(_onListRequested);
    on<BookDetailRequested>(_onDetailRequested);
    on<BookCreateRequested>(_onCreateRequested);
    on<BookUpdateRequested>(_onUpdateRequested);
    on<BookDeleteRequested>(_onDeleteRequested);
    on<BookPublishRequested>(_onPublishRequested);
  }

  Future<void> _onListRequested(
    BookListRequested event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());
    try {
      final result = await _bookService.getBooks(
        categoryId: event.categoryId,
        tag: event.tag,
        keyword: event.keyword,
        sort: event.sort,
        page: event.page,
        size: event.size,
      );

      if (!result.success || result.data == null) {
        throw Exception(result.message ?? 'Failed to load books');
      }

      final data = result.data!;
      final books = data.items;
      final total = data.total;
      final hasMore = event.page * event.size < total;

      emit(BookListLoaded(
        books: books,
        total: total,
        page: event.page,
        size: event.size,
        hasMore: hasMore,
      ));
    } catch (e) {
      emit(BookError(message: e.toString()));
    }
  }

  Future<void> _onDetailRequested(
    BookDetailRequested event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());
    try {
      final result = await _bookService.getBookDetail(event.bookId);

      if (!result.success || result.data == null) {
        throw Exception(result.message ?? 'Failed to load book detail');
      }

      final data = result.data!;
      final book = Book.fromJson(data['book'] as Map<String, dynamic>);
      final chapters = (data['chapters'] as List?)
              ?.map((json) => Chapter.fromJson(json as Map<String, dynamic>))
              .toList() ??
          [];
      final comments = (data['comments'] as List?)
              ?.map((json) => Comment.fromJson(json as Map<String, dynamic>))
              .toList() ??
          [];
      final recommendations = (data['recommendations'] as List?)
              ?.map((json) => Book.fromJson(json as Map<String, dynamic>))
              .toList() ??
          [];

      emit(BookDetailLoaded(
        book: book,
        chapters: chapters,
        comments: comments,
        recommendations: recommendations,
      ));
    } catch (e) {
      emit(BookError(message: e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    BookCreateRequested event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());
    try {
      final data = {
        'title': event.title,
        if (event.subtitle != null) 'subtitle': event.subtitle,
        if (event.description != null) 'description': event.description,
        if (event.categoryId != null) 'categoryId': event.categoryId,
        if (event.tags != null) 'tags': event.tags,
        if (event.cover != null) 'cover': event.cover,
        if (event.language != null) 'language': event.language,
      };

      final result = await _bookService.createBook(data);

      if (!result.success || result.data == null) {
        throw Exception(result.message ?? 'Failed to create book');
      }

      final book = result.data!;
      emit(BookOperationSuccess(message: 'Book created successfully', book: book));
    } catch (e) {
      emit(BookError(message: e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    BookUpdateRequested event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());
    try {
      final data = {
        if (event.title != null) 'title': event.title,
        if (event.subtitle != null) 'subtitle': event.subtitle,
        if (event.description != null) 'description': event.description,
        if (event.categoryId != null) 'categoryId': event.categoryId,
        if (event.tags != null) 'tags': event.tags,
        if (event.cover != null) 'cover': event.cover,
        if (event.language != null) 'language': event.language,
      };

      final result = await _bookService.updateBook(event.bookId, data);

      if (!result.success || result.data == null) {
        throw Exception(result.message ?? 'Failed to update book');
      }

      final book = result.data!;
      emit(BookOperationSuccess(message: 'Book updated successfully', book: book));
    } catch (e) {
      emit(BookError(message: e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    BookDeleteRequested event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());
    try {
      final result = await _bookService.deleteBook(event.bookId);

      if (!result.success) {
        throw Exception(result.message ?? 'Failed to delete book');
      }

      emit(const BookOperationSuccess(message: 'Book deleted successfully'));
    } catch (e) {
      emit(BookError(message: e.toString()));
    }
  }

  Future<void> _onPublishRequested(
    BookPublishRequested event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());
    try {
      final result = await _bookService.publishBook(event.bookId);

      if (!result.success || result.data == null) {
        throw Exception(result.message ?? 'Failed to publish book');
      }

      final book = result.data!;
      emit(BookOperationSuccess(message: 'Book published successfully', book: book));
    } catch (e) {
      emit(BookError(message: e.toString()));
    }
  }
}
