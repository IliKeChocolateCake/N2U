class Voucher {
  final String code;
  final String name;
  final String status;
  final String image;
  final int pointRequired;
  final String validityText;
  final String tnc;
  final String discountText;

  Voucher({
    required this.code,
    required this.name,
    required this.status,
    required this.image,
    required this.pointRequired,
    required this.validityText,
    required this.tnc,
    required this.discountText,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    final criteria = json['criteria'] ?? {};
    final discount = json['discount'] ?? {};
    final claim = json['claim'] ?? {};

    String validity = criteria['validity_type'] == 'days_after_redemption'
        ? '${criteria['validity_value']} days after redemption'
        : 'Unlimited';

    String discountText = discount['rate_type'] == 'percentage'
        ? '${discount['rate']}% OFF'
        : 'RM ${discount['rate']} OFF';

    return Voucher(
      code: json['voucher_code'],
      name: json['name'],
      status: json['status'],
      image: json['image'] ?? '',
      pointRequired: claim['point'] ?? 0,
      validityText: validity,
      tnc: json['tnc'] ?? '',
      discountText: discountText,
    );
  }
}
