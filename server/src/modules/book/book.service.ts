import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma.service';

@Injectable()
export class BookService {
  constructor(private prisma: PrismaService) {}

  async getBooks(params: {
    categoryId?: string;
    tag?: string;
    keyword?: string;
    sort?: string;
    page?: number;
    size?: number;
    language?: string;
  }) {
    const { categoryId, tag, keyword, sort = 'updatedAt', page = 1, size = 20, language } = params;

    const where: any = {
      status: 'published',
      auditStatus: 'approved',
      deletedAt: null,
    };

    if (categoryId) {
      where.categoryId = categoryId;
    }

    if (keyword) {
      where.OR = [
        { title: { contains: keyword, mode: 'insensitive' } },
        { description: { contains: keyword, mode: 'insensitive' } },
      ];
    }

    if (language) {
      where.language = language;
    }

    const orderBy: any = {};
    switch (sort) {
      case 'rating':
        orderBy.ratingAvg = 'desc';
        break;
      case 'sales':
        orderBy.subscriberCount = 'desc';
        break;
      case 'views':
        orderBy.viewCount = 'desc';
        break;
      case 'new':
        orderBy.publishedAt = 'desc';
        break;
      default:
        orderBy.updatedAt = 'desc';
    }

    const [items, total] = await Promise.all([
      this.prisma.book.findMany({
        where,
        orderBy,
        skip: (page - 1) * size,
        take: size,
        include: {
          author: {
            select: {
              id: true,
              penName: true,
              avatar: true,
            },
          },
          category: true,
          bookTags: {
            include: {
              tag: true,
            },
          },
        },
      }),
      this.prisma.book.count({ where }),
    ]);

    return {
      items: items.map((book) => ({
        id: book.id,
        title: book.title,
        subtitle: book.subtitle,
        description: book.description,
        coverUrl: book.coverUrl,
        authorId: book.authorId,
        authorName: book.author?.penName,
        authorAvatar: book.author?.avatar,
        category: book.category?.name,
        categoryId: book.categoryId,
        tags: book.bookTags.map((bt) => bt.tag.name),
        priceChapter: book.priceChapter,
        priceBook: book.priceBook,
        isVipOnly: book.isVipOnly,
        wordCount: book.wordCount,
        chapterCount: book.chapterCount,
        ratingAvg: book.ratingAvg,
        ratingCount: book.ratingCount,
        viewCount: book.viewCount,
        subscriberCount: book.subscriberCount,
        publishedAt: book.publishedAt,
        createdAt: book.createdAt,
        updatedAt: book.updatedAt,
      })),
      total,
      page,
      size,
      hasMore: page * size < total,
    };
  }

  async getBookDetail(bookId: string, userId?: string) {
    const book = await this.prisma.book.findUnique({
      where: { id: bookId },
      include: {
        author: {
          include: {
            user: {
              select: {
                id: true,
                nickname: true,
                avatar: true,
                bio: true,
              },
            },
          },
        },
        category: true,
        bookTags: {
          include: { tag: true },
        },
        chapters: {
          where: { status: 'published' },
          orderBy: { chapterNumber: 'asc' },
          select: {
            id: true,
            chapterNumber: true,
            title: true,
            wordCount: true,
            priceType: true,
            price: true,
            isVipOnly: true,
            publishedAt: true,
          },
        },
      },
    });

    if (!book) {
      throw new NotFoundException('Book not found');
    }

    // Increment view count
    await this.prisma.book.update({
      where: { id: bookId },
      data: { viewCount: { increment: 1 } },
    });

    // Get user subscription status
    let isSubscribed = false;
    if (userId) {
      const order = await this.prisma.order.findFirst({
        where: {
          userId,
          bookId,
          paymentStatus: 'paid',
        },
      });
      isSubscribed = !!order;
    }

    // Get comments
    const comments = await this.prisma.comment.findMany({
      where: { bookId, parentId: null, status: 'approved' },
      orderBy: { createdAt: 'desc' },
      take: 10,
      include: {
        user: {
          select: { id: true, nickname: true, avatar: true },
        },
      },
    });

    return {
      book: {
        id: book.id,
        title: book.title,
        subtitle: book.subtitle,
        description: book.description,
        coverUrl: book.coverUrl,
        author: {
          id: book.author.user.id,
          penName: book.author.penName,
          avatar: book.author.user.avatar,
          bio: book.author.user.bio,
          totalBooks: book.author.totalBooks,
          totalFans: book.author.totalFans,
        },
        category: book.category?.name,
        tags: book.bookTags.map((bt) => bt.tag.name),
        priceChapter: book.priceChapter,
        priceBook: book.priceBook,
        isVipOnly: book.isVipOnly,
        wordCount: book.wordCount,
        chapterCount: book.chapterCount,
        ratingAvg: book.ratingAvg,
        ratingCount: book.ratingCount,
        viewCount: book.viewCount,
        subscriberCount: book.subscriberCount,
        publishedAt: book.publishedAt,
        createdAt: book.createdAt,
      },
      chapters: book.chapters.map((ch) => ({
        id: ch.id,
        chapterNumber: ch.chapterNumber,
        title: ch.title,
        wordCount: ch.wordCount,
        priceType: ch.priceType,
        price: ch.price,
        isVipOnly: ch.isVipOnly,
        publishedAt: ch.publishedAt,
      })),
      comments: comments.map((c) => ({
        id: c.id,
        content: c.content,
        rating: c.rating,
        user: c.user,
        likeCount: c.likeCount,
        createdAt: c.createdAt,
      })),
      isSubscribed,
    };
  }

