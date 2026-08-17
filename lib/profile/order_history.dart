import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:n2u/profile/profile.dart';
import 'package:n2u/const/controller/main_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';



class OrderHistory extends StatefulWidget{

  const OrderHistory ({super.key});

  @override
  State<OrderHistory> createState() => OrderHistoryPage();


}

class OrderHistoryPage extends State<OrderHistory>{

  List<dynamic> transactions = [];
  bool _isLoading = false;
  bool isOffline = false;
  String? lastUpdateTime;


  @override
  void initState() {
    super.initState();
    fetchTransaction();
  }

  // Load cached order history first for instant display
  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedOrders = prefs.getString('cached_order_history');

      if (cachedOrders != null) {
        final data = jsonDecode(cachedOrders);

        setState(() {
          transactions = data['transactions'] ?? [];
          lastUpdateTime = data['last_update'] ?? '';
        });

        debugPrint('✅ Loaded cached order history from $lastUpdateTime');
      }
    } catch (e) {
      debugPrint('Error loading cached order data: $e');
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

      await prefs.setString('cached_order_history', jsonEncode(cacheData));
      debugPrint('💾 Order history cached at ${now.toIso8601String()}');
    } catch (e) {
      debugPrint('Error caching order data: $e');
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
        Uri.parse(stageOrderHistory),
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

        debugPrint('🌐 Fresh order history loaded successfully');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AwesomeSnackbarContent(
                title: 'Error',
                message: data['message'] ?? 'Failed to load order history',
                contentType: ContentType.failure,
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              behavior: SnackBarBehavior.floating,
            )
        );
      }
    } catch (e) {
      debugPrint('❌ Network error, using cached order data: $e');
      setState(() {
        isOffline = true;
      });

      // Show offline indicator only if we have no cached data
      if (mounted && transactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AwesomeSnackbarContent(
                title: 'Offline',
                message: 'No cached data available',
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
                message: 'Showing cached orders',
                contentType: ContentType.warning,
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
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

  String formatDateTime(String? dateTime) {
    if (dateTime == null) return '';
    try {
      final dt = DateTime.parse(dateTime);
      return DateFormat('dd MMM yyyy HH:mm:ss').format(dt);
    } catch (e) {
      return dateTime;
    }
  }

  String getOrderType(String? orderType) {
    if (orderType == null || orderType.isEmpty) return 'Dine In';
    return orderType;
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
              'Order History',
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
          // Offline banner
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
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchTransaction,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: transactions.map((transaction) {
                    // Extract data from transaction
                    final id = transaction['id']?.toString() ?? '';
                    final shiftId = transaction['shift_id']?.toString() ?? '';
                    final userId = transaction['user_id']?.toString() ?? '';
                    final sessionId = transaction['session_id']?.toString() ?? '';
                    final orderType = transaction['order_type']?.toString() ?? '';
                    final orderNo = transaction['order_no']?.toString() ?? '';
                    final customerId = transaction['customer_id']?.toString() ?? '';
                    final tableId = transaction['table_id']?.toString() ?? '';
                    final tableName = transaction['table_name']?.toString() ?? '';
                    final pax = transaction['pax']?.toString() ?? '';
                    final status = transaction['status']?.toString() ?? '';
                    final paymentStatus = transaction['payment_status']?.toString() ?? '';
                    final subtotal = transaction['subtotal']?.toString() ?? '0.00';
                    final tax = transaction['tax']?.toString() ?? '0.00';
                    final taxRate = transaction['tax_rate']?.toString() ?? '0';
                    final serviceCharge = transaction['service_charge']?.toString() ?? '0.00';
                    final serviceRate = transaction['service_rate']?.toString() ?? '0';
                    final discountType = transaction['discount_type']?.toString() ?? 'N/A';
                    final discountValue = transaction['discount_value']?.toString() ?? '0.00';
                    final discount = transaction['discount']?.toString() ?? '0.00';
                    final rounding = transaction['rounding']?.toString() ?? '0.00';
                    final total = transaction['total']?.toString() ?? '0.00';
                    final remark = transaction['remark']?.toString() ?? '';
                    final voidDateTime = transaction['void_datetime']?.toString() ?? '';
                    final voidBy = transaction['voided_by']?.toString() ?? '';
                    final createAt = transaction['created_at']?.toString() ?? '';
                    final updateAt = transaction['updated_at']?.toString() ?? '';

                    final payment = transaction['payment'];
                    final paymentOrderId = payment?['order_id']?.toString() ?? '';
                    final paymentPoint = payment?['points']?.toString() ?? '0.00';

                    return order(
                      context,
                      id,
                      shiftId,
                      userId,
                      sessionId,
                      orderType,
                      orderNo,
                      customerId,
                      tableId,
                      tableName,
                      pax,
                      status,
                      paymentStatus,
                      subtotal,
                      tax,
                      taxRate,
                      serviceCharge,
                      serviceRate,
                      discountType,
                      discountValue,
                      discount,
                      rounding,
                      total,
                      remark,
                      voidDateTime,
                      voidBy,
                      createAt,
                      updateAt,
                      paymentOrderId,
                      paymentPoint,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget order(
      BuildContext context,
      String id,
      String shiftId,
      String userId,
      String sessionId,
      String orderType,
      String orderNo,
      String customerId,
      String tableId,
      String tableName,
      String pax,
      String status,
      String paymentStatus,
      String subtotal,
      String tax,
      String taxRate,
      String serviceCharge,
      String serviceRate,
      String discountType,
      String discountValue,
      String discount,
      String rounding,
      String total,
      String remark,
      String voidDateTime,
      String voidBy,
      String createAt,
      String updateAt,
      String paymentOrderId,
      String paymentPoint,
      ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header - Black background with transaction number and date
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  orderNo,
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  formatDateTime(createAt),
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Body - Order details
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildRow('Table Number', tableName),
                SizedBox(height: 12),
                _buildRow('Pax', pax),
                SizedBox(height: 12),
                _buildRow('Order Type', getOrderType(orderType)),
                SizedBox(height: 12),
                _buildRowWithBadge('Payment Status'.tr(), paymentStatus),
                SizedBox(height: 12),
                _buildRowWithBadge('Status'.tr(), status),
                SizedBox(height: 12),
                _buildRow('N2U Reward Points Earned', '$paymentPoint pts'),
                SizedBox(height: 12),
                _buildRow('Rounding', 'RM $rounding', isBold: true),
                SizedBox(height: 12),
                _buildRow('Discount Type', discountType, isBold: true),
                SizedBox(height: 12),
                _buildRow('Discount Value', 'RM $discountValue', isBold: true),
                SizedBox(height: 12),
                _buildRow('Subtotal', 'RM $subtotal', isBold: true),
                SizedBox(height: 12),
                _buildRow('${'Tax'.tr()} ($taxRate%)', 'RM $tax', isBold: true),
                SizedBox(height: 12),
                _buildRow('${'Service Tax'.tr()} ($serviceRate%)', 'RM $serviceCharge', isBold: true),
                SizedBox(height: 12),
                _buildRow('Total', 'RM $total', isBold: true),
                SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(

      String label,
      String value,
      {bool isBold = false}

      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ).tr(),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: Colors.black,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRowWithBadge(String label, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Color(0xFFD4F5E8), // Light mint green
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: Color(0xFF009880), // Dark teal
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }


  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Order History',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ).tr(),
          const SizedBox(height: 8),
          Text(
            "You don't have any order history right now",
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