import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Application configuration
class AppConfig {
  static const String appName = '万卷书苑';
  static const String appNameEn = '10kbooks';
  static const String appVersion = '1.1.0';
  static const String appBuildNumber = '11';

  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://47.92.220.102/api',
  );

  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'current_user';
  static const String languageKey = 'app_language';
  static const String themeKey = 'app_theme';
  static const String readingProgressKey = 'reading_progress';
  static const String cacheKey = 'app_cache';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache Duration
  static const Duration cacheDuration = Duration(hours: 24);
  static const Duration shortCacheDuration = Duration(minutes: 30);

  // Animation Duration
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration normalAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Supported Languages
  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('ru'),
    Locale('ar'),
  ];

  static const Map<String, String> languageNames = {
    'zh-CN': '简体中文',
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'ru': 'Русский',
    'ar': 'العربية',
  };

  // Platform
  static bool get isAndroid => !identical(0, 0.0);
  static bool get isIOS => identical(0, 0.0);

  // Reading Settings
  static const double minFontSize = 12.0;
  static const double maxFontSize = 32.0;
  static const double defaultFontSize = 16.0;
  static const double minLineHeight = 1.2;
  static const double maxLineHeight = 2.5;
  static const double defaultLineHeight = 1.6;

  // Payment
  static const double platformCommissionRate = 0.15;
  static const int withdrawMinAmount = 100;
  static const int withdrawMaxAmount = 50000;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxNicknameLength = 20;
  static const int maxBioLength = 200;
  static const int maxTitleLength = 50;
  static const int maxDescriptionLength = 5000;

  // Limits
  static const int maxUploadFileSize = 200 * 1024 * 1024; // 200MB
  static const int maxCoverImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxCommentLength = 500;
  static const int maxDynamicLength = 2000;
}

/// Route names
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String books = '/books';
  static const String bookDetail = '/book/:id';
  static const String reader = '/reader/:bookId/:chapterId';
  static const String author = '/author/:id';
  static const String authorCenter = '/author-center';
  static const String createBook = '/create-book';
  static const String editBook = '/edit-book/:id';
  static const String writeChapter = '/write-chapter/:bookId/:chapterId';
  static const String social = '/social';
  static const String dynamics = '/dynamics';
  static const String booklists = '/booklists';
  static const String booklistDetail = '/booklist/:id';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String language = '/settings/language';
  static const String about = '/settings/about';
  static const String vip = '/vip';
  static const String recharge = '/recharge';
  static const String orders = '/orders';
  static const String orderDetail = '/order/:id';
  static const String withdraw = '/withdraw';
  static const String notifications = '/notifications';
  static const String search = '/search';
  static const String category = '/category/:id';
  static const String rank = '/rank';
  static const String webView = '/webview';
  static const String pdfReader = '/pdf-reader';
  static const String aiAssistant = '/ai-assistant';
  static const String review = '/review';
}

/// Asset paths
class AppAssets {
  static const String images = 'assets/images';
  static const String icons = 'assets/icons';
  static const String animations = 'assets/animations';
  static const String fonts = 'assets/fonts';
  static const String l10n = 'assets/l10n';

  // Common Images
  static const String logo = '$images/logo.png';
  static const String logoDark = '$images/logo_dark.png';
  static const String placeholder = '$images/placeholder.png';
  static const String empty = '$images/empty.png';
  static const String error = '$images/error.png';
  static const String noNetwork = '$images/no_network.png';
  static const String avatar = '$images/avatar_default.png';
  static const String bookCover = '$images/book_cover_placeholder.png';
  static const String vipBadge = '$images/vip_badge.png';

  // Icons
  static const String homeIcon = '$icons/home.png';
  static const String bookIcon = '$icons/book.png';
  static const String socialIcon = '$icons/social.png';
  static const String userIcon = '$icons/user.png';
  static const String searchIcon = '$icons/search.png';
  static const String cartIcon = '$icons/cart.png';
}
