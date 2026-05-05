import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../shared/services/user_service.dart';
import '../../../shared/models/user_model.dart';
import '../../di/service_locator.dart';

// Events
abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class UserProfileRequested extends UserEvent {
  final String userId;

  const UserProfileRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class UserFollowRequested extends UserEvent {
  final String userId;

  const UserFollowRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class UserUnfollowRequested extends UserEvent {
  final String userId;

  const UserUnfollowRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class UserFollowersRequested extends UserEvent {
  final String userId;
  final int page;
  final int size;

  const UserFollowersRequested({
    required this.userId,
    this.page = 1,
    this.size = 20,
  });

  @override
  List<Object?> get props => [userId, page, size];
}

class UserFollowingRequested extends UserEvent {
  final String userId;
  final int page;
  final int size;

  const UserFollowingRequested({
    required this.userId,
    this.page = 1,
    this.size = 20,
  });

  @override
  List<Object?> get props => [userId, page, size];
}

class UserBooksRequested extends UserEvent {
  final String userId;
  final int page;
  final int size;

  const UserBooksRequested({
    required this.userId,
    this.page = 1,
    this.size = 20,
  });

  @override
  List<Object?> get props => [userId, page, size];
}

class UserSearchRequested extends UserEvent {
  final String keyword;
  final int page;
  final int size;

  const UserSearchRequested({
    required this.keyword,
    this.page = 1,
    this.size = 20,
  });

  @override
  List<Object?> get props => [keyword, page, size];
}

// States
abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserProfileLoaded extends UserState {
  final User user;
  final int followersCount;
  final int followingCount;
  final int booksCount;
  final bool isFollowing;

  const UserProfileLoaded({
    required this.user,
    this.followersCount = 0,
    this.followingCount = 0,
    this.booksCount = 0,
    this.isFollowing = false,
  });

  @override
  List<Object?> get props => [user, followersCount, followingCount, booksCount, isFollowing];
}

class UserListLoaded extends UserState {
  final List<User> users;
  final int total;
  final int page;
  final bool hasMore;

  const UserListLoaded({
    required this.users,
    required this.total,
    required this.page,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [users, total, page, hasMore];
}

class UserOperationSuccess extends UserState {
  final String message;
  final bool isFollowing;

  const UserOperationSuccess({required this.message, required this.isFollowing});

  @override
  List<Object?> get props => [message, isFollowing];
}

class UserError extends UserState {
  final String message;

  const UserError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserService _userService;

  UserBloc({UserService? userService})
      : _userService = userService ?? getIt<UserService>(),
        super(UserInitial()) {
    on<UserProfileRequested>(_onProfileRequested);
    on<UserFollowRequested>(_onFollowRequested);
    on<UserUnfollowRequested>(_onUnfollowRequested);
    on<UserFollowersRequested>(_onFollowersRequested);
    on<UserFollowingRequested>(_onFollowingRequested);
    on<UserBooksRequested>(_onBooksRequested);
    on<UserSearchRequested>(_onSearchRequested);
  }

  Future<void> _onProfileRequested(
    UserProfileRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final result = await _userService.getUserProfile(event.userId);

      emit(UserProfileLoaded(
        user: User.fromJson(result['user'] as Map<String, dynamic>),
        followersCount: result['followersCount'] as int? ?? 0,
        followingCount: result['followingCount'] as int? ?? 0,
        booksCount: result['booksCount'] as int? ?? 0,
        isFollowing: result['isFollowing'] as bool? ?? false,
      ));
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onFollowRequested(
    UserFollowRequested event,
    Emitter<UserState> emit,
  ) async {
    try {
      await _userService.followUser(event.userId);
      emit(UserOperationSuccess(message: 'Followed successfully', isFollowing: true));
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onUnfollowRequested(
    UserUnfollowRequested event,
    Emitter<UserState> emit,
  ) async {
    try {
      await _userService.unfollowUser(event.userId);
      emit(UserOperationSuccess(message: 'Unfollowed successfully', isFollowing: false));
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onFollowersRequested(
    UserFollowersRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final result = await _userService.getFollowers(
        userId: event.userId,
        page: event.page,
        size: event.size,
      );

      final users = (result['items'] as List)
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();

      final total = result['total'] as int;
      final hasMore = event.page * event.size < total;

      emit(UserListLoaded(
        users: users,
        total: total,
        page: event.page,
        hasMore: hasMore,
      ));
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onFollowingRequested(
    UserFollowingRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final result = await _userService.getFollowing(
        userId: event.userId,
        page: event.page,
        size: event.size,
      );

      final users = (result['items'] as List)
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();

      final total = result['total'] as int;
      final hasMore = event.page * event.size < total;

      emit(UserListLoaded(
        users: users,
        total: total,
        page: event.page,
        hasMore: hasMore,
      ));
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onBooksRequested(
    UserBooksRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final result = await _userService.getUserBooks(
        userId: event.userId,
        page: event.page,
        size: event.size,
      );

      final users = (result['items'] as List)
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();

      final total = result['total'] as int;
      final hasMore = event.page * event.size < total;

      emit(UserListLoaded(
        users: users,
        total: total,
        page: event.page,
        hasMore: hasMore,
      ));
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onSearchRequested(
    UserSearchRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final result = await _userService.searchUsers(
        keyword: event.keyword,
        page: event.page,
        size: event.size,
      );

      final users = (result['items'] as List)
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();

      final total = result['total'] as int;
      final hasMore = event.page * event.size < total;

      emit(UserListLoaded(
        users: users,
        total: total,
        page: event.page,
        hasMore: hasMore,
      ));
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }
}