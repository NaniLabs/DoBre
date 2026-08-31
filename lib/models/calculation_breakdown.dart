class CalculationBreakdown {
  const CalculationBreakdown({
    required this.publishedPrice,
    required this.targetNetAmount,
    required this.actualReceived,
    required this.commissionRate,
    required this.commissionAmount,
    required this.installmentRate,
    required this.installmentAmount,
    required this.shippingAmount,
    required this.fixedChargeAmount,
    required this.unitCostAmount,
  });

  final double publishedPrice;
  final double targetNetAmount;
  final double actualReceived;
  final double commissionRate;
  final double commissionAmount;
  final double installmentRate;
  final double installmentAmount;
  final double shippingAmount;
  final double fixedChargeAmount;
  final double unitCostAmount;

  double get totalDeductions =>
      commissionAmount +
      installmentAmount +
      shippingAmount +
      fixedChargeAmount +
      unitCostAmount;

  double get commissionPercentage => commissionRate * 100;
  double get installmentPercentage => installmentRate * 100;

  bool get hasShippingCost => shippingAmount > 0;
  bool get hasFixedCharge => fixedChargeAmount > 0;
  bool get hasUnitCost => unitCostAmount > 0;
  bool get hasInstallmentCost => installmentAmount > 0;
}
