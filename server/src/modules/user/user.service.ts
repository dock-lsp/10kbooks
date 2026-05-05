import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../common/prisma.service';

@Injectable()
export class UserService {
  constructor(private prisma: PrismaService) {}

  async getUserProfile(userId: string, currentUserId?: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        author: true,
      },
    });

    if (!user) {
      return null;
    }

    const [followersCount, followingCount, booksCount] = await Promise.all([
      this.prisma.follow.count({ where: { followingId: userId } }),
      this.prisma.follow.count({ where: { followerId: userId } }),
      this.prisma.book.count({
        where: {
          authorId: user.author?.id,
          status: 'published',
        },
      }),
    ]);

    let isFollowing = false;
    if (currentUserId) {
      const follow = await this.prisma.follow.findUnique({
        where: {
          followerId_followingId: {
            followerId: currentUserId,
            followingId: userId,
          },
        },
      });
      isFollowing = !!follow;
    }

    return {
      user: {
        id: user.id,
        nickname: user.nickname,
        avatar: user.avatar,
        bio: user.bio,
        vipStatus: user.vipStatus,
        vipExpireAt: user.vipExpireAt,
        realAuthStatus: user.realAuthStatus,
        createdAt: user.createdAt,
        isAuthor: !!user.author,
        authorLevel: user.author?.authorLevel,
        penName: user.author?.penName,
      },
      followersCount,
      followingCount,
      booksCount,
      isFollowing,
    };
  }

  async followUser(followerId: string, followingId: string) {
    if (followerId === followingId) {
      throw new Error('Cannot follow yourself');
    }

    // Check if already following
    const existingFollow = await this.prisma.follow.findUnique({
      where: {
        followerId_followingId: {
          followerId,
          followingId,
        },
      },
    });

    if (existingFollow) {
      throw new Error('Already following this user');
    }

    // Create follow relationship
    await this.prisma.follow.create({
      data: {
        followerId,
        followingId,
      },
    });

    // Update follower and following counts
    await Promise.all([
      this.prisma.user.update({
        where: { id: followingId },
        data: { followers: { increment: 1 } },
      }),
      this.prisma.user.update({
        where: { id: followerId },
        data: { following: { increment: 1 } },
      }),
    ]);

    // If following an author, update author fans count
    const author = await this.prisma.author.findUnique({
      where: { userId: followingId },
    });
    if (author) {
      await this.prisma.author.update({
        where: { id: author.id },
        data: { totalFans: { increment: 1 } },
      });
    }

    // Create notification
    await this.prisma.notification.create({
      data: {
        userId: followingId,
        type: 'follow',
        title: '新粉丝',
        content: '有人关注了你',
        data: { followerId },
      },
    });

    return { success: true };
  }

  async unfollowUser(followerId: string, followingId: string) {
    const follow = await this.prisma.follow.findUnique({
      where: {
        followerId_followingId: {
          followerId,
          followingId,
        },
      },
    });

    if (!follow) {
      throw new Error('Not following this user');
    }

    await this.prisma.follow.delete({
      where: { id: follow.id },
    });

    // Update counts
    await Promise.all([
      this.prisma.user.update({
        where: { id: followingId },
        data: { followers: { decrement: 1 } },
      }),
      this.prisma.user.update({
        where: { id: followerId },
        data: { following: { decrement: 1 } },
      }),
    ]);

    // Update author fans count
    const author = await this.prisma.author.findUnique({
      where: { userId: followingId },
    });
    if (author) {
      await this.prisma.author.update({
        where: { id: author.id },
        data: { totalFans: { decrement: 1 } },
      });
    }

    return { success: true };
  }

  async getFollowers(userId: string, page: number = 1, size: number = 20) {
    const [items, total] = await Promise.all([
      this.prisma.follow.findMany({
        where: { followingId: userId },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * size,
        take: size,
        include: {
          follower: {
            select: {
              id: true,
              nickname: true,
              avatar: true,
              bio: true,
            },
          },
        },
      }),
      this.prisma.follow.count({ where: { followingId: userId } }),
    ]);

    return {
      items: items.map((f) => f.follower),
      total,
      page,
      size,
      hasMore: page * size < total,
    };
  }

  async getFollowing(userId: string, page: number = 1, size: number = 20) {
    const [items, total] = await Promise.all([
      this.prisma.follow.findMany({
        where: { followerId: userId },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * size,
        take: size,
        include: {
          following: {
            select: {
              id: true,
              nickname: true,
              avatar: true,
              bio: true,
            },
          },
        },
      }),
      this.prisma.follow.count({ where: { followerId: userId } }),
    ]);

    return {
      items: items.map((f) => f.following),
      total,
      page,
      size,
      hasMore: page * size < total,
    };
  }

  async getUserBooks(userId: string, page: number = 1, size: number = 20) {
    const author = await this.prisma.author.findUnique({
      where: { userId },
    });

    if (!author) {
      return { items: [], total: 0, page, size, hasMore: false };
    }

    const [items, total] = await Promise.all([
      this.prisma.book.findMany({
        where: { authorId: author.id },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * size,
        take: size,
      }),
      this.prisma.book.count({ where: { authorId: author.id } }),
    ]);

    return {
      items,
      total,
      page,
      size,
      hasMore: page * size < total,
    };
  }

  async searchUsers(keyword: string, page: number = 1, size: number = 20) {
    const [items, total] = await Promise.all([
      this.prisma.user.findMany({
        where: {
          OR: [
            { nickname: { contains: keyword, mode: 'insensitive' } },
          ],
        },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * size,
        take: size,
        select: {
          id: true,
          nickname: true,
          avatar: true,
          bio: true,
        },
      }),
      this.prisma.user.count({
        where: {
          nickname: { contains: keyword, mode: 'insensitive' },
        },
      }),
    ]);

    return {
      items,
      total,
      page,
      size,
      hasMore: page * size < total,
    };
  }
}
