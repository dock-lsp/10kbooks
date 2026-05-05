'use client';

import React, { useState } from 'react';
import { BookCard } from './book-card';
import { cn } from '@/lib/utils';

interface CategorySectionProps {
  title: string;
  categories?: Array<{ id: string; name: string; count: number }>;
  books?: Array<{
    id: string;
    title: string;
    author: string;
    cover: string;
    rating: number;
    subscribers: number;
    description?: string;
    isVipOnly?: boolean;
  }>;
  viewAllLink?: string;
  className?: string;
}

export function CategorySection({
  title,
  categories,
  books,
  viewAllLink,
  className,
}: CategorySectionProps) {
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);

  const mockBooks = books || [
    {
      id: '1',
      title: '仙武帝尊',
      author: '玄幻小王子',
      cover: '',
      rating: 4.8,
      subscribers: 125800,
      description: '一代天才重生，逆天崛起，终成一代武帝...',
      isVipOnly: true,
    },
    {
      id: '2',
      title: '都市狂少',
      author: '都市达人',
      cover: '',
      rating: 4.6,
      subscribers: 98200,
      description: '都市小子逆袭人生，权财双收...',
      isVipOnly: false,
    },
    {
      id: '3',
      title: '星际迷航',
      author: '科幻作家',
      cover: '',
      rating: 4.5,
      subscribers: 75600,
      description: '探索宇宙深处，发现未知文明...',
      isVipOnly: true,
    },
    {
      id: '4',
      title: '重生之都市修仙',
      author: '修仙迷',
      cover: '',
      rating: 4.7,
      subscribers: 110500,
      description: '重生都市，携修仙传承，纵横天下...',
      isVipOnly: false,
    },
  ];

  return (
    <section className={cn('py-8', className)}>
      <div className="container mx-auto px-4">
        {/* Section Header */}
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-bold text-gray-900">{title}</h2>
          {viewAllLink && (
            <a
              href={viewAllLink}
              className="text-sm text-primary hover:underline flex items-center gap-1"
            >
              查看更多
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
              </svg>
            </a>
          )}
        </div>

        {/* Categories Filter */}
        {categories && categories.length > 0 && (
          <div className="flex gap-2 mb-6 overflow-x-auto pb-2">
            <button
              onClick={() => setSelectedCategory(null)}
              className={cn(
                'px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-all',
                selectedCategory === null
                  ? 'bg-primary text-white'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              )}
            >
              全部
            </button>
            {categories.map((category) => (
              <button
                key={category.id}
                onClick={() => setSelectedCategory(category.id)}
                className={cn(
                  'px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-all',
                  selectedCategory === category.id
                    ? 'bg-primary text-white'
                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                )}
              >
                {category.name}
              </button>
            ))}
          </div>
        )}

        {/* Books Grid */}
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-4">
          {mockBooks.map((book) => (
            <BookCard key={book.id} book={book} />
          ))}
        </div>
      </div>
    </section>
  );
}
