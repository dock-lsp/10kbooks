import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/services/auth_service.dart';
import '../../network/storage_service.dart';
import '../../di/service_locator.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String? phone;
  final String? email;
  final String password;
  final String? captcha;

  const AuthLoginRequested({
    this.phone,
    this.email,
    required this.password,
    this.captcha,
  });

  @override
  List<Object?> get props => [phone, email, password, captcha];
}

class AuthRegisterRequested extends AuthEvent {
  final String? phone;
  final String? email;
  final String password;
  final String? inviteCode;
  final String? captcha;

  const AuthRegisterRequested({
    this.phone,
    this.email,
    required this.password,
    this.inviteCode,
    this.captcha,
  });

  @override
  List<Object?> get props => [phone, email, password, inviteCode, captcha];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthRefreshTokenRequested extends AuthEvent {}

class AuthUpdateUserRequested extends AuthEvent {
  final String? nickname;
  final String? avatar;
  final String? bio;
  final String? language;

  const AuthUpdateUserRequested({
    this.nickname,
    this.avatar,
    this.bio,
    this.language,
  });

  @override
  List<Object?> get props => [nickname, avatar, bio, language];
}

class AuthRealAuthRequested extends AuthEvent {
  final String idCardType;
  final String idCardFront;
  final String idCardBack;
  final String? handheldPhoto;

  const AuthRealAuthRequested({
    required this.idCardType,
    required this.idCardFront,
    required this.idCardBack,
    this.handheldPhoto,
  });

  @override
  List<Object?> get props => [idCardType, idCardFront, idCardBack, handheldPhoto];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final String accessToken;
  final String? refreshToken;

  const AuthAuthenticated({
    required this.user,
    required this.accessToken,
    this.refreshToken,
  });

  @override
  List<Object?> get props => [user, accessToken, refreshToken];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  final int? code;

  const AuthError({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final StorageService _storageService;

  AuthBloc({
    AuthService? authService,
    StorageService? storageService,
  })  : _authService = authService ?? getIt<AuthService>(),
        _storageService = storageService ?? getIt<StorageService>(),
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthRefreshTokenRequested>(_onRefreshTokenRequested);
    on<AuthUpdateUserRequested>(_onUpdateUserRequested);
    on<AuthRealAuthRequested>(_onRealAuthRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final token = await _storageService.getAccessToken();
      if (token == null) {
        emit(AuthUnauthenticated());
        return;
      }

      final user = await _authService.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(
          user: user,
          accessToken: token,
          refreshToken: await _storageService.getRefreshToken(),
        ));
      } else {
        await _storageService.clearAll();
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      await _storageService.clearAll();
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _authService.login(
        phone: event.phone,
        email: event.email,
        password: event.password,
        captcha: event.captcha,
      );

      if (!result.success || result.data == null) {
        throw Exception(result.message ?? 'Login failed');
      }

      final data = result.data!;
      await _storageService.saveToken(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String?,
      );

      emit(AuthAuthenticated(
        user: User.fromJson(data['user'] as Map<String, dynamic>),
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String?,
      ));
    } catch (e) {
      emit(AuthError(message: e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _authService.register(
        phone: event.phone,
        email: event.email,
        password: event.password,
        inviteCode: event.inviteCode,
        captcha: event.captcha,
      );

      if (!result.success || result.data == null) {
        throw Exception(result.message ?? 'Registration failed');
      }

      final data = result.data!;
      await _storageService.saveToken(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String?,
      );

      emit(AuthAuthenticated(
        user: User.fromJson(data['user'] as Map<String, dynamic>),
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String?,
      ));
    } catch (e) {
      emit(AuthError(message: e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.logout();
    } catch (_) {
      // Ignore logout errors
    } finally {
      await _storageService.clearAll();
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onRefreshTokenRequested(
    AuthRefreshTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthAuthenticated) return;

    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) {
        emit(AuthUnauthenticated());
        return;
      }

      final result = await _authService.refreshToken(refreshToken);

      if (!result.success || result.data == null) {
        throw Exception(result.message ?? 'Token refresh failed');
      }

      final data = result.data!;
      await _storageService.saveToken(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String?,
      );

      emit(AuthAuthenticated(
        user: (state as AuthAuthenticated).user,
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String?,
      ));
    } catch (e) {
      await _storageService.clearAll();
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onUpdateUserRequested(
    AuthUpdateUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthAuthenticated) return;

    try {
      final result = await _authService.updateProfile(
        nickname: event.nickname,
        avatar: event.avatar,
        bio: event.bio,
        language: event.language,
      );

      if (!result.success || result.data == null) {
        throw Exception(result.message ?? 'Update failed');
      }

      final user = result.data!;

      emit(AuthAuthenticated(
        user: user,
        accessToken: (state as AuthAuthenticated).accessToken,
        refreshToken: (state as AuthAuthenticated).refreshToken,
      ));
    } catch (e) {
      emit(AuthError(message: e.toString()));
      emit(state);
    }
  }

  Future<void> _onRealAuthRequested(
    AuthRealAuthRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthAuthenticated) return;

    emit(AuthLoading());
    try {
      final result = await _authService.submitRealAuth(
        idCardType: event.idCardType,
        idCardFront: event.idCardFront,
        idCardBack: event.idCardBack,
        handheldPhoto: event.handheldPhoto,
      );

      if (!result.success) {
        throw Exception(result.message ?? 'Real auth failed');
      }

      // Refresh user data
      final user = await _authService.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(
          user: user,
          accessToken: (state as AuthAuthenticated).accessToken,
          refreshToken: (state as AuthAuthenticated).refreshToken,
        ));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
      emit(state);
    }
  }
}
