'use client';

import React from 'react';
import { Star, Users, Crown } from 'lucide-react';
import { cn } from '@/lib/utils';

interface BookCardProps {
  book: {
    id: string;
    title: string;
    author: string;
    cover: string;
    rating: number;
    subscribers: number;
    description?: string;
    isVipOnly?: boolean;
  };
  variant?: 'default' | 'horizontal' | 'compact';
  className?: string;
  onClick?: () => void;
}

export function BookCard({
  book,
  variant = 'default',
  className,
  onClick,
}: BookCardProps) {
  const formatSubscribers = (num: number) => {
    if (num >= 10000) {
      return (num / 10000).toFixed(1) + '万';
    }
    return num.toLocaleString();
  };

  if (variant === 'horizontal') {
    return (
      <div
        onClick={onClick}
        className={cn(
          'flex gap-4 p-4 bg-white rounded-xl border border-gray-100 hover:shadow-md transition-all cursor-pointer',
          className
        )}
      >
        {/* Cover */}
        <div className="relative w-20 h-28 flex-shrink-0 bg-gradient-to-br from-primary/20 to-primary/10 rounded-lg overflow-hidden">
          {book.cover ? (
            <img src={book.cover} alt={book.title} className="w-full h-full object-cover" />
          ) : (
            <div className="w-full h-full flex items-center justify-center">
              <svg className="w-8 h-8 text-primary/50" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
              </svg>
            </div>
          )}
          {book.isVipOnly && (
            <div className="absolute top-1 left-1 px-1.5 py-0.5 bg-amber-500 rounded text-[10px] text-white font-medium flex items-center gap-0.5">
              <Crown className="w-3 h-3" />
              VIP
            </div>
          )}
        </div>

        {/* Info */}
        <div className="flex-1 min-w-0">
          <h3 className="font-bold text-gray-900 truncate">{book.title}</h3>
          <p className="text-sm text-gray-500 mt-1">{book.author}</p>
          <p className="text-sm text-gray-600 mt-2 line-clamp-2">{book.description}</p>
          <div className="flex items-center gap-4 mt-3 text-sm">
            <div className="flex items-center gap-1 text-amber-500">
              <Star className="w-4 h-4 fill-current" />
              <span className="font-medium">{book.rating}</span>
            </div>
            <div className="flex items-center gap-1 text-gray-500">
              <Users className="w-4 h-4" />
              <span>{formatSubscribers(book.subscribers)}</span>
            </div>
          </div>
        </div>
      </div>
    );
  }

  if (variant === 'compact') {
    return (
      <div
        onClick={onClick}
        className={cn(
          'flex gap-3 p-2 hover:bg-gray-50 rounded-lg transition-all cursor-pointer',
          className
        )}
      >
        <div className="relative w-12 h-16 bg-gradient-to-br from-primary/20 to-primary/10 rounded overflow-hidden flex-shrink-0">
          {book.cover ? (
            <img src={book.cover} alt={book.title} className="w-full h-full object-cover" />
          ) : (
            <div className="w-full h-full flex items-center justify-center">
              <svg className="w-4 h-4 text-primary/50" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
              </svg>
            </div>
          )}
        </div>
        <div className="flex-1 min-w-0">
          <h4 className="font-medium text-gray-900 text-sm truncate">{book.title}</h4>
          <p className="text-xs text-gray-500 truncate">{book.author}</p>
        </div>
      </div>
    );
  }

  // Default variant
  return (
    <div
      onClick={onClick}
      className={cn(
        'group bg-white rounded-xl overflow-hidden border border-gray-100 hover:shadow-lg transition-all cursor-pointer',
        className
      )}
    >
      {/* Cover */}
      <div className="relative aspect-[3/4] bg-gradient-to-br from-primary/20 to-primary/10 overflow-hidden">
        {book.cover ? (
          <img src={book.cover} alt={book.title} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300" />
        ) : (
          <div className="w-full h-full flex items-center justify-center">
            <svg className="w-12 h-12 text-primary/30" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
            </svg>
          </div>
        )}
        {book.isVipOnly && (
          <div className="absolute top-2 right-2 px-2 py-1 bg-amber-500 rounded-full text-[10px] text-white font-bold flex items-center gap-1">
            <Crown className="w-3 h-3" />
            VIP
          </div>
        )}
        <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity">
          <div className="absolute bottom-2 left-2 right-2">
            <button className="w-full py-1.5 bg-white rounded-lg text-sm font-medium text-primary">
              立即阅读
            </button>
          </div>
        </div>
      </div>

      {/* Info */}
      <div className="p-3">
        <h3 className="font-bold text-gray-900 text-sm line-clamp-2 leading-tight">
          {book.title}
        </h3>
        <p className="text-xs text-gray-500 mt-1 truncate">{book.author}</p>
        <div className="flex items-center justify-between mt-2 text-xs">
          <div className="flex items-center gap-1 text-amber-500">
            <Star className="w-3 h-3 fill-current" />
            <span className="font-medium">{book.rating}</span>
          </div>
          <div className="flex items-center gap-1 text-gray-400">
            <Users className="w-3 h-3" />
            <span>{formatSubscribers(book.subscribers)}</span>
          </div>
        </div>
      </div>
    </div>
  );
}
