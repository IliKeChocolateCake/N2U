import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:n2u/profile/withdraw.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n2u/const/button_style.dart';
import 'package:n2u/const/constant.dart';
import 'package:n2u/const/controller/main_api.dart';

class RequestWithdraw extends StatefulWidget {
  final String withdraw;

  const RequestWithdraw({
    super.key,
    required this.withdraw,
  });

  @override
  State<RequestWithdraw> createState() => _RequestWithdrawState();
}

class _RequestWithdrawState extends State<RequestWithdraw> {
  bool _isLoading = false;

  Future<void> _submitWithdrawRequest() async {
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

      final response = await http.post(
        Uri.parse(requestWithdrawal),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'withdraw_amount': double.parse(widget.withdraw),
        }),
      );

      final data = jsonDecode(response.body);
      debugPrint('📦 withdraw Response: $data');

      if (response.statusCode == 200 && data['success'] == true) {
        if (!mounted) return;

        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Center(
              child: Text('Request Submitted', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold), textAlign: TextAlign.center,).tr(),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Center(
                  child:AnimatedCheckmark() ,
                ),

                const SizedBox(height: 24),
                Wrap(
                  children: [
                    Text(
                      'Your withdraw request of RM ',
                      style: GoogleFonts.dmSans(),
                    ).tr(),
                    Text(
                      widget.withdraw,
                      style: GoogleFonts.dmSans(),
                    ),
                    Text(
                      'has been submitted successfully.',
                      style: GoogleFonts.dmSans(),
                    ).tr(),
                  ],
                ),

                const SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF4E6), // Soft yellow/peach background
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Status: Pending',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: Color(0xFFFF8C00), // Orange text
                      fontWeight: FontWeight.w600,
                    ),
                  ).tr(),
                ),
                const SizedBox(height: 8),
                Wrap(
                  children: [
                    Text(
                      'Request Date: ',
                      style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      _formatDate(data['transaction']['request_date']),
                      style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),


              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Withdraw()),
                  );
                },
                child: Text('OK', style: GoogleFonts.dmSans()).tr(),
              ),
            ],
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AwesomeSnackbarContent(
              title: 'Uh Oh!',
              message:
              data['message'] ?? 'Failed to submit withdraw request',
              contentType: ContentType.failure,
            ),
            backgroundColor: Colors.transparent,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error submitting withdraw: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(preferredSize: Size.fromHeight(kToolbarHeight),
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
          title:   Text('Confirm Withdraw', style: GoogleFonts.dmSans(fontSize: 18,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w700,
          ),).tr(),
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Withdraw()),
              );
            },
            icon: Icon(Icons.chevron_left, color: Colors.grey,),
          ),
        ),
      )),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Text(
                    'Withdraw Amount',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ).tr(),
                  const SizedBox(height: 8),
                  Text(
                    'RM ${widget.withdraw}',
                    style: GoogleFonts.dmSans(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: primaryDark,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: primaryOrange, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Important Information',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600,
                          color: primaryOrange,
                        ),
                      ).tr(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• Your withdraw request will be pending until approved',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ).tr(),
                      const SizedBox(height: 4),
                      Text(
                        '• Funds will be deducted from your cash wallet',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ).tr(),
                      const SizedBox(height: 4),
                      Text(
                        '• You will be notified once approved',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ).tr(),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            ZincButton(
              onPressed:  _submitWithdrawRequest,
              text: _isLoading ? 'Submitting...'.tr() : 'Submit Request'.tr(),
              height: 52,
              width: MediaQuery.of(context).size.width * 0.9,
            ),
          ],
        ),
      ),
    );
  }
}


// Flutter version - Add this to your success dialog/screen

class AnimatedCheckmark extends StatefulWidget {
  const AnimatedCheckmark({super.key});

  @override
  State<AnimatedCheckmark> createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<AnimatedCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: CheckmarkPainter(_controller.value),
          );
        },
      ),
    );
  }
}

class CheckmarkPainter extends CustomPainter {
  final double progress;

  CheckmarkPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw circle
    final circleProgress = (progress * 1.5).clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57, // Start at top
      6.28 * circleProgress, // Full circle
      false,
      paint,
    );

    // Draw checkmark
    if (progress > 0.5) {
      final checkProgress = ((progress - 0.5) * 2).clamp(0.0, 1.0);

      final path = Path();
      path.moveTo(size.width * 0.3, size.height * 0.5);
      path.lineTo(size.width * 0.45, size.height * 0.65);
      path.lineTo(size.width * 0.7, size.height * 0.35);

      final metric = path.computeMetrics().first;
      final extracted = metric.extractPath(0, metric.length * checkProgress);

      canvas.drawPath(extracted, paint);
    }
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) =>
      oldDelegate.progress != progress;
}