  async getChapterContent(
    bookId: string,
    chapterId: string,
    userId?: string,
    skipPayCheck?: boolean,
  ) {
    const chapter = await this.prisma.chapter.findFirst({
      where: { id: chapterId, bookId },
      include: { book: true },
    });

    if (!chapter) {
      throw new NotFoundException('Chapter not found');
    }

    // Check if user has access
    let hasAccess = skipPayCheck || false;

    if (!hasAccess && userId) {
      // Check if user has purchased
      const order = await this.prisma.order.findFirst({
        where: {
          userId,
          OR: [{ bookId }, { chapterId }],
          paymentStatus: 'paid',
        },
      });

      // Check if chapter is free or VIP with active subscription
      hasAccess = chapter.priceType === 'free' || !!order;
    }

    // If VIP only, check user's VIP status
    if (chapter.isVipOnly && userId && !hasAccess) {
      const user = await this.prisma.user.findUnique({
        where: { id: userId },
      });
      hasAccess = user?.vipStatus !== 'none' && user?.vipExpireAt && user.vipExpireAt > new Date();
    }

    return {
      chapter: {
        id: chapter.id,
        chapterNumber: chapter.chapterNumber,
        title: chapter.title,
        content: hasAccess ? chapter.content : null,
        wordCount: chapter.wordCount,
        priceType: chapter.priceType,
        price: chapter.price,
        isVipOnly: chapter.isVipOnly,
      },
      hasAccess,
      book: {
        id: chapter.book.id,
        title: chapter.book.title,
        authorId: chapter.book.authorId,
      },
    };
  }

  async createBook(authorId: string, data: {
    title: string;
    subtitle?: string;
    description?: string;
    categoryId?: string;
    tags?: string[];
    cover?: string;
    language?: string;
  }) {
    const author = await this.prisma.author.findUnique({
      where: { id: authorId },
    });

    if (!author) {
      throw new NotFoundException('Author not found');
    }

    const book = await this.prisma.book.create({
      data: {
        authorId: author.id,
        title: data.title,
        subtitle: data.subtitle,
        description: data.description,
        categoryId: data.categoryId,
        coverUrl: data.cover,
        language: data.language || 'zh-CN',
      },
    });

    // Create tags
    if (data.tags && data.tags.length > 0) {
      for (const tagName of data.tags) {
        const tag = await this.prisma.tag.upsert({
          where: { name: tagName },
          create: { name: tagName },
          update: { usageCount: { increment: 1 } },
        });

        await this.prisma.bookTag.create({
          data: { bookId: book.id, tagId: tag.id },
        });
      }
    }

    // Update author stats
    await this.prisma.author.update({
      where: { id: author.id },
      data: { totalBooks: { increment: 1 } },
    });

    return book;
  }

  async updateReadingProgress(userId: string, data: {
    bookId: string;
    chapterId: string;
    position: number;
    percentage: number;
    currentChapter: number;
    totalChapters: number;
  }) {
    return this.prisma.readingProgress.upsert({
      where: {
        userId_bookId: {
          userId,
          bookId: data.bookId,
        },
      },
      create: {
        userId,
        bookId: data.bookId,
        chapterId: data.chapterId,
        position: data.position,
        percentage: data.percentage,
        currentChapter: data.currentChapter,
        totalChapters: data.totalChapters,
        lastReadAt: new Date(),
      },
      update: {
        chapterId: data.chapterId,
        position: data.position,
        percentage: data.percentage,
        currentChapter: data.currentChapter,
        totalChapters: data.totalChapters,
        lastReadAt: new Date(),
      },
    });
  }
}
