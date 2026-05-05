import axios, { AxiosError, AxiosResponse, InternalAxiosRequestConfig } from 'axios';
import { getToken, setToken, removeToken, getRefreshToken, setRefreshToken } from '@/utils/auth';
import { ApiResponse } from '@/types/auth';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001/api';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor
apiClient.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token = getToken();
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error: AxiosError) => {
    return Promise.reject(error);
  }
);

// Response interceptor
apiClient.interceptors.response.use(
  (response: AxiosResponse<ApiResponse<unknown>>) => {
    return response;
  },
  async (error: AxiosError<ApiResponse<unknown>>) => {
    const originalRequest = error.config as InternalAxiosRequestConfig & { _retry?: boolean };

    // Handle 401 Unauthorized
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      try {
        const refreshToken = getRefreshToken();
        if (refreshToken) {
          const response = await axios.post(`${API_BASE_URL}/auth/refresh`, {
            refreshToken,
          });

          const { token: newToken, refreshToken: newRefreshToken } = response.data.data as any;
          setToken(newToken);
          setRefreshToken(newRefreshToken);

          if (originalRequest.headers) {
            originalRequest.headers.Authorization = `Bearer ${newToken}`;
          }
          return apiClient(originalRequest);
        }
      } catch (refreshError) {
        removeToken();
        window.location.href = '/auth/login';
        return Promise.reject(refreshError);
      }
    }

    // Handle other errors
    if (error.response?.data) {
      const { message, errors } = error.response.data;
      if (errors) {
        const errorMessages = Object.values(errors).flat().join(', ');
        return Promise.reject(new Error(errorMessages || message));
      }
      return Promise.reject(new Error(message || 'An error occurred'));
    }

    return Promise.reject(error);
  }
);

export default apiClient;

// Auth API
export const authApi = {
  login: (data: { phone?: string; email?: string; password?: string; code?: string; loginType: string }) =>
    apiClient.post<ApiResponse<{ user: any; token: string; refreshToken: string; expiresIn: number }>>('/auth/login', data),

  register: (data: any) =>
    apiClient.post<ApiResponse<{ user: any; token: string; refreshToken: string }>>('/auth/register', data),

  sendCode: (data: { phone?: string; email?: string; type: string }) =>
    apiClient.post<ApiResponse<{ sent: boolean }>>('/auth/send-code', data),

  resetPassword: (data: { phone?: string; email?: string; code: string; newPassword: string }) =>
    apiClient.post<ApiResponse<{ success: boolean }>>('/auth/reset-password', data),

  refresh: (data: { refreshToken: string }) =>
    apiClient.post<ApiResponse<{ token: string; refreshToken: string }>>('/auth/refresh', data),
};

// User API
export const userApi = {
  getMe: () => apiClient.get<ApiResponse<any>>('/users/me'),

  updateMe: (data: any) => apiClient.patch<ApiResponse<any>>('/users/me', data),

  uploadAvatar: (file: File) => {
    const formData = new FormData();
    formData.append('file', file);
    return apiClient.post<ApiResponse<{ url: string }>>('/users/me/avatar', formData);
  },

  realAuth: (data: FormData) =>
    apiClient.post<ApiResponse<{ authId: string; status: string }>>('/users/real-auth', data),

  getRealAuthStatus: () =>
    apiClient.get<ApiResponse<{ status: string; reason?: string }>>('/users/real-auth/status'),
};

// Author API
export const authorApi = {
  becomeAuthor: (data: { penName: string; bankAccount?: string; bankName?: string; paypalAccount?: string }) =>
    apiClient.post<ApiResponse<any>>('/authors', data),

  getMe: () => apiClient.get<ApiResponse<any>>('/authors/me'),

  getProfile: (authorId: string) =>
    apiClient.get<ApiResponse<any>>(`/authors/${authorId}`),

  updateProfile: (data: any) =>
    apiClient.patch<ApiResponse<any>>('/authors/me', data),
};

