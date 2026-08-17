import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:n2u/const/button_style.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class RedeemCode extends StatefulWidget {
  final String logo;
  final String title;
  final String subtitle;
  final String valid;
  final String code;

  const RedeemCode({
    super.key,
    required this.title,
    required this.subtitle,
    required this.valid,
    required this.logo,
    required this.code,
  });

  @override
  State<RedeemCode> createState() => RedeemCodePage();
}

class RedeemCodePage extends State<RedeemCode> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close, color: Colors.black, size: 24),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(widget.logo),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.title,
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      children: [

                        Text(
                          'Expires on ',
                          style: GoogleFonts.dmSans(
                            fontSize:13,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white60
                                : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ).tr(),
                        Text(
                          widget.valid,
                          style: GoogleFonts.dmSans(
                            fontSize:13,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white60
                                : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],

                    ),
                    const SizedBox(height: 24),
                    Html(data: widget.subtitle),
                  ],
                ),
              ),
            ),
          ),
          // Bottom section - always visible
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(
                  thickness: 1,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                DottedBorder(
                  options: RoundedRectDottedBorderOptions(
                    radius: Radius.circular(50),
                    borderPadding: EdgeInsets.all(16),
                    padding: EdgeInsets.all(20),
                    strokeWidth: 1,
                    color: Colors.grey.shade400,
                    dashPattern: [6, 4],
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 52,
                    child: Center(
                      child: Text(
                        widget.code,
                        style: GoogleFonts.dmSans(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ZincButtonTwo(
                  onPressed: () async {
                    // Copy to clipboard
                    await Clipboard.setData(ClipboardData(text: widget.code));

                    // Show confirmation snackbar
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(

                          content: AwesomeSnackbarContent(
                            title: 'Redeemed.'.tr(),
                            message:
                            'Voucher code copied!'.tr(),

                            contentType: ContentType.success,
                          ),

                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.transparent,
                        ),
                      );
                    }
                  },
                  text: 'Copy Voucher Code'.tr(),
                  height: 52,
                  width: double.infinity,
                ),
                const SizedBox(height: 12),
                Text(
                  'Copy and paste this voucher code at order confirmation page to enjoy the deals!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ).tr(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}