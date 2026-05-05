// Authentication types
export interface LoginRequest {
  phone?: string;
  email?: string;
  password?: string;
  code?: string;
  loginType: 'password' | 'code';
  captcha?: string;
}

export interface RegisterRequest {
  phone?: string;
  email?: string;
  password: string;
  confirmPassword?: string;
  inviteCode?: string;
  captcha: string;
  agreeTerms: boolean;
}

export interface AuthResponse {
  user: User;
  token: string;
  refreshToken: string;
  expiresIn: number;
}

export interface SendCodeRequest {
  phone?: string;
  email?: string;
  type: 'login' | 'register' | 'reset';
}

export interface ResetPasswordRequest {
  phone?: string;
  email?: string;
  code: string;
  newPassword: string;
}

// User types
export interface User {
  id: string;
  phone?: string;
  email?: string;
  nickname: string;
  avatar?: string;
  bio?: string;
  realName?: string;
  idCardType?: 'id_card' | 'passport';
  idCardNumber?: string;
  realAuthStatus: 'none' | 'pending' | 'approved' | 'rejected';
  realAuthAt?: string;
  vipStatus: 'none' | 'monthly' | 'yearly' | 'permanent';
  vipExpireAt?: string;
  language: SupportedLanguage;
  createdAt: string;
  updatedAt: string;
}

export interface UpdateUserRequest {
  nickname?: string;
  avatar?: string;
  bio?: string;
  language?: SupportedLanguage;
}

// Author types
export interface Author {
  id: string;
  userId: string;
  user?: User;
  penName: string;
  authorLevel: 'normal' | 'advanced' | 'signed';
  totalBooks: number;
  totalWords: number;
  totalFans: number;
  totalIncome: number;
  pendingIncome: number;
  withdrawableBalance: number;
  bankAccount?: string;
  bankName?: string;
  paypalAccount?: string;
  createdAt: string;
  updatedAt: string;
}