// Book API
export const bookApi = {
  list: (params?: { category?: string; tag?: string; keyword?: string; page?: number; size?: number; sort?: string }) =>
    apiClient.get<ApiResponse<{ items: any[]; total: number; page: number; size: number }>>('/books', { params }),

  getById: (bookId: string) =>
    apiClient.get<ApiResponse<any>>(`/books/${bookId}`),

  create: (data: FormData) =>
    apiClient.post<ApiResponse<any>>('/books', data, {
      headers: { 'Content-Type': 'multipart/form-data' },
    }),

  update: (bookId: string, data: FormData) =>
    apiClient.patch<ApiResponse<any>>(`/books/${bookId}`, data, {
      headers: { 'Content-Type': 'multipart/form-data' },
    }),

  delete: (bookId: string) =>
    apiClient.delete<ApiResponse<{ success: boolean }>>(`/books/${bookId}`),

  uploadPdf: (bookId: string, file: File, onProgress?: (progress: number) => void) => {
    const formData = new FormData();
    formData.append('file', file);
    return apiClient.post<ApiResponse<{ chapters: any[] }>>(`/books/${bookId}/upload-pdf`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
      onUploadProgress: (progressEvent) => {
        if (onProgress && progressEvent.total) {
          const progress = Math.round((progressEvent.loaded * 100) / progressEvent.total);
          onProgress(progress);
        }
      },
    });
  },

  getChapters: (bookId: string, params?: { status?: string; page?: number; size?: number }) =>
    apiClient.get<ApiResponse<{ items: any[]; total: number }>>(`/books/${bookId}/chapters`, { params }),

  getChapter: (bookId: string, chapterId: string, params?: { skipPay?: boolean }) =>
    apiClient.get<ApiResponse<any>>(`/books/${bookId}/chapters/${chapterId}`, { params }),

  createChapter: (bookId: string, data: any) =>
    apiClient.post<ApiResponse<any>>(`/books/${bookId}/chapters`, data),

  updateChapter: (bookId: string, chapterId: string, data: any) =>
    apiClient.patch<ApiResponse<any>>(`/books/${bookId}/chapters/${chapterId}`, data),

  publishChapter: (bookId: string, chapterId: string) =>
    apiClient.post<ApiResponse<any>>(`/books/${bookId}/chapters/${chapterId}/publish`),

  deleteChapter: (bookId: string, chapterId: string) =>
    apiClient.delete<ApiResponse<{ success: boolean }>>(`/books/${bookId}/chapters/${chapterId}`),
};

// Order API
export const orderApi = {
  create: (data: { bookId?: string; chapterId?: string; orderType: string; paymentMethod: string; giftReceiverId?: string; giftMessage?: string }) =>
    apiClient.post<ApiResponse<any>>('/orders', data),

  getById: (orderId: string) =>
    apiClient.get<ApiResponse<any>>(`/orders/${orderId}`),

  list: (params?: { status?: string; page?: number; size?: number }) =>
    apiClient.get<ApiResponse<{ items: any[]; total: number }>>('/orders', { params }),

  pay: (orderId: string, data: { paymentMethod: string; returnUrl?: string }) =>
    apiClient.post<ApiResponse<any>>(`/orders/${orderId}/pay`, data),

  cancel: (orderId: string) =>
    apiClient.post<ApiResponse<{ success: boolean }>>(`/orders/${orderId}/cancel`),
};

// Comment API
export const commentApi = {
  list: (bookId: string, params?: { page?: number; size?: number }) =>
    apiClient.get<ApiResponse<{ items: any[]; total: number }>>(`/books/${bookId}/comments`, { params }),

  create: (data: { bookId: string; content: string; rating?: number; parentId?: string }) =>
    apiClient.post<ApiResponse<any>>('/comments', data),

  delete: (commentId: string) =>
    apiClient.delete<ApiResponse<{ success: boolean }>>(`/comments/${commentId}`),

  like: (commentId: string) =>
    apiClient.post<ApiResponse<{ liked: boolean; likeCount: number }>>(`/comments/${commentId}/like`),
};

// AI API
export const aiApi = {
  continueWrite: (data: { bookId: string; chapterId: string; content: string; maxTokens?: number }) =>
    apiClient.post<ApiResponse<{ content: string; usage: any }>>('/ai/continue-write', data),

  polish: (data: { content: string; polishType: string }) =>
    apiClient.post<ApiResponse<{ content: string; usage: any }>>('/ai/polish', data),

  translate: (data: { content: string; sourceLang: string; targetLang: string }) =>
    apiClient.post<ApiResponse<{ content: string; usage: any }>>('/ai/translate', data),

  summarize: (data: { content: string; maxLength?: number }) =>
    apiClient.post<ApiResponse<{ summary: string; usage: any }>>('/ai/summarize', data),

  qa: (data: { bookId?: string; chapterId?: string; question: string; context?: string }) =>
    apiClient.post<ApiResponse<{ answer: string; references: any[]; usage: any }>>('/ai/qa', data),

  generateIdeas: (data: { theme: string; type: string }) =>
    apiClient.post<ApiResponse<{ ideas: any[] }>>('/ai/generate-ideas', data),
};

