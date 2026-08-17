import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:n2u/const/controller/auth_storage.dart';
import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:n2u/const/controller/main_api.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

class Expired extends StatefulWidget {
  const Expired({super.key});

  @override
  State<Expired> createState() => ExpiredPage();
}

class ExpiredPage extends State<Expired> {
  List<dynamic> expiredVouchers = [];
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

        // Filter EXPIRED vouchers
        setState(() {
          expiredVouchers = allVouchers.where((voucher) {
            final expiredAt = DateTime.parse(voucher['expired_at']);
            final now = DateTime.now();

            // Expired means: expiry date has passed
            return expiredAt.isBefore(now);
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
            ? Center(child: CircularProgressIndicator()) : expiredVouchers.isEmpty ? buildEmptyState()
            : SingleChildScrollView(
          child: Column(
            children: expiredVouchers.map((voucher) {
              final voucherData = voucher['vouchers'];

              // Get logo - prefer voucher_image, fallback to media
              String logo = voucherData['voucher_image'] ?? '';
              if (logo.isEmpty && voucherData['media'].isNotEmpty) {
                logo = voucherData['media'][0]['original_url'];
              }

              return _buildVoucherCard(
                id: voucher['id'],
                userId: voucher['user_id'].toString(),
                voucherId: voucher['voucher_id'].toString(),
                code: voucher['code'],
                logo: logo,
                backgroundColor: Colors.white,
                title: voucherData['name'],
                validity: voucher['expired_at'],
                redeemDate: voucher['used_date'] ?? voucher['created_at'],
                redeem: true,
                tnc: voucherData['tnc'] ?? '',
                voucherName: voucherData['name'],
                campaignPeriod: voucherData['campaign_period'],
                campaignStart: voucherData['campaign_period_start'] ?? '',
                campaignEnd: voucherData['campaign_period_end'] ?? '',
                serviceType: voucherData['service_type'],
                status: voucher['status'],
                isExpired: true, // Always true for this page
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildVoucherCard({
    required int id,
    required String userId,
    required String voucherId,
    required String code,
    required String logo,
    required Color backgroundColor,
    required String title,
    required String validity,
    required String redeemDate,
    required bool redeem,
    required String tnc,
    required String voucherName,
    required String campaignPeriod,
    required String campaignStart,
    required String campaignEnd,
    required String serviceType,
    required String status,
    required bool isExpired, // Add this parameter
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
              opacity: isExpired ? 0.6 : 1.0,
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
                                  formatDateTime(redeemDate),
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
            // Expired Badge
            if (isExpired)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
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
                    'EXPIRED',
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
            'No Expired Vouchers',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ).tr(),
          const SizedBox(height: 8),
          Text(
            "You don't have any expired vouchers right now",
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