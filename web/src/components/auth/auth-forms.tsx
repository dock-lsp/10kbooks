'use client';

import React, { useState } from 'react';
import { zodResolver } from '@hookform/resolvers/zod';
import { useForm } from 'react-hook-form';
import * as z from 'zod';
import { Eye, EyeOff, Loader2 } from 'lucide-react';
import { cn } from '@/lib/utils';
import { authService } from '@/services/auth.service';

const loginSchema = z.object({
  phone: z.string().min(1, '请输入手机号').regex(/^1[3-9]\d{9}$/, '请输入正确的手机号'),
  password: z.string().min(6, '密码至少6位'),
  rememberMe: z.boolean().optional(),
});

const registerSchema = z.object({
  phone: z.string().min(1, '请输入手机号').regex(/^1[3-9]\d{9}$/, '请输入正确的手机号'),
  captcha: z.string().length(6, '验证码为6位'),
  password: z
    .string()
    .min(8, '密码至少8位')
    .regex(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$/, '密码需包含大小写字母和数字'),
  confirmPassword: z.string(),
  inviteCode: z.string().optional(),
  agreeTerms: z.boolean().refine((val) => val === true, '请同意用户协议'),
}).refine((data) => data.password === data.confirmPassword, {
  message: '两次密码不一致',
  path: ['confirmPassword'],
});

type LoginFormData = z.infer<typeof loginSchema>;
type RegisterFormData = z.infer<typeof registerSchema>;

interface AuthFormsProps {
  defaultTab?: 'login' | 'register';
  onSuccess?: () => void;
  onForgotPassword?: () => void;
}

