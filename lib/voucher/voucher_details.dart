import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:n2u/const/constant.dart';
import 'package:n2u/const/controller/auth_storage.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:n2u/const/controller/main_api.dart';
import 'package:easy_localization/easy_localization.dart';

const String stagePointBalance =
    "https://n2u-pos.testflight4u.com/api/getPointBalance";

class VoucherDetails extends StatefulWidget {
  final String image;
  final String title;
  final int voucherPoints;
  final String valid;
  final String subtitle;
  final String tnc;
  final String voucherCode;

  const VoucherDetails({
    super.key,
    required this.image,
    required this.title,
    required this.voucherPoints,
    required this.valid,
    required this.subtitle,
    required this.tnc,
    required this.voucherCode
  });

  @override
  State<VoucherDetails> createState() => _VoucherDetailsState();
}

class _VoucherDetailsState extends State<VoucherDetails> {
  int totalPoints = 0;
  bool isLoading = true;
  bool isRedeeming = false;

  bool get canRedeem => totalPoints >= widget.voucherPoints;

  @override
  void initState() {
    super.initState();
    _loadPointBalance();
  }

  Future<void> _loadPointBalance() async {
    try {
      final token = await AuthStorage.getToken();

      final resp = await http.get(
        Uri.parse(stagePointBalance),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(resp.body);

      totalPoints =
          int.tryParse(data['balance']?.toString() ?? '0') ?? 0;
    } catch (e) {
      debugPrint('Point balance error: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _onRedeemPressed(BuildContext context) async {
    if (isRedeeming) return;

    setState(() => isRedeeming = true);

    try {
      final token = await AuthStorage.getToken();

      final resp = await http.post(
        Uri.parse(stageRedeemVoucher),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'voucher_id': widget.voucherCode,  // 👈 Using the voucherCode passed in
        }),
      );

      final data = jsonDecode(resp.body);

      setState(() => isRedeeming = false);

      if (!mounted) return;

      // Close the bottom sheet first
      Navigator.of(context).pop();

      // Check if redemption was successful
      if (resp.statusCode == 200 && data['success'] == true) {
        // Success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Voucher Redeemed', style: GoogleFonts.dmSans()).tr(),
            content: Text(
              'Check the My Voucher section for the voucher that has been redeemed.',
              style: GoogleFonts.dmSans(),
            ).tr(),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                  Navigator.of(context).pop(); // go back to previous screen
                },
                child: Text('Close', style: GoogleFonts.dmSans()).tr(),
              ),
            ],
          ),
        );

        // Reload point balance after successful redemption
        _loadPointBalance();
      } else {
        // Error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Redemption Failed', style: GoogleFonts.dmSans()).tr(),
            content: Text(
              data['message'] ?? 'Unable to redeem voucher. Please try again.',
              style: GoogleFonts.dmSans(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close', style: GoogleFonts.dmSans()).tr(),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Redeem error: $e');
      setState(() => isRedeeming = false);

      if (!mounted) return;

      // Close bottom sheet if still open
      Navigator.of(context).pop();

      // Error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error', style: GoogleFonts.dmSans()),
          content: Text(
            'Something went wrong. Please try again later.',
            style: GoogleFonts.dmSans(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: GoogleFonts.dmSans()),
            ),
          ],
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Voucher Details',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ).tr(),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.image,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// Title
            Text(
              widget.title,
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            /// Points
            Row(
              children: [
                const Icon(Icons.stars_rounded,
                    size: 20, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  '${widget.voucherPoints} points',
                  style: GoogleFonts.dmSans(fontSize: 16),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// Validity
            Row(
              children: [
                const Icon(Icons.schedule,
                    size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  widget.valid,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// Subtitle
            Text(
              widget.subtitle,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(height: 16),

            /// T&C HTML
            Html(data: widget.tnc),

            const SizedBox(height: 24),

            Divider(color: Colors.grey.shade300),

            const SizedBox(height: 12),

            /// User points
            Wrap(

              children: [

                Text(
                  'Your points: ',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                  ),
                ).tr(),

                Text(
                  '$totalPoints',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                  ),
                ).tr(),
              ],

            ),

            const SizedBox(height: 80), // 👈 space for bottom button
          ],
        ),
      ),

      /// Bottom Redeem Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: OutlinedButton(
          onPressed: canRedeem && !isRedeeming
              ? () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(12)),
              ),
              builder: (context) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Get this Voucher',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ).tr(),
                    Wrap(

                      children: [

                        Text('Redeem with ', style: GoogleFonts.dmSans(),).tr(),
                        Text('${widget.voucherPoints}', style: GoogleFonts.dmSans(),).tr(),
                        Text(' points?', style: GoogleFonts.dmSans(),).tr(),
                      ],
                    ),
                    const SizedBox(height: 16),

                    /// Redeem button inside modal
                    OutlinedButton(
                      onPressed: canRedeem && !isRedeeming
                          ? () => _onRedeemPressed(context)
                          : null,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor:
                        canRedeem ? primaryDark : Colors.grey,
                        side: BorderSide(
                            color: canRedeem ? primaryDark : Colors.grey,
                            width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      child: isRedeeming
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          :  Text(
                        'Redeem',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ).tr(),
                    ),

                    const SizedBox(height: 5),

                    /// Cancel button
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        side:  BorderSide(
                            color: primaryDark , width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:  Text(
                        'Cancel',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ).tr(),
                    ),
                  ],
                ),
              ),
            );
          }
              : null,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: canRedeem ? primaryDark : Colors.grey,
            side: BorderSide(
                color: canRedeem ? primaryDark : Colors.grey, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Redeem',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ).tr(),
        ),
      ),
    );
  }
}
