import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:n2u/profile/profile.dart';
import 'package:n2u/wallet/wallet_details.dart';
import 'package:n2u/const/controller/main_api.dart';


class WalletTransaction extends StatefulWidget{

  const WalletTransaction ({super.key});


  @override
  State<WalletTransaction> createState() => WalletTransactionPage();


}


class WalletTransactionPage extends State<WalletTransaction>{

  List<dynamic> transactions = [];
  bool _isLoading = false;
  bool isOffline = false;
  String? lastUpdateTime;


  @override
  void initState() {
    super.initState();
    fetchTransaction();
  }

  // Load cached transactions first for instant display
  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedTransactions = prefs.getString('cached_wallet_transactions');

      if (cachedTransactions != null) {
        final data = jsonDecode(cachedTransactions);

        setState(() {
          transactions = data['transactions'] ?? [];
          lastUpdateTime = data['last_update'] ?? '';
        });

        debugPrint('✅ Loaded cached wallet transactions from $lastUpdateTime');
      }
    } catch (e) {
      debugPrint('Error loading cached wallet data: $e');
    }
  }

  // Save fresh data to cache
  Future<void> _cacheData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      final cacheData = {
        'transactions': transactions,
        'last_update': now.toIso8601String(),
      };

      await prefs.setString('cached_wallet_transactions', jsonEncode(cacheData));
      debugPrint('💾 Wallet transactions cached at ${now.toIso8601String()}');
    } catch (e) {
      debugPrint('Error caching wallet data: $e');
    }
  }

  Future<void> fetchTransaction() async {
    // Step 1: Load cached data first (instant)
    await _loadCachedData();

    setState(() {
      _isLoading = true;
    });

    // Step 2: Try to fetch fresh data
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final stagingUrl = prefs.getString('staging_url');

      if (token == null || stagingUrl == null) {
        throw Exception('Not logged in');
      }

      final response = await http.get(
        Uri.parse(stageWalletTransaction),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));

      final data = jsonDecode(response.body);
      debugPrint('📦 Transaction Response: $data');

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          transactions = data['data'] ?? [];
          isOffline = false;
          lastUpdateTime = DateTime.now().toIso8601String();
        });

        // Save fresh data to cache
        await _cacheData();

        debugPrint('🌐 Fresh wallet data loaded successfully');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AwesomeSnackbarContent(
                title: 'Error',
                message: data['message'] ?? 'Failed to load transactions',
                contentType: ContentType.failure,
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              behavior: SnackBarBehavior.floating,
            )
        );
      }
    } catch (e) {
      debugPrint('❌ Network error, using cached wallet data: $e');
      setState(() {
        isOffline = true;
      });

      // Show offline indicator only if we have no cached data
      if (mounted && transactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AwesomeSnackbarContent(
                title: 'Offline',
                message: 'No cached data available'.tr(),
                contentType: ContentType.warning,
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            )
        );
      } else if (mounted && lastUpdateTime != null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AwesomeSnackbarContent(
                title: 'Offline',
                message: 'Showing cached transactions'.tr(),
                contentType: ContentType.warning,
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            )
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Format time helper
  String _formatTime(String isoTime) {
    try {
      final time = DateTime.parse(isoTime);
      final now = DateTime.now();
      final diff = now.difference(time);

      if (diff.inMinutes < 1) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (e) {
      return 'recently';
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
              'Wallet Transactions',
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
            actions: [
              // Offline indicator
              if (isOffline)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Icon(
                    Icons.cloud_off,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
              // Refresh button
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  onPressed: _isLoading ? null : fetchTransaction,
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: _isLoading && transactions.isEmpty
          ? Center(child: CircularProgressIndicator())
          : transactions.isEmpty
          ? buildEmptyState()
          : Column(
        children: [
          // Offline banner with last update statements
          if (isOffline && lastUpdateTime != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orange.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Offline mode - Last updated ${_formatTime(lastUpdateTime!)}',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.orange[800],
                      ),
                    ).tr(),
                  ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchTransaction,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: transactions.map((transaction) {
                      return _title(
                        context,
                        transaction['id']?.toString() ?? '',
                        transaction['user_id']?.toString() ?? '',
                        transaction['transaction_number'] ?? '',
                        transaction['transaction_type'] ?? 'Transaction',
                        transaction['remark'] ?? '',
                        transaction['amount'] ?? '0.00',
                        transaction['transaction_type'] == 'top_up',
                        transaction['receipt_no'] ?? '',
                        transaction['receipt_start'] ?? '',
                        transaction['receipt_end'] ?? '',
                        transaction['receipt_total'] ?? '',
                        transaction['receipt_grand_total'] ?? '0.00',
                        transaction['rounding'] ?? '',
                        transaction['discount_type'] ?? '',
                        transaction['discount_amount'] ?? '0',
                        transaction['discount_receipt_amount'] ?? '',
                        transaction['discount_id']?.toString() ?? '',
                        transaction['discount_item'] ?? '',
                        transaction['tip_type'] ?? '',
                        transaction['tip_amount'] ?? '',
                        transaction['tip_receipt_amount'] ?? '',
                        transaction['change'] ?? '0.00',
                        transaction['table_id']?.toString() ?? '',
                        transaction['pax_no']?.toString() ?? '',
                        transaction['trans_by'] ?? '',
                        transaction['cust_name'] ?? '',
                        transaction['phone_no'] ?? '',
                        transaction['reward_point']?.toString() ?? '0',
                        transaction['handle_by'] ?? '',
                        transaction['status'] ?? 'pending',
                        transaction['payment_type'] ?? '',
                        transaction['created_at'] ?? '',
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wallet,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Wallet Transactions',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ).tr(),
          const SizedBox(height: 8),
          Text(
            "You don't have any wallet transaction right now",
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
}

Widget _title(BuildContext context,
    String id,
    String userID,
    String transactionNumber,
    String transactionType,
    String remark,
    String amount,
    bool add,
    String receiptNo,
    String receiptStart,
    String receiptEnd,
    String receiptTotal,
    String receiptGrandTotal,
    String rounding,
    String discountType,
    String discountAmount,
    String discountReceiptAmount,
    String discountID,
    String discountItem,
    String tipType,
    String tipAmount,
    String tipReceiptAmount,
    String change,
    String tableID,
    String paxNo,
    String transBy,
    String customerName,
    String phoneNumber,
    String rewardPoint,
    String handleBy,
    String status,
    String paymentType,
    String createdAt

    ) {
  return ListTile(
    title: Text(
      transactionType.toDisplayFormat(),
      style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 16),
    ),
    subtitle: Text(
      remark,
      style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey),
    ),
    trailing: Text(
      add ? '+ RM $amount' : '- RM $amount',
      style: GoogleFonts.dmSans(
        fontWeight: FontWeight.w500,
        fontSize: 18,
        color: add ? Colors.green : Colors.red,
      ),
    ),
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
              child: WalletDetails(
                transactionType: transactionType,
                amount: amount,
                remark: remark,
                add: add,
                phoneNumber: phoneNumber,
                id: id,
                transactionNumber: transactionNumber,
                userID: userID,
                status: status,
                paymentType: paymentType,
                createAt: createdAt,
              ),
            ),
          ),
        ),
      );
    },
  );
}

extension StringExtension on String {
  String toDisplayFormat() {
    return split('_')
        .map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }
}