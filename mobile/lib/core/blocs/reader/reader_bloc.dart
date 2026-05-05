import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../shared/models/book_model.dart';
import '../../shared/services/book_service.dart';
import '../../core/di/service_locator.dart';

// Events
abstract class ReaderEvent extends Equatable {
  const ReaderEvent();

  @override
  List<Object?> get props => [];
}

class ReaderChapterRequested extends ReaderEvent {
  final String bookId;
  final String? chapterId;

  const ReaderChapterRequested({
    required this.bookId,
    this.chapterId,
  });

  @override
  List<Object?> get props => [bookId, chapterId];
}

class ReaderChapterChanged extends ReaderEvent {
  final String chapterId;
  final int position;

  const ReaderChapterChanged({
    required this.chapterId,
    required this.position,
  });

  @override
  List<Object?> get props => [chapterId, position];
}

class ReaderProgressUpdated extends ReaderEvent {
  final String bookId;
  final String chapterId;
  final int position;
  final double percentage;
  final int currentChapter;
  final int totalChapters;

  const ReaderProgressUpdated({
    required this.bookId,
    required this.chapterId,
    required this.position,
    required this.percentage,
    required this.currentChapter,
    required this.totalChapters,
  });

  @override
  List<Object?> get props => [bookId, chapterId, position, percentage, currentChapter, totalChapters];
}

class ReaderSettingsChanged extends ReaderEvent {
  final ReaderSettings settings;

  const ReaderSettingsChanged({required this.settings});

  @override
  List<Object?> get props => [settings];
}

class ReaderAiActionRequested extends ReaderEvent {
  final String action; // translate, summarize, qa
  final String content;
  final String? bookId;
  final String? question;

  const ReaderAiActionRequested({
    required this.action,
    required this.content,
    this.bookId,
    this.question,
  });

  @override
  List<Object?> get props => [action, content, bookId, question];
}

// Reader Settings
class ReaderSettings extends Equatable {
  final double fontSize;
  final double lineHeight;
  final String fontFamily;
  final String backgroundColor;
  final bool isNightMode;
  final String readingMode; // scroll, page
  final String pageAnimation;

  const ReaderSettings({
    this.fontSize = 16,
    this.lineHeight = 1.5,
    this.fontFamily = 'system',
    this.backgroundColor = '#FFFFFF',
    this.isNightMode = false,
    this.readingMode = 'scroll',
    this.pageAnimation = 'none',
  });

  ReaderSettings copyWith({
    double? fontSize,
    double? lineHeight,
    String? fontFamily,
    String? backgroundColor,
    bool? isNightMode,
    String? readingMode,
    String? pageAnimation,
  }) {
    return ReaderSettings(
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      fontFamily: fontFamily ?? this.fontFamily,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      isNightMode: isNightMode ?? this.isNightMode,
      readingMode: readingMode ?? this.readingMode,
      pageAnimation: pageAnimation ?? this.pageAnimation,
    );
  }

  @override
  List<Object?> get props => [fontSize, lineHeight, fontFamily, backgroundColor, isNightMode, readingMode, pageAnimation];
}

// States
abstract class ReaderState extends Equatable {
  const ReaderState();

  @override
  List<Object?> get props => [];
}

class ReaderInitial extends ReaderState {}

class ReaderLoading extends ReaderState {}

class ReaderLoaded extends ReaderState {
  final BookModel book;
  final ChapterModel chapter;
  final List<ChapterModel> chapters;
  final ReadingProgress? progress;
  final ReaderSettings settings;
  final bool showSettings;

  const ReaderLoaded({
    required this.book,
    required this.chapter,
    this.chapters = const [],
    this.progress,
    this.settings = const ReaderSettings(),
    this.showSettings = false,
  });

  ReaderLoaded copyWith({
    BookModel? book,
    ChapterModel? chapter,
    List<ChapterModel>? chapters,
    ReadingProgress? progress,
    ReaderSettings? settings,
    bool? showSettings,
  }) {
    return ReaderLoaded(
      book: book ?? this.book,
      chapter: chapter ?? this.chapter,
      chapters: chapters ?? this.chapters,
      progress: progress ?? this.progress,
      settings: settings ?? this.settings,
      showSettings: showSettings ?? this.showSettings,
    );
  }

  @override
  List<Object?> get props => [book, chapter, chapters, progress, settings, showSettings];
}

class ReaderAiResult extends ReaderState {
  final String action;
  final String result;

  const ReaderAiResult({required this.action, required this.result});

  @override
  List<Object?> get props => [action, result];
}

class ReaderError extends ReaderState {
  final String message;

  const ReaderError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Reading Progress
class ReadingProgress extends Equatable {
  final String bookId;
  final String chapterId;
  final int position;
  final double percentage;
  final int currentChapter;
  final int totalChapters;
  final DateTime lastReadAt;

