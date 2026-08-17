import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:n2u/const/button_style.dart';
import 'package:n2u/voucher/redeem_code.dart';
import 'package:http/http.dart' as http;
import 'package:n2u/const/controller/auth_storage.dart';
import 'package:n2u/const/controller/main_api.dart';

class Active extends StatefulWidget {
  const Active({super.key});

  @override
  State<Active> createState() => ActivePage();
}

class ActivePage extends State<Active> {
  List<dynamic> activeVouchers = [];
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
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> allVouchers = jsonDecode(response.body);

        setState(() {
          activeVouchers = allVouchers.where((voucher) {
            final status = voucher['status'];
            final expiredAt = DateTime.parse(voucher['expired_at']);
            final now = DateTime.now();

            return status == 'active' && expiredAt.isAfter(now);
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
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : activeVouchers.isEmpty
            ? buildEmptyState()
            : SingleChildScrollView(
          child: Column(
            children: activeVouchers.map((voucher) {
              final voucherData = voucher['vouchers'];

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
                redeemDate: voucher['created_at'],
                redeem: true,
                tnc: voucherData['tnc'] ?? '',
                voucherName: voucherData['name'],
                campaignPeriod: voucherData['campaign_period'],
                campaignStart: voucherData['campaign_period_start'] ?? '',
                campaignEnd: voucherData['campaign_period_end'] ?? '',
                serviceType: voucherData['service_type'],
                status: voucher['status'],
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
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;

    return GestureDetector(
      onTap: null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: CouponCard(
          height: 150,
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: ZincButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.8,
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  child: RedeemCode(
                                    title: title,
                                    subtitle: tnc,
                                    valid: validity,
                                    logo: logo,
                                    code: code,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        text: 'Use'.tr(),
                        height: 20,
                        width: isSmallScreen ? 60 : 80,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
            'No Active Vouchers',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ).tr(),
          const SizedBox(height: 8),
          Text(
            "You don't have any active vouchers right now",
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