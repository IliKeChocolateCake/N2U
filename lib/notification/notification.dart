import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n2u/notification/notification_details.dart';
import 'package:n2u/profile/profile.dart';
import 'package:n2u/const/constant.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:easy_localization/easy_localization.dart';

// Initialize flutter_local_notifications
final fln.FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
fln.FlutterLocalNotificationsPlugin();

class NotificationItem {
  final String id;
  final String type;
  final String title;
  final String message;
  final String time;
  bool isRead;
  final IconData icon;
  final Color color;
  final String? imageUrl;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.icon,
    required this.color,
    this.imageUrl,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? 'general',
      title: json['title'] ?? 'Notification',
      message: json['message'] ?? '',
      time: _formatTime(json['created_at']),
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      icon: _getIconForType(json['type']),
      color: _getColorForType(json['type']),
      imageUrl: json['image_url'],
    );
  }

  static String _formatTime(String? dateString) {
    if (dateString == null) return 'Just now';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
      if (diff.inDays < 7) return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Recently';
    }
  }

  static IconData _getIconForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'order':
        return Icons.shopping_bag;
      case 'payment':
        return Icons.payment;
      case 'voucher':
        return Icons.card_giftcard;
      case 'promotion':
      case 'promo':
        return Icons.local_offer;
      case 'subscription':
        return Icons.diamond;
      case 'referral':
        return Icons.people;
      case 'message':
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }

  static Color _getColorForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'order':
        return Colors.blue;
      case 'payment':
        return Colors.green;
      case 'voucher':
        return Colors.purple;
      case 'promotion':
      case 'promo':
        return Colors.orange;
      case 'subscription':
        return Colors.amber;
      case 'referral':
        return Colors.teal;
      case 'message':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}

class Noti extends StatefulWidget {
  const Noti({super.key});

  @override
  State<Noti> createState() => NotificationPage();
}