// Notification API
export const notificationApi = {
  list: (params?: { page?: number; size?: number; unreadOnly?: boolean }) =>
    apiClient.get<ApiResponse<{ items: any[]; total: number; unreadCount: number }>>('/notifications', { params }),

  markAsRead: (notificationId: string) =>
    apiClient.post<ApiResponse<{ success: boolean }>>(`/notifications/${notificationId}/read`),

  markAllAsRead: () =>
    apiClient.post<ApiResponse<{ success: boolean }>>('/notifications/read-all'),

  delete: (notificationId: string) =>
    apiClient.delete<ApiResponse<{ success: boolean }>>(`/notifications/${notificationId}`),
};

// Social API
export const socialApi = {
  follow: (userId: string) =>
    apiClient.post<ApiResponse<{ following: boolean }>>(`/users/${userId}/follow`),

  unfollow: (userId: string) =>
    apiClient.delete<ApiResponse<{ following: boolean }>>(`/users/${userId}/follow`),

  getFollowers: (userId: string, params?: { page?: number; size?: number }) =>
    apiClient.get<ApiResponse<{ items: any[]; total: number }>>(`/users/${userId}/followers`, { params }),

  getFollowing: (userId: string, params?: { page?: number; size?: number }) =>
    apiClient.get<ApiResponse<{ items: any[]; total: number }>>(`/users/${userId}/following`, { params }),

  getDynamics: (params?: { page?: number; size?: number }) =>
    apiClient.get<ApiResponse<{ items: any[]; total: number }>>('/dynamics', { params }),

  createDynamic: (data: FormData) =>
    apiClient.post<ApiResponse<any>>('/dynamics', data, {
      headers: { 'Content-Type': 'multipart/form-data' },
    }),

  likeDynamic: (dynamicId: string) =>
    apiClient.post<ApiResponse<{ liked: boolean; likeCount: number }>>(`/dynamics/${dynamicId}/like`),

  getBooklists: (userId?: string, params?: { page?: number; size?: number }) =>
    apiClient.get<ApiResponse<{ items: any[]; total: number }>>('/booklists', { params: { userId, ...params } }),

  createBooklist: (data: { name: string; description?: string; isPublic: boolean }) =>
    apiClient.post<ApiResponse<any>>('/booklists', data),

  addToBooklist: (booklistId: string, bookId: string) =>
    apiClient.post<ApiResponse<{ success: boolean }>>(`/booklists/${booklistId}/books`, { bookId }),
};

// Reading API
export const readingApi = {
  getProgress: (bookId: string) =>
    apiClient.get<ApiResponse<any>>(`/reading/${bookId}/progress`),

  updateProgress: (bookId: string, data: { chapterId: string; position: number; percentage: number }) =>
    apiClient.put<ApiResponse<any>>(`/reading/${bookId}/progress`, data),

  getHistory: (params?: { page?: number; size?: number }) =>
    apiClient.get<ApiResponse<{ items: any[]; total: number }>>('/reading/history', { params }),
};

// VIP API
export const vipApi = {
  getPlans: () =>
    apiClient.get<ApiResponse<any[]>>('/vip/plans'),

  subscribe: (data: { planId: string; paymentMethod: string }) =>
    apiClient.post<ApiResponse<any>>('/vip/subscribe', data),

  getStatus: () =>
    apiClient.get<ApiResponse<any>>('/vip/status'),

  cancelAutoRenew: () =>
    apiClient.post<ApiResponse<{ success: boolean }>>('/vip/cancel-auto-renew'),
};

// Withdraw API
export const withdrawApi = {
  apply: (data: { amount: number; method: string; bankAccount?: string; bankName?: string; paypalAccount?: string }) =>
    apiClient.post<ApiResponse<any>>('/withdrawals', data),

  list: (params?: { status?: string; page?: number; size?: number }) =>
    apiClient.get<ApiResponse<{ items: any[]; total: number }>>('/withdrawals', { params }),

  getBalance: () =>
    apiClient.get<ApiResponse<{ totalIncome: number; pendingIncome: number; withdrawableBalance: number }>>('/withdrawals/balance'),
};

// Category API
export const categoryApi = {
  getAll: () =>
    apiClient.get<ApiResponse<any[]>>('/categories'),

  getById: (categoryId: string) =>
    apiClient.get<ApiResponse<any>>(`/categories/${categoryId}`),
};

// Tag API
export const tagApi = {
  search: (keyword: string) =>
    apiClient.get<ApiResponse<any[]>>('/tags/search', { params: { keyword } }),

  getPopular: (limit?: number) =>
    apiClient.get<ApiResponse<any[]>>('/tags/popular', { params: { limit } }),
};