  const ReadingProgress({
    required this.bookId,
    required this.chapterId,
    required this.position,
    required this.percentage,
    required this.currentChapter,
    required this.totalChapters,
    required this.lastReadAt,
  });

  @override
  List<Object?> get props => [bookId, chapterId, position, percentage, currentChapter, totalChapters, lastReadAt];
}

// BLoC
class ReaderBloc extends Bloc<ReaderEvent, ReaderState> {
  final BookService _bookService;

  ReaderBloc({BookService? bookService})
      : _bookService = bookService ?? getIt<BookService>(),
        super(ReaderInitial()) {
    on<ReaderChapterRequested>(_onChapterRequested);
    on<ReaderChapterChanged>(_onChapterChanged);
    on<ReaderProgressUpdated>(_onProgressUpdated);
    on<ReaderSettingsChanged>(_onSettingsChanged);
    on<ReaderAiActionRequested>(_onAiActionRequested);
  }

  Future<void> _onChapterRequested(
    ReaderChapterRequested event,
    Emitter<ReaderState> emit,
  ) async {
    emit(ReaderLoading());
    try {
      final result = await _bookService.getChapterContent(
        event.bookId,
        chapterId: event.chapterId,
      );

      final chapter = ChapterModel.fromJson(result['chapter'] as Map<String, dynamic>);
      final book = result['book'] != null
          ? BookModel.fromJson(result['book'] as Map<String, dynamic>)
          : null;
      final chapters = (result['chapters'] as List?)
              ?.map((json) => ChapterModel.fromJson(json as Map<String, dynamic>))
              .toList() ??
          [];

      ReadingProgress? progress;
      if (result['progress'] != null) {
        final p = result['progress'] as Map<String, dynamic>;
        progress = ReadingProgress(
          bookId: p['bookId'] as String,
          chapterId: p['chapterId'] as String,
          position: p['position'] as int,
          percentage: (p['percentage'] as num).toDouble(),
          currentChapter: p['currentChapter'] as int,
          totalChapters: p['totalChapters'] as int,
          lastReadAt: DateTime.parse(p['lastReadAt'] as String),
        );
      }

      emit(ReaderLoaded(
        book: book!,
        chapter: chapter,
        chapters: chapters,
        progress: progress,
      ));
    } catch (e) {
      emit(ReaderError(message: e.toString()));
    }
  }

  Future<void> _onChapterChanged(
    ReaderChapterChanged event,
    Emitter<ReaderState> emit,
  ) async {
    if (state is! ReaderLoaded) return;

    final currentState = state as ReaderLoaded;
    emit(ReaderLoading());

    try {
      final result = await _bookService.getChapterContent(
        currentState.book.id,
        chapterId: event.chapterId,
      );

      final chapter = ChapterModel.fromJson(result['chapter'] as Map<String, dynamic>);

      emit(currentState.copyWith(
        chapter: chapter,
        position: event.position,
      ));
    } catch (e) {
      emit(ReaderError(message: e.toString()));
    }
  }

  Future<void> _onProgressUpdated(
    ReaderProgressUpdated event,
    Emitter<ReaderState> emit,
  ) async {
    try {
      await _bookService.updateReadingProgress(
        bookId: event.bookId,
        chapterId: event.chapterId,
        position: event.position,
        percentage: event.percentage,
        currentChapter: event.currentChapter,
        totalChapters: event.totalChapters,
      );

      if (state is ReaderLoaded) {
        final currentState = state as ReaderLoaded;
        emit(currentState.copyWith(
          progress: ReadingProgress(
            bookId: event.bookId,
            chapterId: event.chapterId,
            position: event.position,
            percentage: event.percentage,
            currentChapter: event.currentChapter,
            totalChapters: event.totalChapters,
            lastReadAt: DateTime.now(),
          ),
        ));
      }
    } catch (_) {
      // Silently fail for progress updates
    }
  }

  void _onSettingsChanged(
    ReaderSettingsChanged event,
    Emitter<ReaderState> emit,
  ) {
    if (state is! ReaderLoaded) return;

    final currentState = state as ReaderLoaded;
    emit(currentState.copyWith(
      settings: event.settings,
      showSettings: false,
    ));
  }

  Future<void> _onAiActionRequested(
    ReaderAiActionRequested event,
    Emitter<ReaderState> emit,
  ) async {
    if (state is! ReaderLoaded) return;

    final currentState = state as ReaderLoaded;

    try {
      String result;
      switch (event.action) {
        case 'translate':
          result = await _bookService.translateContent(event.content);
          break;
        case 'summarize':
          result = await _bookService.summarizeContent(event.content);
          break;
        case 'qa':
          result = await _bookService.answerQuestion(
            bookId: event.bookId!,
            question: event.question!,
            context: event.content,
          );
          break;
        default:
          throw Exception('Unknown AI action');
      }

      emit(ReaderAiResult(action: event.action, result: result));
      emit(currentState);
    } catch (e) {
      emit(ReaderError(message: e.toString()));
      emit(currentState);
    }
  }
}