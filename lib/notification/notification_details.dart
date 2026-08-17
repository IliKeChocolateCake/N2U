import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:n2u/notification/notification.dart';

class NotificationDetails extends StatefulWidget {
  final NotificationItem notification;

  const NotificationDetails({
    super.key,
    required this.notification,
  });

  @override
  State<NotificationDetails> createState() => NotificationDetailsPage();
}

class NotificationDetailsPage extends State<NotificationDetails> {
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
              'Notification Details',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w700,
              ),
            ),
            leading: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Noti()),
                );
              },
              icon: Icon(Icons.chevron_left, color: Colors.grey),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Images - use placeholder if no image
            CachedNetworkImage(
              imageUrl: widget.notification.imageUrl!,
              fit: BoxFit.fill,
              placeholder: (context, url) => Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) {
                debugPrint('❌ CachedImage Error: $error');
                return Container(
                  height: 200,
                  color: widget.notification.color.withValues(alpha: 0.2),
                  child: Center(
                    child: Icon(
                      widget.notification.icon,
                      size: 80,
                      color: widget.notification.color,
                    ),
                  ),
                );
              },
            ),

            // Timestamps, title, description
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.grey),
                      SizedBox(width: 10),
                      Text(
                        widget.notification.time,
                        style: GoogleFonts.dmSans(color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Title
                  Text(
                    widget.notification.title,
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  SizedBox(height: 8),
                  _buildRowWithBadge(widget.notification.type),
                  SizedBox(height: 24),

                  // Message
                  Text(
                    widget.notification.message,
                    style: GoogleFonts.dmSans(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowWithBadge(String category) {
    // Get color based on notification type
    Color backgroundColor;
    Color textColor;

    switch (category.toLowerCase()) {
      case 'order':
        backgroundColor = Color(0xFFDBEAFE);
        textColor = Color(0xFF1D4ED8);
        break;
      case 'payment':
        backgroundColor = Color(0xFFD1FAE5);
        textColor = Color(0xFF059669);
        break;
      case 'voucher':
        backgroundColor = Color(0xFFF3E8FF);
        textColor = Color(0xFF9333EA);
        break;
      case 'promotion':
      case 'promo':
        backgroundColor = Color(0xFFFFEDD5);
        textColor = Color(0xFFF97316);
        break;
      case 'subscription':
        backgroundColor = Color(0xFFFEF3C7);
        textColor = Color(0xFFD97706);
        break;
      case 'referral':
        backgroundColor = Color(0xFFCCFBF1);
        textColor = Color(0xFF0D9488);
        break;
      case 'message':
        backgroundColor = Color(0xFFE0E7FF);
        textColor = Color(0xFF4F46E5);
        break;
      default:
        backgroundColor = Color(0xFFF3F4F6);
        textColor = Color(0xFF6B7280);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            category.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}