// Book types
export interface Book {
  id: string;
  authorId: string;
  author?: Author;
  title: string;
  subtitle?: string;
  description?: string;
  coverUrl?: string;
  category?: Category;
  categoryId?: string;
  priceChapter: number;
  priceBook: number;
  isVipOnly: boolean;
  wordCount: number;
  chapterCount: number;
  status: 'draft' | 'publishing' | 'published' | 'rejected' | 'removed';
  auditStatus: 'pending' | 'approved' | 'rejected';
  auditReason?: string;
  ratingAvg: number;
  ratingCount: number;
  viewCount: number;
  subscriberCount: number;
  language: SupportedLanguage;
  isSerial: boolean;
  tags?: Tag[];
  chapters?: Chapter[];
  publishedAt?: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreateBookRequest {
  title: string;
  subtitle?: string;
  description?: string;
  cover?: File;
  categoryId?: string;
  tags?: string[];
  priceChapter?: number;
  priceBook?: number;
  isVipOnly?: boolean;
  language?: SupportedLanguage;
  isSerial?: boolean;
}

export interface UpdateBookRequest extends Partial<CreateBookRequest> {}

// Chapter types
export interface Chapter {
  id: string;
  bookId: string;
  book?: Book;
  chapterNumber: number;
  title: string;
  content?: string;
  wordCount: number;
  priceType: 'free' | 'vip' | 'chapter' | 'book';
  price: number;
  isVipOnly: boolean;
  status: 'draft' | 'published';
  auditStatus: 'pending' | 'approved' | 'rejected';
  publishedAt?: string;
  scheduledAt?: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreateChapterRequest {
  title: string;
  content?: string;
  priceType?: 'free' | 'vip' | 'chapter' | 'book';
  price?: number;
  isVipOnly?: boolean;
  scheduledAt?: string;
}

export interface UpdateChapterRequest extends Partial<CreateChapterRequest> {
  status?: 'draft' | 'published';
}

// Category types
export interface Category {
  id: string;
  name: string;
  nameEn: string;
  parentId?: string;
  level: number;
  sort: number;
  children?: Category[];
}

export interface Tag {
  id: string;
  name: string;
  usageCount: number;
}

// Order types
export interface Order {
  id: string;
  orderNo: string;
  userId: string;
  user?: User;
  bookId?: string;
  book?: Book;
  chapterId?: string;
  chapter?: Chapter;
  orderType: 'book' | 'chapter' | 'vip' | 'gift';
  amount: number;
  currency: 'CNY' | 'USD';
  discountAmount: number;
  actualAmount: number;
  paymentMethod?: 'alipay' | 'wechat' | 'stripe' | 'paypal';
  paymentStatus: 'pending' | 'paid' | 'refunded' | 'cancelled';
  paymentTime?: string;
  platformFee: number;
  authorIncome: number;
  giftReceiverId?: string;
  giftReceiver?: User;
  giftMessage?: string;
  createdAt: string;
}

export interface CreateOrderRequest {
  bookId?: string;
  chapterId?: string;
  orderType: 'book' | 'chapter' | 'vip' | 'gift';
  paymentMethod: 'alipay' | 'wechat' | 'stripe' | 'paypal';
  giftReceiverId?: string;
  giftMessage?: string;
}

// Payment types
export interface PaymentRequest {
  orderId: string;
  paymentMethod: 'alipay' | 'wechat' | 'stripe' | 'paypal';
  returnUrl?: string;
}

export interface PaymentResult {
  success: boolean;
  orderId: string;
  paymentUrl?: string;
  paymentParams?: Record<string, string>;
  error?: string;
}

// Comment types
export interface Comment {
  id: string;
  bookId: string;
  userId: string;
  user?: User;
  content: string;
  rating?: number;
  parentId?: string;
  replies?: Comment[];
  likeCount: number;
  isLiked?: boolean;
  status: 'pending' | 'approved' | 'hidden';
  createdAt: string;
  updatedAt: string;
}

export interface CreateCommentRequest {
  bookId: string;
  content: string;
  rating?: number;
  parentId?: string;
}

// Notification types
export interface Notification {
  id: string;
  userId: string;
  type: 'comment' | 'like' | 'follow' | 'book_update' | 'system' | 'order';
  title: string;
  content: string;
  data?: Record<string, string>;
  isRead: boolean;
  createdAt: string;
}

// AI types
export interface AIContinueWriteRequest {
  bookId: string;
  chapterId: string;
  content: string;
  maxTokens?: number;
}

export interface AIPolishRequest {
  content: string;
  polishType: 'smooth' | 'elegant' | 'concise' | 'vivid';
}

export interface AITranslateRequest {
  content: string;
  sourceLang: SupportedLanguage;
  targetLang: SupportedLanguage;
}

export interface AIQaRequest {
  bookId?: string;
  chapterId?: string;
  question: string;
  context?: string;
}

export interface AIResponse {
  content: string;
  usage?: {
    promptTokens: number;
    completionTokens: number;
    totalTokens: number;
  };
}

// Supported languages
export type SupportedLanguage = 'zh-CN' | 'en' | 'es' | 'fr' | 'de' | 'ru' | 'ar';

// Pagination
export interface PaginationParams {
  page?: number;
  size?: number;
  sort?: string;
  order?: 'asc' | 'desc';
}

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  size: number;
  totalPages: number;
}

// API Response wrapper
export interface ApiResponse<T> {
  code: number;
  message: string;
  data?: T;
  errors?: Record<string, string[]>;
}

// Review reading progress
export interface ReadingProgress {
  bookId: string;
  chapterId: string;
  position: number;
  percentage: number;
  totalChapters: number;
  currentChapter: number;
  lastReadAt: string;
}

// Author withdrawal
export interface WithdrawalRequest {
  amount: number;
  method: 'bank' | 'paypal';
  bankAccount?: string;
  bankName?: string;
  paypalAccount?: string;
}

// Dynamic / Feed
export interface Dynamic {
  id: string;
  userId: string;
  user?: User;
  type: 'text' | 'image' | 'book_recommend';
  content: string;
  images?: string[];
  bookId?: string;
  book?: Book;
  likeCount: number;
  commentCount: number;
  shareCount: number;
  isLiked?: boolean;
  createdAt: string;
}

// Booklist
export interface Booklist {
  id: string;
  userId: string;
  user?: User;
  name: string;
  description?: string;
  coverUrl?: string;
  isPublic: boolean;
  bookCount: number;
  followerCount: number;
  books?: Book[];
  createdAt: string;
  updatedAt: string;
}

// Real auth
export interface RealAuthRequest {
  idCardType: 'id_card' | 'passport';
  idCardFront: File;
  idCardBack: File;
  handheldPhoto?: File;
}
