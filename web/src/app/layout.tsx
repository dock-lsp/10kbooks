import type { Metadata, Viewport } from 'next';
import { Inter, Noto_Sans_SC } from 'next/font/google';
import { Toaster } from 'react-hot-toast';
import { Providers } from './providers';
import './globals.css';

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-sans',
});

const notoSansSC = Noto_Sans_SC({
  subsets: ['latin'],
  variable: '--font-sc',
  weight: ['300', '400', '500', '700'],
});

export const metadata: Metadata = {
  title: {
    default: '万卷书苑 - 10kbooks',
    template: '%s | 万卷书苑 - 10kbooks',
  },
  description: '数字阅读与创作平台，提供从书籍创作、发布、阅读到社交互动的全流程服务',
  keywords: ['电子书', '阅读', '创作', '作者', '出版', '10kbooks', '万卷书苑'],
  authors: [{ name: '10kbooks Technology Team' }],
  creator: '10kbooks',
  publisher: '10kbooks',
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  metadataBase: new URL(process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000'),
  openGraph: {
    type: 'website',
    locale: 'zh_CN',
    siteName: '万卷书苑 - 10kbooks',
    title: '万卷书苑 - 10kbooks',
    description: '数字阅读与创作平台',
    images: [
      {
        url: '/og-image.jpg',
        width: 1200,
        height: 630,
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: '万卷书苑 - 10kbooks',
    description: '数字阅读与创作平台',
    images: ['/og-image.jpg'],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  verification: {
    google: 'your-google-verification-code',
  },
};

export const viewport: Viewport = {
  themeColor: [
    { media: '(prefers-color-scheme: light)', color: '#0ea5e9' },
    { media: '(prefers-color-scheme: dark)', color: '#0c4a6e' },
  ],
  width: 'device-width',
  initialScale: 1,
  maximumScale: 5,
};

export default function RootLayout({
  children,
  params: { locale }
}: {
  children: React.ReactNode;
  params: { locale: string };
}) {
  return (
    <html
      lang={locale}
      className={`${inter.variable} ${notoSansSC.variable}`}
      suppressHydrationWarning
    >
      <head>
        <link rel="icon" href="/favicon.ico" sizes="any" />
        <link rel="icon" href="/icon.svg" type="image/svg+xml" />
        <link rel="apple-touch-icon" href="/apple-touch-icon.png" />
      </head>
      <body className="min-h-screen bg-background antialiased">
        <Providers locale={locale}>
          {children}
          <Toaster
            position="top-center"
            gutter={12}
            containerClassName="font-sans"
            toastOptions={{
              success: {
                duration: 4000,
                style: {
                  background: 'hsl(var(--background))',
                  color: 'hsl(var(--foreground))',
                  border: '1px solid hsl(var(--border))',
                },
              },
              error: {
                duration: 5000,
                style: {
                  background: 'hsl(var(--destructive))',
                  color: 'hsl(var(--destructive-foreground))',
                },
              },
            }}
          />
        </Providers>
      </body>
    </html>
  );
}
