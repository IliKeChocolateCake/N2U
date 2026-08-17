import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WalletDetails extends StatefulWidget {
  final String id;
  final String userID;
  final String transactionNumber;
  final String transactionType;
  final String remark;
  final String amount;
  final bool add;
  final String phoneNumber;
  final String status;
  final String paymentType;
  final String createAt;

  const WalletDetails({
    super.key,
    required this.id,
    required this.userID,
    required this.transactionNumber,
    required this.transactionType,
    required this.remark,
    required this.amount,
    required this.add,
    required this.status,
    required this.paymentType,
    required this.createAt,
    required this.phoneNumber,
  });

  @override
  State<WalletDetails> createState() => WalletDetailsPage();
}

class WalletDetailsPage extends State<WalletDetails> {
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
            automaticallyImplyLeading: false,
            title: Text(
              'Transaction Details',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w700,
              ),
            ).tr(),
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
        ),
      ),
      // Always show the simple transaction UI
      body: _buildTransactionUI(),
    );
  }


  Widget _buildTransactionUI() {
    // Remove 'Z' and split the datetime string
    final cleanedDateTime = widget.createAt.replaceAll('Z', '').replaceAll('T', ' ');
    final dateTimeParts = cleanedDateTime.split(' ');
    final date = dateTimeParts.isNotEmpty ? dateTimeParts[0] : cleanedDateTime;
    final time = dateTimeParts.length > 1 ? _formatTime(dateTimeParts[1]) : '';

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRow('Transaction Type:', _formatTransactionType(widget.transactionType)),
          SizedBox(height: 8),
          _buildRow('Payment Method:', widget.paymentType),
          SizedBox(height: 8),
          _buildRow('Transaction No.:', widget.transactionNumber),
          SizedBox(height: 8),
          _buildRow('Date:', date),
          SizedBox(height: 8),
          if (time.isNotEmpty) _buildRow('Time:', time),
          if (time.isNotEmpty) SizedBox(height: 8),
          if (widget.remark.isNotEmpty)
            _buildRow('Remark:', widget.remark),
          if (widget.remark.isNotEmpty)
            SizedBox(height: 8),
          _buildStatusRow(),
          SizedBox(height: 8),
          Divider(),
          _buildRow('Total:', 'RM ${widget.amount}', isBold: true),
          Divider(),
        ],
      ),
    );
  }

// Helper to format time to 12-hour format with AM/PM
  String _formatTime(String time) {
    try {
      final timeParts = time.split(':');
      if (timeParts.isEmpty) return time;

      int hour = int.parse(timeParts[0]);
      final minute = timeParts.length > 1 ? timeParts[1] : '00';

      final period = hour >= 12 ? 'PM' : 'AM';
      hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

      return '$hour:$minute $period';
    } catch (e) {
      return time; // Return original if parsing fails
    }
  }

// Helper to format transaction type nicely
  String _formatTransactionType(String type) {
    switch (type.toLowerCase()) {
      case 'top_up':
        return 'Top Up';
      case 'adjustment':
        return 'Adjustment';
      case 'withdrawal':
        return 'Withdrawal';
      case 'referral':
        return 'Referral';
      default:
        return type;
    }
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildRow(
      String label,
      String value, {
        bool isBold = false,
        double fontSize = 14,
        Color? valueColor,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ).tr(),
          Spacer(),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
              color: valueColor ?? Colors.black,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    Color statusColor;
    Color bgColor;
    String statusText;

    switch (widget.status.toLowerCase()) {
      case 'pending':
        statusColor = Color(0xFFFF8C00);
        bgColor = Color(0xFFFFF4E6);
        statusText = 'Pending';
        break;
      case 'approved':
      case 'success':
      case 'completed':
        statusColor = Color(0xFF009880);
        bgColor = Color(0xFFD4F5E8);
        statusText = 'Successful';
        break;
      case 'rejected':
      case 'failed':
        statusColor = Colors.red;
        bgColor = Colors.red.shade50;
        statusText = 'Failed';
        break;
      default:
        statusColor = Colors.grey;
        bgColor = Colors.grey.shade100;
        statusText = widget.status;
    }

    return Row(
      children: [
        Text(
          'Status: ',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
        ).tr(),
        Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusText,
            style: GoogleFonts.dmSans(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}