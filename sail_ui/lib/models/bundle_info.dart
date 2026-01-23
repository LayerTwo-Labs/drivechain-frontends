class BundleInfo {
  final int amountSatoshi;
  final int feesSatoshi;
  final int weight;
  final int height;

  BundleInfo({
    required this.amountSatoshi,
    required this.feesSatoshi,
    required this.weight,
    required this.height,
  });

  factory BundleInfo.fromJson(Map<String, dynamic> json) {
    return BundleInfo(
      amountSatoshi: json['amount'],
      feesSatoshi: json['fees'],
      weight: json['weight'],
      height: json['height'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amountSatoshi,
      'fees': feesSatoshi,
      'weight': weight,
      'height': height,
    };
  }
}
