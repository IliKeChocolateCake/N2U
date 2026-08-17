import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:n2u/const/button_style.dart';
import 'package:n2u/const/constant.dart';
import 'package:n2u/voucher/voucher_details.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n2u/const/controller/main_api.dart';



class N2uVoucher extends StatefulWidget {
  const N2uVoucher({super.key});

  @override
  State<N2uVoucher> createState() => N2UVoucherPage();
}

class N2UVoucherPage extends State<N2uVoucher> {
  List<dynamic> vouchers = [];
  bool _isLoading = true;
  final TextEditingController _voucherCodeController = TextEditingController();
  bool isLoading = false;



  @override
  void dispose() {
    _voucherCodeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchVouchers();

  }

  // Updated function - takes voucher code as parameter
  Future<void> claimVoucher(String voucherCode) async {
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
        Uri.parse(stageClaimVoucher),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'voucher_code': voucherCode,
        }),
      );

      final data = jsonDecode(response.body);
      debugPrint('📦 Claim Response: $data');

      if (response.statusCode == 200 && data['success'] == true) {
        if (!mounted) return;

        // Clear the text field 👇
        _voucherCodeController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voucher claimed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh vouchers if needed
        // await loadMyVouchers();

      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to claim voucher'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error claiming voucher: $e');
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
  // ========================================
  // Fetch Vouchers from API
  // ========================================
  Future<void> _fetchVouchers() async {
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
        Uri.parse(getVoucher),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      debugPrint('📦 Vouchers Response: $data');

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          vouchers = data['voucher'] ?? [];
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to load vouchers'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error fetching vouchers: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error loading vouchers'),
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

  // ========================================
  // Helper: Format discount text
  // ========================================
  String getDiscountText(dynamic voucher) {
    final discount = voucher['discount'];
    final rateType = discount['rate_type'];
    final rate = discount['rate'];

    if (rateType == 'percentage') {
      return 'Discount $rate%';
    } else {
      return 'RM $rate Off';
    }
  }

  String getTitleName (dynamic voucher){

    final name = voucher['name']??'';

    return name;
  }

  // ========================================
  // Helper: Format validity text
  // ========================================
  String _getValidityText(dynamic voucher) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    String formatDate(String date) {
      final d = DateTime.parse(date);
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    }

    final campaignPeriod = voucher['campaign_period'];

    /// Case 1: Limited period (start + end date)
    if (campaignPeriod == 'limited' &&
        voucher['start_at'] != null &&
        voucher['end_at'] != null) {
      final start = formatDate(voucher['start_at']);
      final end = formatDate(voucher['end_at']);
      return '$start – $end';
    }
    
    return 'No expiry';
  }

  String getCriteria(dynamic voucher) {
    final criteria = voucher?['criteria'];
    if (criteria == null) return 'No expiry';

    final validityValue =
        int.tryParse(criteria['validity_value']?.toString() ?? '') ?? 0;
    final validityType = criteria['validity_type']?.toString();

    if (validityValue > 0 && validityType == 'day') {
      return '$validityValue days after claim';
    }

    return 'No expiry';
  }


  // ========================================
  // Helper: Get points text
  // ========================================
  int getVoucherPoints(dynamic voucher) {
    final claim = voucher['claim'];
    final method = claim?['method'];

    if (method == 'Point to claim') {
      return int.tryParse(claim?['point']?.toString() ?? '0') ?? 0;
    }

    return 0;
  }


  // ========================================
  // Helper: Get image URL
  // ========================================
  String _getImageUrl(dynamic voucher) {
    final image = voucher['image'] ?? '';

    // If no image, return placeholder
    if (image.isEmpty) {
      return 'https://ik.imagekit.io/mnwxsrjlz/ws_app/placeholder?updatedAt=1749434631243https://ik.imagekit.io/mnwxsrjlz/ws_app/placeholder?updatedAt=1749434631243';
    }

    return image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(color: primaryOrange),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add your voucher',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: primaryDark,
                      ),
                    ).tr(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _voucherCodeController,  // 👈 Add this
                            decoration: InputDecoration(
                              hintText: 'E.g. N2U1234',
                              hintStyle: GoogleFonts.dmSans(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        NeoButton(
                          onPressed: _isLoading ? null : () {  // 👈 Disable when loading
                            final code = _voucherCodeController.text.trim();

                            if (code.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(
                                  content: Text('Please enter a voucher code').tr(),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            // Call the claim function
                            claimVoucher(code);
                          },
                          text: _isLoading ? 'Claiming...'.tr() : 'Claim'.tr(),  // 👈 Show loading state
                          height: 52,
                          width: MediaQuery.of(context).size.width * 0.3,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Display vouchers from API
              ...vouchers.map((voucher) {
                return Column(
                  children: [
                    buildVoucher(
                      _getImageUrl(voucher),
                     getVoucherPoints(voucher),
                      _getValidityText(voucher),
                      voucher['name'] ?? '',
                      voucher['tnc']??'',
                      getCriteria(voucher),
                      voucher['voucher_code']

                    ),
                    SizedBox(height: 16),
                  ],
                );
              }

              ),

              // Show message if no vouchers
              if (vouchers.isEmpty)
                buildEmptyState()
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
          SizedBox(height: 24,),
          Icon(
            Icons.wallet_giftcard,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Vouchers Available',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ).tr(),
          const SizedBox(height: 8),
          Text(
            "You don't have any vouchers right now",
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

  Widget buildVoucher(String imageUrl, int points, String validity,
      String title, String description, String criteria, String voucherCode) {
    return GestureDetector(
      onTap: () {
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
                child: VoucherDetails(

                  image: imageUrl,
                  title: title,
                  voucherPoints: points,
                  tnc: description,
                  valid: validity,
                 subtitle: criteria,
                  voucherCode: voucherCode,

                ),
              ),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) {
                  debugPrint('❌ CachedImage Error: $error');
                  return Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: Center(
                      child: Icon(Icons.broken_image,
                          size: 40, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Redeem With',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ).tr(),
                      SizedBox(height: 4),
                      Text(
                        points == '0' ? 'Purchase' : '$points pts',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Valid Until',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ).tr(),
                      SizedBox(height: 4),
                      Text(
                        validity,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
    );
  }
}