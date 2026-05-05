import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { BullModule } from '@nestjs/bull';

import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { AuthResolver } from './auth.resolver';
import { JwtStrategy } from './strategies/jwt.strategy';
import { RefreshTokenStrategy } from './strategies/refresh-token.strategy';

import { User } from '../user/entities/user.entity';
import { Session } from '../user/entities/session.entity';
import { Author } from '../author/entities/author.entity';
import { SmsProcessor } from './processors/sms.processor';
import { MailProcessor } from './processors/mail.processor';

@Module({
  imports: [
    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        secret: configService.get('JWT_SECRET'),
        signOptions: {
          expiresIn: configService.get('JWT_EXPIRES_IN') || '2h',
        },
      }),
    }),
    TypeOrmModule.forFeature([User, Session, Author]),
    BullModule.registerQueue({
      name: 'sms',
    }),
    BullModule.registerQueue({
      name: 'mail',
    }),
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    AuthResolver,
    JwtStrategy,
    RefreshTokenStrategy,
    SmsProcessor,
    MailProcessor,
  ],
  exports: [AuthService, JwtModule],
})
export class AuthModule {}
