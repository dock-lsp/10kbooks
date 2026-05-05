import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/blocs/auth/auth_bloc.dart';
import '../../../core/blocs/book/book_bloc.dart';
import '../../../shared/models/book_model.dart';
import '../../../../core/config/theme_config.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _unreadCount = 5;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息通知'),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  _unreadCount = 0;
                });
              },
              child: const Text('全部已读'),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '通知'),
            Tab(text: '互动'),
            Tab(text: '系统'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationList('notification'),
          _buildNotificationList('interaction'),
          _buildNotificationList('system'),
        ],
      ),
    );
  }

  Widget _buildNotificationList(String type) {
    final notifications = _getMockNotifications(type);

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '暂无消息',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final isUnread = notification['isUnread'] as bool? ?? false;

    return InkWell(
      onTap: () {
        setState(() {
          notification['isUnread'] = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isUnread ? AppTheme.primaryColor.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnread ? AppTheme.primaryColor.withOpacity(0.3) : Colors.grey[200]!,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (notification['iconColor'] as Color? ?? AppTheme.primaryColor)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                notification['icon'] as IconData? ?? Icons.notifications,
                color: notification['iconColor'] as Color? ?? AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification['title'] as String? ?? '',
                          style: TextStyle(
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(notification['time'] as DateTime? ?? DateTime.now()),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['content'] as String? ?? '',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Unread indicator
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 8),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getMockNotifications(String type) {
    switch (type) {
      case 'notification':
        return [
          {
            'icon': Icons.new_releases,
            'iconColor': Colors.red,
            'title': '作品审核通过',
            'content': '您的作品《xxx》已审核通过，现在可以正式发布啦！',
            'time': DateTime.now().subtract(const Duration(hours: 1)),
            'isUnread': true,
          },
          {
            'icon': Icons.book,
            'iconColor': Colors.blue,
            'title': '章节更新提醒',
            'content': '您关注的《xxx》作者更新了新的章节，快去看看吧！',
            'time': DateTime.now().subtract(const Duration(hours: 3)),
            'isUnread': true,
          },
          {
            'icon': Icons.campaign,
            'iconColor': Colors.orange,
            'title': '活动通知',
            'content': '万卷书苑周年庆活动开启，VIP会员限时优惠中！',
            'time': DateTime.now().subtract(const Duration(days: 1)),
            'isUnread': false,
          },
        ];
      case 'interaction':
        return [
          {
            'icon': Icons.favorite,
            'iconColor': Colors.pink,
            'title': '收到点赞',
            'content': '用户xxx赞了您的评论',
            'time': DateTime.now().subtract(const Duration(minutes: 30)),
            'isUnread': true,
          },
          {
            'icon': Icons.comment,
            'iconColor': Colors.green,
            'title': '新评论',
            'content': '用户xxx回复了您的评论：写的真好！',
            'time': DateTime.now().subtract(const Duration(hours: 2)),
            'isUnread': true,
          },
          {
            'icon': Icons.person_add,
            'iconColor': Colors.purple,
            'title': '新粉丝',
            'content': '作者xxx关注了您',
            'time': DateTime.now().subtract(const Duration(days: 1)),
            'isUnread': false,
          },
        ];
      case 'system':
        return [
          {
            'icon': Icons.account_balance_wallet,
            'iconColor': Colors.teal,
            'title': '收益到账',
            'content': '您本周的阅读收益已到账，共计100元',
            'time': DateTime.now().subtract(const Duration(days: 1)),
            'isUnread': false,
          },
          {
            'icon': Icons.vpn_key,
            'iconColor': Colors.blue,
            'title': '安全提醒',
            'content': '您的账号在新设备登录，如非本人操作请及时修改密码',
            'time': DateTime.now().subtract(const Duration(days: 3)),
            'isUnread': false,
          },
        ];
      default:
        return [];
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return '刚刚';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return '${time.month}/${time.day}';
    }
  }
}
