import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { BullModule } from '@nestjs/bull';

import { BookController } from './book.controller';
import { BookService } from './book.service';
import { BookResolver } from './book.resolver';

import { Book } from './entities/book.entity';
import { Chapter } from '../chapter/entities/chapter.entity';
import { Category } from './entities/category.entity';
import { Tag } from './entities/tag.entity';
import { BookTag } from './entities/book-tag.entity';
import { Author } from '../author/entities/author.entity';
import { User } from '../user/entities/user.entity';
import { BookTranslation } from './entities/book-translation.entity';

import { AuditProcessor } from './processors/audit.processor';
import { SearchProcessor } from './processors/search.processor';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Book,
      Chapter,
      Category,
      Tag,
      BookTag,
      Author,
      User,
      BookTranslation,
    ]),
    BullModule.registerQueue({
      name: 'book-audit',
    }),
    BullModule.registerQueue({
      name: 'search-index',
    }),
  ],
  controllers: [BookController],
  providers: [
    BookService,
    BookResolver,
    AuditProcessor,
    SearchProcessor,
  ],
  exports: [BookService],
})
export class BookModule {}
