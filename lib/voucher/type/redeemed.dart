import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:n2u/const/controller/main_api.dart';
import 'package:n2u/const/controller/auth_storage.dart';
import 'package:easy_localization/easy_localization.dart';

class Used extends StatefulWidget {
  const Used({super.key});

  @override
  State<Used> createState() => UsedPage();
}

class UsedPage extends State<Used> {
  List<dynamic> usedVouchers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVouchers();
  }

  Future<void> fetchVouchers() async {
    try {
      final token = await AuthStorage.getToken();
      final response = await http.get(
        Uri.parse(stageGetMyVoucher),
        headers: {
          'Authorization': 'Bearer $token', // Replace with actual token
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> allVouchers = jsonDecode(response.body);

        // Filter USED vouchers
        setState(() {
          usedVouchers = allVouchers.where((voucher) {
            return voucher['status'] == 'used' || voucher['used_date'] != null;
          }).toList();

          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching vouchers: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16),
        child: isLoading
            ? Center(child: CircularProgressIndicator()) : usedVouchers.isEmpty ? buildEmptyState()
            : SingleChildScrollView(
          child: Column(
            children: usedVouchers.map((voucher) {
              final voucherData = voucher['vouchers'];

              // Get logo - prefer voucher_image, fallback to media
              String logo = voucherData['voucher_image'] ?? '';
              if (logo.isEmpty && voucherData['media'].isNotEmpty) {
                logo = voucherData['media'][0]['original_url'];
              }

              return _buildVoucherCard(
                id: voucher['id'],
                logo: logo,
                backgroundColor: Colors.white,
                title: voucherData['name'],
                validity: voucher['expired_at'],
                redeemDate: voucher['used_date'] ?? voucher['created_at'], // Show used_date if available
                redeem: true,
                isUsed: true, // Always true for this page
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildVoucherCard({
    required int id,
    required String logo,
    required Color backgroundColor,
    required String title,
    required String validity,
    required String redeemDate,
    required bool redeem,
    required bool isUsed,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;

    return GestureDetector(
      onTap: null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Stack(
          children: [
            Opacity(
              opacity: isUsed ? 0.6 : 1.0,
              child: CouponCard(
                height: 140,
                width: screenWidth * 0.9,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white60
                    : Colors.white,
                curveAxis: Axis.vertical,
                borderRadius: 12,
                shadow: BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
                firstChild: Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(logo),
                  ),
                ),
                secondChild: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: DottedLine(
                        direction: Axis.vertical,
                        lineLength: double.infinity,
                        lineThickness: 1,
                        dashLength: 6,
                        dashColor: Colors.grey.shade400,
                        dashGapLength: 4,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        right: isSmallScreen ? 8 : 12,
                        left: 14,
                        top: 12,
                        bottom: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.dmSans(
                                  fontSize: isSmallScreen ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                children: [

                                  Text(
                                    'Expires on ',
                                    style: GoogleFonts.dmSans(
                                      fontSize: isSmallScreen ? 12 : 13,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white60
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ).tr(),
                                  Text(
                                    validity,
                                    style: GoogleFonts.dmSans(
                                      fontSize: isSmallScreen ? 12 : 13,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white60
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],

                              ),
                              const SizedBox(height: 2),
                              if (redeem)
                                Text(
                                  'Used on ${formatDateTime(redeemDate)}',
                                  style: GoogleFonts.dmSans(
                                    fontSize: isSmallScreen ? 11 : 12,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white60
                                        : Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Used Badge
            if (isUsed)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'USED',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ).tr(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Used Vouchers',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ).tr(),
          const SizedBox(height: 8),
          Text(
            "You don't have any used vouchers right now",
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ).tr(),
        ],
      ),
    );
  }

  String formatDateTime(String timestamp) {
    final dateTime = DateTime.parse(timestamp).toLocal();
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

}