class NotificationPage extends State<Noti> {
  String activeTab = 'all';
  List<NotificationItem> notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLocalNotifications();
    _loadNotifications();
    _setupOneSignalListeners();
  }

  // Initialize flutter_local_notifications
  Future<void> _initializeLocalNotifications() async {
    const fln.AndroidInitializationSettings androidSettings =
    fln.AndroidInitializationSettings('@mipmap/ic_launcher');

    const fln.DarwinInitializationSettings iosSettings =
    fln.DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const fln.InitializationSettings initSettings = fln.InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (fln.NotificationResponse response) {
        // Handle notification tap
        debugPrint('Notification tapped: ${response.payload}');
        _loadNotifications();
      },
    );
  }

  // Show local notification
  Future<void> _showLocalNotification(String title, String body) async {
    const fln.AndroidNotificationDetails androidDetails =
    fln.AndroidNotificationDetails(
      'n2u_channel',
      'N2U Notifications',
      channelDescription: 'Notifications from N2U app',
      importance: fln.Importance.high,
      priority: fln.Priority.high,
      showWhen: true,
    );

    const fln.DarwinNotificationDetails iosDetails = fln.DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const fln.NotificationDetails notificationDetails = fln.NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
    );
  }

  // Setup OneSignal listeners for real-time notifications
  void _setupOneSignalListeners() {
    OneSignal.Notifications.addClickListener((event) {
      debugPrint('OneSignal notification clicked: ${event.notification.jsonRepresentation()}');
      // Reload notifications when user clicks a push notification
      _loadNotifications();
    });

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugPrint('OneSignal notification received: ${event.notification.jsonRepresentation()}');

      // Show local notification when app is in foreground
      final notification = event.notification;
      _showLocalNotification(
        notification.title ?? 'New Notification',
        notification.body ?? '',
      );

      // Reload notifications when receiving a push while app is open
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final stagingUrl = prefs.getString('staging_url');

      if (token == null || stagingUrl == null) {
        throw Exception('Not logged in');
      }

      final response = await http.get(
        Uri.parse('$stagingUrl/api/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      debugPrint('📦 Notifications Response: $data');

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          notifications = (data['data'] as List)
              .map((json) => NotificationItem.fromJson(json))
              .toList();
        });

        // Save unread count to SharedPreferences for badge
        await _saveUnreadCount();
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unread_notification_count', unreadCount);
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  List<NotificationItem> get filteredNotifications {
    return activeTab == 'all'
        ? notifications
        : notifications.where((n) => !n.isRead).toList();
  }

  Future<void> markAsRead(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final stagingUrl = prefs.getString('staging_url');

      if (token == null || stagingUrl == null) return;

      // Call API to mark as read
      final response = await http.post(
        Uri.parse('https://n2u-pos.testflight4u.com/api/notifications/$id/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint('Mark as read response: ${response.body}');

      setState(() {
        final index = notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          notifications[index].isRead = true;
        }
      });

      await _saveUnreadCount();
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final stagingUrl = prefs.getString('staging_url');

      if (token == null || stagingUrl == null) return;

      // Call API to mark all as read
      final response = await http.post(
        Uri.parse('https://n2u-pos.testflight4u.com/api/notifications/read-all'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint('Mark all as read response: ${response.body}');

      setState(() {
        for (var notification in notifications) {
          notification.isRead = true;
        }
      });

      await _saveUnreadCount();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final stagingUrl = prefs.getString('staging_url');

      if (token == null || stagingUrl == null) return;

      // Call API to delete notification
      await http.delete(
        Uri.parse('https://n2u-pos.testflight4u.com/api/notifications/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      setState(() {
        notifications.removeWhere((n) => n.id == id);
      });

      await _saveUnreadCount();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                offset: Offset(0, 2),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            title: Text(
              'Notification',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w700,
              ),
            ).tr(),
            leading: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Profile()),
                );
              },
              icon: Icon(Icons.chevron_left, color: Colors.grey),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Spacer(),
                        if (unreadCount > 0)
                          TextButton(
                            onPressed: markAllAsRead,
                            child: Text(
                              'Mark all read',
                              style: GoogleFonts.dmSans(
                                color: primaryOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ).tr(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTabButton(
                            'All '.tr(), '(${notifications.length})',
                            'all',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildTabButton(
                            'Unread '.tr(), '($unreadCount)',
                            'unread',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredNotifications.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: filteredNotifications.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  color: Colors.grey,
                ),
                itemBuilder: (context, index) {
                  final notification = filteredNotifications[index];
                  return _NotificationCard(
                    notification: notification,
                    onMarkAsRead: () => markAsRead(notification.id),
                    onDelete: () => deleteNotification(notification.id),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, String count, String tab) {
    final isActive = activeTab == tab;
    return GestureDetector(
      onTap: () => setState(() => activeTab = tab),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? primaryOrange.shade50 : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(

          child: Wrap(

            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  color: isActive ? primaryDark : Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),

              Text(
                count,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  color: isActive ? primaryDark : Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ).tr(),
          const SizedBox(height: 8),
          Text(
            activeTab == 'unread'
                ? "You're all caught up!".tr()
                : "You'll see notifications here when you get them".tr(),
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatefulWidget {
  final NotificationItem notification;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.onMarkAsRead,
    required this.onDelete,
  });

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> {
  bool showActions = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!widget.notification.isRead) {
          widget.onMarkAsRead();
        }
        // Pass notification data to details page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotificationDetails(
              notification: widget.notification,
            ),
          ),
        );
      },
      onLongPress: () => setState(() => showActions = !showActions),
      child: Container(
        color: widget.notification.isRead ? Colors.white : Colors.blue.shade50,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.notification.color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.notification.icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.notification.title,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (!widget.notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: primaryOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.notification.message,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.notification.time,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            if (showActions)
              Column(
                children: [
                  if (!widget.notification.isRead)
                    IconButton(
                      onPressed: widget.onMarkAsRead,
                      icon: const Icon(Icons.check, color: Colors.green),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  const SizedBox(height: 8),
                  IconButton(
                    onPressed: widget.onDelete,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}