export function AuthForms({ defaultTab = 'login', onSuccess, onForgotPassword }: AuthFormsProps) {
  const [activeTab, setActiveTab] = useState<'login' | 'register'>(defaultTab);
  const [loginType, setLoginType] = useState<'password' | 'sms'>('password');
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loginForm = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
    defaultValues: {
      rememberMe: false,
    },
  });

  const registerForm = useForm<RegisterFormData>({
    resolver: zodResolver(registerSchema),
    defaultValues: {
      agreeTerms: false,
    },
  });

  const handleLogin = async (data: LoginFormData) => {
    setIsLoading(true);
    setError(null);
    try {
      await authService.login({
        phone: data.phone,
        password: data.password,
      });
      onSuccess?.();
    } catch (err: any) {
      setError(err.message || '登录失败');
    } finally {
      setIsLoading(false);
    }
  };

  const handleRegister = async (data: RegisterFormData) => {
    setIsLoading(true);
    setError(null);
    try {
      await authService.register({
        phone: data.phone,
        password: data.password,
        captcha: data.captcha,
        inviteCode: data.inviteCode,
      });
      onSuccess?.();
    } catch (err: any) {
      setError(err.message || '注册失败');
    } finally {
      setIsLoading(false);
    }
  };

  const handleSendCaptcha = async () => {
    const phone = registerForm.getValues('phone');
    if (!phone || !/^1[3-9]\d{9}$/.test(phone)) {
      registerForm.setError('phone', { message: '请输入正确的手机号' });
      return;
    }
    // Send captcha logic here
  };

  return (
    <div className="w-full max-w-md mx-auto">
      {/* Header */}
      <div className="text-center mb-8">
        <div className="w-20 h-20 mx-auto mb-4 bg-primary rounded-2xl flex items-center justify-center">
          <svg className="w-10 h-10 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
          </svg>
        </div>
        <h1 className="text-2xl font-bold text-gray-900">万卷书苑</h1>
        <p className="text-gray-500 mt-1">Welcome Back</p>
      </div>

      {/* Tab Switch */}
      <div className="flex bg-gray-100 rounded-xl p-1 mb-6">
        <button
          onClick={() => setActiveTab('login')}
          className={cn(
            'flex-1 py-2.5 text-sm font-medium rounded-lg transition-all',
            activeTab === 'login' ? 'bg-white shadow-sm' : 'text-gray-500 hover:text-gray-700'
          )}
        >
          密码登录
        </button>
        <button
          onClick={() => setActiveTab('register')}
          className={cn(
            'flex-1 py-2.5 text-sm font-medium rounded-lg transition-all',
            activeTab === 'register' ? 'bg-white shadow-sm' : 'text-gray-500 hover:text-gray-700'
          )}
        >
          注册账号
        </button>
      </div>

      {/* Error Message */}
      {error && (
        <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg text-red-600 text-sm">
          {error}
        </div>
      )}

      {/* Login Form */}
      {activeTab === 'login' && (
        <form onSubmit={loginForm.handleSubmit(handleLogin)} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">手机号</label>
            <input
              {...loginForm.register('phone')}
              type="tel"
              placeholder="请输入手机号"
              className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all"
            />
            {loginForm.formState.errors.phone && (
              <p className="mt-1 text-sm text-red-500">{loginForm.formState.errors.phone.message}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">密码</label>
            <div className="relative">
              <input
                {...loginForm.register('password')}
                type={showPassword ? 'text' : 'password'}
                placeholder="请输入密码"
                className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all pr-12"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
              >
                {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
              </button>
            </div>
            {loginForm.formState.errors.password && (
              <p className="mt-1 text-sm text-red-500">{loginForm.formState.errors.password.message}</p>
            )}
          </div>

          <div className="flex items-center justify-between">
            <label className="flex items-center">
              <input
                {...loginForm.register('rememberMe')}
                type="checkbox"
                className="w-4 h-4 text-primary border-gray-300 rounded focus:ring-primary"
              />
              <span className="ml-2 text-sm text-gray-600">记住我</span>
            </label>
            <button type="button" onClick={onForgotPassword} className="text-sm text-primary hover:underline">
              忘记密码？
            </button>
          </div>

          <button
            type="submit"
            disabled={isLoading}
            className="w-full py-3 bg-primary text-white font-medium rounded-xl hover:bg-primary/90 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center"
          >
            {isLoading ? <Loader2 className="w-5 h-5 animate-spin" /> : '登录'}
          </button>
        </form>
      )}

      {/* Register Form */}
      {activeTab === 'register' && (
        <form onSubmit={registerForm.handleSubmit(handleRegister)} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">手机号</label>
            <input
              {...registerForm.register('phone')}
              type="tel"
              placeholder="请输入手机号"
              className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all"
            />
            {registerForm.formState.errors.phone && (
              <p className="mt-1 text-sm text-red-500">{registerForm.formState.errors.phone.message}</p>
            )}
          </div>

          <div className="flex gap-2">
            <div className="flex-1">
              <label className="block text-sm font-medium text-gray-700 mb-1">验证码</label>
              <input
                {...registerForm.register('captcha')}
                type="text"
                placeholder="请输入验证码"
                className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all"
              />
            </div>
            <button
              type="button"
              onClick={handleSendCaptcha}
              className="mt-7 px-4 py-3 bg-primary/10 text-primary font-medium rounded-xl hover:bg-primary/20 transition-all"
            >
              获取验证码
            </button>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">密码</label>
            <div className="relative">
              <input
                {...registerForm.register('password')}
                type={showPassword ? 'text' : 'password'}
                placeholder="请设置密码（至少8位）"
                className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all pr-12"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
              >
                {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
              </button>
            </div>
            {registerForm.formState.errors.password && (
              <p className="mt-1 text-sm text-red-500">{registerForm.formState.errors.password.message}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">确认密码</label>
            <input
              {...registerForm.register('confirmPassword')}
              type="password"
              placeholder="请再次输入密码"
              className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all"
            />
            {registerForm.formState.errors.confirmPassword && (
              <p className="mt-1 text-sm text-red-500">{registerForm.formState.errors.confirmPassword.message}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">邀请码（选填）</label>
            <input
              {...registerForm.register('inviteCode')}
              type="text"
              placeholder="请输入邀请码"
              className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all"
            />
          </div>

          <div className="flex items-start">
            <input
              {...registerForm.register('agreeTerms')}
              type="checkbox"
              className="mt-1 w-4 h-4 text-primary border-gray-300 rounded focus:ring-primary"
            />
            <span className="ml-2 text-sm text-gray-600">
              我已阅读并同意
              <a href="/terms" className="text-primary hover:underline">《用户协议》</a>
              和
              <a href="/privacy" className="text-primary hover:underline">《隐私政策》</a>
            </span>
          </div>
          {registerForm.formState.errors.agreeTerms && (
            <p className="text-sm text-red-500">{registerForm.formState.errors.agreeTerms.message}</p>
          )}

          <button
            type="submit"
            disabled={isLoading}
            className="w-full py-3 bg-primary text-white font-medium rounded-xl hover:bg-primary/90 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center"
          >
            {isLoading ? <Loader2 className="w-5 h-5 animate-spin" /> : '注册'}
          </button>
        </form>
      )}

      {/* Social Login */}
      <div className="mt-8">
        <div className="relative">
          <div className="absolute inset-0 flex items-center">
            <div className="w-full border-t border-gray-200" />
          </div>
          <div className="relative flex justify-center text-sm">
            <span className="px-4 bg-white text-gray-500">其他登录方式</span>
          </div>
        </div>
        <div className="mt-6 flex justify-center gap-6">
          <button className="w-12 h-12 rounded-full border border-gray-200 hover:bg-gray-50 transition-all flex items-center justify-center">
            <svg className="w-6 h-6 text-green-500" viewBox="0 0 24 24" fill="currentColor">
              <path d="M20.28 19.462c-1.125 0-2.025.562-2.625 1.125l-2.175-2.362c.337-.337.637-.675 1.05-.9.9-.45 1.687-.338 2.288.113.788.6 1.763 1.987 1.462 2.024zm-2.588-4.387c-.337.338-.787.45-1.237.225-.45-.225-.675-.562-.787-.9l2.138-2.25c.337.45.45.787.337 1.237-.113.45-.337.788-.788 1.012l.112.112-2.362 2.362-.337-.337 1.5-1.462c.113-.113.113-.113.225-.113.337 0 .675.225.9.562l1.687 1.8c-.337.225-.562.337-.9.337-.337 0-.562-.112-.787-.337l-1.35-1.462.337-.337 1.687 1.8c-.225.225-.562.337-.9.337s-.675-.112-.9-.337l-3.375-3.6c-.225-.225-.337-.562-.337-.9s.112-.675.337-.9l3.375-3.6c.225-.225.562-.337.9-.337.337 0 .675.112.9.337l1.35 1.462-.337.337-1.687-1.8c-.112.113-.225.113-.337.113-.337 0-.675-.225-.9-.562l-1.687-1.8c.337-.225.562-.337.9-.337s.675.112.9.337l2.362 2.362.337-.337-1.5-1.462c-.113-.113-.113-.113-.225-.113-.337 0-.675-.225-.9-.562l-1.687-1.8c.225-.225.562-.337.9-.337.337 0 .562.112.787.337l3.375 3.6c.225.225.337.562.337.9s-.112.675-.337.9l-3.375 3.6c-.225.225-.562.337-.9.337-.337 0-.675-.112-.9-.337l-1.35-1.462.337-.337 1.687 1.8c.112-.113.225-.113.337-.113z"/>
            </svg>
          </button>
          <button className="w-12 h-12 rounded-full border border-gray-200 hover:bg-gray-50 transition-all flex items-center justify-center">
            <svg className="w-6 h-6" viewBox="0 0 24 24" fill="currentColor">
              <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
            </svg>
          </button>
          <button className="w-12 h-12 rounded-full border border-gray-200 hover:bg-gray-50 transition-all flex items-center justify-center">
            <svg className="w-6 h-6 text-blue-500" viewBox="0 0 24 24" fill="currentColor">
              <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
              <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
              <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
              <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
            </svg>
          </button>
        </div>
      </div>
    </div>
  );
}
