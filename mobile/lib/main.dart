import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/config/app_config.dart';
import 'core/config/theme_config.dart';
import 'core/router/app_router.dart';
import 'core/di/service_locator.dart';
import 'core/network/storage_service.dart';
import 'core/blocs/auth/auth_bloc.dart';
import 'core/blocs/book/book_bloc.dart';
import 'core/blocs/reader/reader_bloc.dart';
import 'core/blocs/user/user_bloc.dart';
import 'shared/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize services
  await _initServices();

  runApp(const TenKBooksApp());
}

Future<void> _initServices() async {
  // Initialize service locator
  await serviceLocatorInit();

  // Initialize storage service
  await getIt<StorageService>().init();

  // Initialize notification service
  try {
    await getIt<NotificationService>().init();
  } catch (e) {
    debugPrint('Notification service init failed: $e');
  }
}

class TenKBooksApp extends StatefulWidget {
  const TenKBooksApp({super.key});

  @override
  State<TenKBooksApp> createState() => _TenKBooksAppState();
}

class _TenKBooksAppState extends State<TenKBooksApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc()..add(AuthCheckRequested()),
        ),
        BlocProvider<BookBloc>(
          create: (context) => BookBloc(),
        ),
        BlocProvider<ReaderBloc>(
          create: (context) => ReaderBloc(),
        ),
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(),
        ),
      ],
      child: MaterialApp.router(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,

        // Theme
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,

        // Router
        routerConfig: _appRouter.router,

        // Localization
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh', 'CN'),
          Locale('en'),
          Locale('es'),
          Locale('fr'),
          Locale('de'),
          Locale('ru'),
          Locale('ar'),
        ],
        locale: const Locale('zh', 'CN'),
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode) {
              return supportedLocale;
            }
          }
          return const Locale('zh', 'CN');
        },
      ),
    );
  }
}