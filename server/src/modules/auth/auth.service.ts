import { Injectable, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { randomBytes } from 'crypto';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async register(data: {
    phone?: string;
    email?: string;
    password: string;
    inviteCode?: string;
    captcha?: string;
  }) {
    // Validate captcha if provided
    if (data.captcha) {
      const isValidCaptcha = await this.validateCaptcha(data.phone || data.email!, data.captcha);
      if (!isValidCaptcha) {
        throw new BadRequestException('Invalid or expired captcha');
      }
    }

    // Check if user already exists
    const existingUser = await this.prisma.user.findFirst({
      where: {
        OR: [
          { phone: data.phone },
          { email: data.email },
        ].filter(Boolean),
      },
    });

    if (existingUser) {
      throw new BadRequestException('User already exists');
    }

    // Hash password
    const passwordHash = await bcrypt.hash(data.password, 10);

    // Create user
    const user = await this.prisma.user.create({
      data: {
        phone: data.phone,
        email: data.email,
        passwordHash,
        nickname: `用户${Math.random().toString(36).substring(2, 8)}`,
      },
    });

    // Handle invite code
    if (data.inviteCode) {
      await this.processInviteCode(data.inviteCode, user.id);
    }

    // Generate tokens
    const tokens = await this.generateTokens(user.id);

    // Create session
    await this.createSession(user.id, tokens.refreshToken);

    return {
      user: this.sanitizeUser(user),
      ...tokens,
    };
  }

  async login(data: {
    phone?: string;
    email?: string;
    password: string;
    captcha?: string;
  }) {
    const user = await this.prisma.user.findFirst({
      where: {
        OR: [
          { phone: data.phone },
          { email: data.email },
        ].filter(Boolean),
      },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(data.password, user.passwordHash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Update last login
    await this.prisma.user.update({
      where: { id: user.id },
      data: { lastLoginAt: new Date() },
    });

    const tokens = await this.generateTokens(user.id);
    await this.createSession(user.id, tokens.refreshToken);

    return {
      user: this.sanitizeUser(user),
      ...tokens,
    };
  }

  async refreshToken(refreshToken: string) {
    const session = await this.prisma.session.findUnique({
      where: { refreshToken },
    });

    if (!session) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    if (session.expiresAt < new Date()) {
      await this.prisma.session.delete({ where: { id: session.id } });
      throw new UnauthorizedException('Refresh token expired');
    }

    const tokens = await this.generateTokens(session.userId);

    // Rotate refresh token
    await this.prisma.session.update({
      where: { id: session.id },
      data: { refreshToken: tokens.refreshToken },
    });

    return tokens;
  }

  async logout(refreshToken: string) {
    await this.prisma.session.deleteMany({
      where: { refreshToken },
    });
  }

  async getCurrentUser(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        author: true,
      },
    });

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    return this.sanitizeUser(user);
  }

  async updateProfile(userId: string, data: {
    nickname?: string;
    avatar?: string;
    bio?: string;
    language?: string;
  }) {
    const user = await this.prisma.user.update({
      where: { id: userId },
      data: data,
    });

    return this.sanitizeUser(user);
  }

  async submitRealAuth(userId: string, data: {
    idCardType: string;
    idCardFront: string;
    idCardBack: string;
    handheldPhoto?: string;
  }) {
    const realAuth = await this.prisma.realAuth.create({
      data: {
        userId,
        idCardType: data.idCardType,
        idCardFront: data.idCardFront,
        idCardBack: data.idCardBack,
        handheldPhoto: data.handheldPhoto,
        status: 'pending',
      },
    });

    await this.prisma.user.update({
      where: { id: userId },
      data: { realAuthStatus: 'pending' },
    });

    return realAuth;
  }

  private async generateTokens(userId: string) {
    const payload = { sub: userId };

    const accessToken = this.jwtService.sign(payload, { expiresIn: '2h' });
    const refreshToken = randomBytes(64).toString('hex');

    return { accessToken, refreshToken };
  }

  private async createSession(userId: string, refreshToken: string) {
    await this.prisma.session.create({
      data: {
        userId,
        refreshToken,
        expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days
      },
    });
  }

  private async validateCaptcha(identifier: string, captcha: string): Promise<boolean> {
    // In production, implement actual captcha validation with Redis
    return captcha.length === 6;
  }

  private async processInviteCode(inviteCode: string, newUserId: string) {
    // Find inviter
    const inviter = await this.prisma.user.findFirst({
      where: { id: inviteCode }, // In production, use a separate invite code table
    });

    if (inviter) {
      // Create invitation record
      // Award inviter based on new user's first purchase
    }
  }

  private sanitizeUser(user: any) {
    const { passwordHash, ...sanitized } = user;
    return sanitized;
  }
}
