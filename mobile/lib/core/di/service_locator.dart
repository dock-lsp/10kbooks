import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../network/storage_service.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/services/book_service.dart';
import '../../shared/services/user_service.dart';
import '../../shared/services/notification_service.dart';
import '../../shared/services/payment_service.dart';

final getIt = GetIt.instance;

Future<void> serviceLocatorInit() async {
  // Core Services
  final storageService = StorageService();
  await storageService.init();
  getIt.registerSingleton<StorageService>(storageService);

  final apiClient = ApiClient();
  getIt.registerSingleton<ApiClient>(apiClient);

  // Feature Services
  getIt.registerLazySingleton<AuthService>(() => AuthService(getIt(), getIt()));
  getIt.registerLazySingleton<BookService>(() => BookService(getIt(), getIt()));
  getIt.registerLazySingleton<UserService>(() => UserService(getIt(), getIt()));
  getIt.registerLazySingleton<NotificationService>(() => NotificationService(getIt(), getIt()));
  getIt.registerLazySingleton<PaymentService>(() => PaymentService(getIt(), getIt()));
}
