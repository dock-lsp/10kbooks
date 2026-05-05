import 'package:equatable/equatable.dart';
import 'user_model.dart';

/// Book model
class Book extends Equatable {
  final String id;
  final String authorId;
  final Author? author;
  final String title;
  final String? subtitle;
  final String? description;
  final String? coverUrl;
  final Category? category;
  final String? categoryId;
  final double priceChapter;
  final double priceBook;
  final bool isVipOnly;
  final int wordCount;
  final int chapterCount;
  final String status;
  final String auditStatus;
  final String? auditReason;
  final double ratingAvg;
  final int ratingCount;
  final int viewCount;
  final int subscriberCount;
  final String language;
  final bool isSerial;
  final List<Tag>? tags;
  final List<Chapter>? chapters;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Book({
    required this.id,
    required this.authorId,
    this.author,
    required this.title,
    this.subtitle,
    this.description,
    this.coverUrl,
    this.category,
    this.categoryId,
    this.priceChapter = 0,
    this.priceBook = 0,
    this.isVipOnly = false,
    this.wordCount = 0,
    this.chapterCount = 0,
    this.status = 'draft',
    this.auditStatus = 'pending',
    this.auditReason,
    this.ratingAvg = 0,
    this.ratingCount = 0,
    this.viewCount = 0,
    this.subscriberCount = 0,
    this.language = 'zh-CN',
    this.isSerial = true,
    this.tags,
    this.chapters,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isFree => priceBook == 0 && priceChapter == 0;
  bool get isPublished => status == 'published';
  bool get isVipBook => isVipOnly || (chapters?.any((c) => c.isVipOnly) ?? false);

  Book copyWith({
    String? id,
    String? authorId,
    Author? author,
    String? title,
    String? subtitle,
    String? description,
    String? coverUrl,
    Category? category,
    String? categoryId,
    double? priceChapter,
    double? priceBook,
    bool? isVipOnly,
    int? wordCount,
    int? chapterCount,
    String? status,
    String? auditStatus,
    String? auditReason,
    double? ratingAvg,
    int? ratingCount,
    int? viewCount,
    int? subscriberCount,
    String? language,
    bool? isSerial,
    List<Tag>? tags,
    List<Chapter>? chapters,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Book(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      author: author ?? this.author,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      priceChapter: priceChapter ?? this.priceChapter,
      priceBook: priceBook ?? this.priceBook,
      isVipOnly: isVipOnly ?? this.isVipOnly,
      wordCount: wordCount ?? this.wordCount,
      chapterCount: chapterCount ?? this.chapterCount,
      status: status ?? this.status,
      auditStatus: auditStatus ?? this.auditStatus,
      auditReason: auditReason ?? this.auditReason,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      ratingCount: ratingCount ?? this.ratingCount,
      viewCount: viewCount ?? this.viewCount,
      subscriberCount: subscriberCount ?? this.subscriberCount,
      language: language ?? this.language,
      isSerial: isSerial ?? this.isSerial,
      tags: tags ?? this.tags,
      chapters: chapters ?? this.chapters,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      author: json['author'] != null ? Author.fromJson(json['author'] as Map<String, dynamic>) : null,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String?,
      coverUrl: json['coverUrl'] as String?,
      category: json['category'] != null ? Category.fromJson(json['category'] as Map<String, dynamic>) : null,
      categoryId: json['categoryId'] as String?,
      priceChapter: (json['priceChapter'] as num?)?.toDouble() ?? 0,
      priceBook: (json['priceBook'] as num?)?.toDouble() ?? 0,
      isVipOnly: json['isVipOnly'] as bool? ?? false,
      wordCount: json['wordCount'] as int? ?? 0,
      chapterCount: json['chapterCount'] as int? ?? 0,
      status: json['status'] as String? ?? 'draft',
      auditStatus: json['auditStatus'] as String? ?? 'pending',
      auditReason: json['auditReason'] as String?,
      ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0,
      ratingCount: json['ratingCount'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
      subscriberCount: json['subscriberCount'] as int? ?? 0,
      language: json['language'] as String? ?? 'zh-CN',
      isSerial: json['isSerial'] as bool? ?? true,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => Tag.fromJson(e as Map<String, dynamic>)).toList(),
      chapters: (json['chapters'] as List<dynamic>?)?.map((e) => Chapter.fromJson(e as Map<String, dynamic>)).toList(),
      publishedAt: json['publishedAt'] != null ? DateTime.parse(json['publishedAt'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'coverUrl': coverUrl,
      'categoryId': categoryId,
      'priceChapter': priceChapter,
      'priceBook': priceBook,
      'isVipOnly': isVipOnly,
      'wordCount': wordCount,
      'chapterCount': chapterCount,
      'status': status,
      'auditStatus': auditStatus,
      'auditReason': auditReason,
      'ratingAvg': ratingAvg,
      'ratingCount': ratingCount,
      'viewCount': viewCount,
      'subscriberCount': subscriberCount,
      'language': language,
      'isSerial': isSerial,
      'publishedAt': publishedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        authorId,
        author,
        title,
        subtitle,
        description,
        coverUrl,
        category,
        categoryId,
        priceChapter,
        priceBook,
        isVipOnly,
        wordCount,
        chapterCount,
        status,
        auditStatus,
        auditReason,
        ratingAvg,
        ratingCount,
        viewCount,
        subscriberCount,
        language,
        isSerial,
        tags,
        chapters,
        publishedAt,
        createdAt,
        updatedAt,
      ];
}

/// Chapter model
class Chapter extends Equatable {
  final String id;
  final String bookId;
  final Book? book;
  final int chapterNumber;
  final String title;
  final String? content;
  final int wordCount;
  final String priceType;
  final double price;
  final bool isVipOnly;
  final String status;
  final String auditStatus;
  final DateTime? publishedAt;
  final DateTime? scheduledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Chapter({
    required this.id,
    required this.bookId,
    this.book,
    required this.chapterNumber,
    required this.title,
    this.content,
    this.wordCount = 0,
    this.priceType = 'book',
    this.price = 0,
    this.isVipOnly = false,
    this.status = 'draft',
    this.auditStatus = 'pending',
    this.publishedAt,
    this.scheduledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isFree => priceType == 'free' || (!isVipOnly && price == 0);
  bool get isPublished => status == 'published';

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      book: json['book'] != null ? Book.fromJson(json['book'] as Map<String, dynamic>) : null,
      chapterNumber: json['chapterNumber'] as int,
      title: json['title'] as String,
      content: json['content'] as String?,
      wordCount: json['wordCount'] as int? ?? 0,
      priceType: json['priceType'] as String? ?? 'book',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      isVipOnly: json['isVipOnly'] as bool? ?? false,
      status: json['status'] as String? ?? 'draft',
      auditStatus: json['auditStatus'] as String? ?? 'pending',
      publishedAt: json['publishedAt'] != null ? DateTime.parse(json['publishedAt'] as String) : null,
      scheduledAt: json['scheduledAt'] != null ? DateTime.parse(json['scheduledAt'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'chapterNumber': chapterNumber,
      'title': title,
      'content': content,
      'wordCount': wordCount,
      'priceType': priceType,
      'price': price,
      'isVipOnly': isVipOnly,
      'status': status,
      'auditStatus': auditStatus,
      'publishedAt': publishedAt?.toIso8601String(),
      'scheduledAt': scheduledAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        bookId,
        book,
        chapterNumber,
        title,
        content,
        wordCount,
        priceType,
        price,
        isVipOnly,
        status,
        auditStatus,
        publishedAt,
        scheduledAt,
        createdAt,
        updatedAt,
      ];
}

/// Category model
class Category extends Equatable {
  final String id;
  final String name;
  final String nameEn;
  final String? parentId;
  final int level;
  final int sort;
  final List<Category>? children;

  const Category({
    required this.id,
    required this.name,
    required this.nameEn,
    this.parentId,
    this.level = 1,
    this.sort = 0,
    this.children,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEn: json['nameEn'] as String? ?? json['name'] as String,
      parentId: json['parentId'] as String?,
      level: json['level'] as int? ?? 1,
      sort: json['sort'] as int? ?? 0,
      children: (json['children'] as List<dynamic>?)?.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  @override
  List<Object?> get props => [id, name, nameEn, parentId, level, sort, children];
}

/// Tag model
class Tag extends Equatable {
  final String id;
  final String name;
  final int usageCount;

  const Tag({
    required this.id,
    required this.name,
    this.usageCount = 0,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as String,
      name: json['name'] as String,
      usageCount: json['usageCount'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, usageCount];
}

/// Reading Progress model
class ReadingProgress extends Equatable {
  final String bookId;
  final String chapterId;
  final int position;
  final double percentage;
  final int totalChapters;
  final int currentChapter;
  final DateTime lastReadAt;

  const ReadingProgress({
    required this.bookId,
    required this.chapterId,
    required this.position,
    required this.percentage,
    required this.totalChapters,
    required this.currentChapter,
    required this.lastReadAt,
  });

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      bookId: json['bookId'] as String,
      chapterId: json['chapterId'] as String,
      position: json['position'] as int,
      percentage: (json['percentage'] as num).toDouble(),
      totalChapters: json['totalChapters'] as int,
      currentChapter: json['currentChapter'] as int,
      lastReadAt: DateTime.parse(json['lastReadAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        bookId,
        chapterId,
        position,
        percentage,
        totalChapters,
        currentChapter,
        lastReadAt,
      ];
}


/// Comment model
class Comment extends Equatable {
  final String id;
  final String? parentId;
  final String bookId;
  final String? chapterId;
  final User? user;
  final String content;
  final int likeCount;
  final int replyCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Comment({
    required this.id,
    this.parentId,
    required this.bookId,
    this.chapterId,
    this.user,
    required this.content,
    this.likeCount = 0,
    this.replyCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      parentId: json['parentId'] as String?,
      bookId: json['bookId'] as String,
      chapterId: json['chapterId'] as String?,
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
      content: json['content'] as String,
      likeCount: json['likeCount'] as int? ?? 0,
      replyCount: json['replyCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        parentId,
        bookId,
        chapterId,
        user,
        content,
        likeCount,
        replyCount,
        createdAt,
        updatedAt,
      ];
}
