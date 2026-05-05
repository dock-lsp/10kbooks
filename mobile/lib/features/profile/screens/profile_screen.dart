import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/blocs/auth/auth_bloc.dart';
import '../../../core/blocs/user/user_bloc.dart';
import '../../../shared/models/user_model.dart';
import '../../../../core/config/theme_config.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({
    super.key,
    this.userId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final profileUserId = widget.userId ?? authState.user.id;
      context.read<UserBloc>().add(UserProfileRequested(userId: profileUserId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          return BlocBuilder<UserBloc, UserState>(
            builder: (context, userState) {
              if (userState is UserLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (userState is UserProfileLoaded) {
                return _buildProfileContent(context, userState, authState);
              }

              // Fallback: show authenticated user's basic profile
              return _buildBasicProfile(context, authState.user);
            },
          );
        },
      ),
    );
  }

  Widget _buildBasicProfile(BuildContext context, UserModel user) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -50),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: AppTheme.primaryColor,
                      backgroundImage: user.avatar != null
                          ? NetworkImage(user.avatar!)
                          : null,
                      child: user.avatar == null
                          ? const Icon(Icons.person, size: 48, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name and bio
                  Text(
                    user.nickname,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (user.bio != null)
                    Text(
                      user.bio!,
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 24),

                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('关注', '0'),
                      _buildStatItem('粉丝', '0'),
                      _buildStatItem('作品', '0'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Menu items
                  _buildMenuSection(context),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileContent(BuildContext context, UserProfileLoaded state, AuthAuthenticated authState) {
    final isOwnProfile = state.user.id == authState.user.id;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          actions: isOwnProfile
              ? [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {
                      // Navigate to settings
                    },
                  ),
                ]
              : null,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -50),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 48,
                          backgroundColor: AppTheme.primaryColor,
                          backgroundImage: state.user.avatar != null
                              ? NetworkImage(state.user.avatar!)
                              : null,
                          child: state.user.avatar == null
                              ? const Icon(Icons.person, size: 48, color: Colors.white)
                              : null,
                        ),
                      ),
                      if (state.user.vipStatus != 'none')
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: 12, color: Colors.white),
                                SizedBox(width: 2),
                                Text(
                                  'VIP',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Name and bio
                  Text(
                    state.user.nickname,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (state.user.bio != null)
                    Text(
                      state.user.bio!,
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 24),

                  // Action buttons
                  if (!isOwnProfile)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            if (state.isFollowing) {
                              context.read<UserBloc>().add(
                                    UserUnfollowRequested(userId: state.user.id),
                                  );
                            } else {
                              context.read<UserBloc>().add(
                                    UserFollowRequested(userId: state.user.id),
                                  );
                            }
                          },
                          icon: Icon(
                            state.isFollowing ? Icons.check : Icons.add,
                          ),
                          label: Text(state.isFollowing ? '已关注' : '关注'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: state.isFollowing
                                ? Colors.grey[200]
                                : AppTheme.primaryColor,
                            foregroundColor: state.isFollowing
                                ? Colors.black87
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            // Message
                          },
                          icon: const Icon(Icons.mail_outline),
                          label: const Text('私信'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),

                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('关注', state.followingCount.toString()),
                      _buildStatItem('粉丝', state.followersCount.toString()),
                      _buildStatItem('作品', state.booksCount.toString()),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Menu items
                  _buildMenuSection(context),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.book_outlined,
          title: '我的书架',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.history,
          title: '阅读历史',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.bookmark_outline,
          title: '我的收藏',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.list_alt,
          title: '我的书单',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.wallet_outlined,
          title: '我的钱包',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.card_membership,
          title: 'VIP会员',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.help_outline,
          title: '帮助与反馈',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
