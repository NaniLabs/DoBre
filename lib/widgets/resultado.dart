import 'package:dobre/models/calculation_breakdown.dart';
import 'package:dobre/utils/currency_utils.dart';
import 'package:flutter/material.dart';

class Resultado extends StatefulWidget {
  const Resultado({
    super.key,
    required this.precioML,
    required this.onCopiar,
    this.breakdown,
  });

  final double precioML;
  final VoidCallback onCopiar;
  final CalculationBreakdown? breakdown;

  @override
  State<Resultado> createState() => _ResultadoState();
}

class _ResultadoState extends State<Resultado> {
  bool _copiado = false;

  void _handleCopiar() {
    widget.onCopiar();
    setState(() => _copiado = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _copiado = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasResult = widget.precioML > 0;
    final breakdown = widget.breakdown;

    if (!hasResult) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Precio sugerido",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    "Ingresá el monto que querés recibir en mano y presioná Calcular.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final formattedPrice = CurrencyUtils.format(
      widget.precioML,
      includeDecimals: true,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Precio sugerido de publicación",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: widget.precioML, end: widget.precioML),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero : const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, _) {
              final textPrice = (animatedValue - widget.precioML).abs() < 0.01
                  ? formattedPrice
                  : CurrencyUtils.format(animatedValue, includeDecimals: true);
              return Text(
                textPrice,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                  letterSpacing: -0.8,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: _copiado ? colorScheme.primary : colorScheme.outline,
                width: _copiado ? 1.8 : 1.0,
              ),
              backgroundColor: _copiado
                  ? colorScheme.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
            ),
            onPressed: _handleCopiar,
            icon: Icon(
              _copiado ? Icons.check_rounded : Icons.content_copy_rounded,
              color: _copiado ? colorScheme.primary : null,
            ),
            label: Text(
              _copiado ? "¡Precio copiado!" : "Copiar precio",
              style: TextStyle(
                fontWeight: _copiado ? FontWeight.w800 : FontWeight.w600,
                color: _copiado ? colorScheme.primary : null,
              ),
            ),
          ),
        ),
        if (breakdown != null) ...[
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            "Desglose estimado de la venta",
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          _ProportionalBreakdownBar(
            total: widget.precioML,
            net: breakdown.actualReceived,
            commission: breakdown.commissionAmount,
            installment: breakdown.installmentAmount,
            otherCosts: breakdown.shippingAmount +
                breakdown.fixedChargeAmount +
                breakdown.unitCostAmount,
          ),
          const SizedBox(height: 12),
          _BreakdownRow(
            label:
                "Comisión publicación (${breakdown.commissionPercentage.toStringAsFixed(1)}%)",
            value: "-${CurrencyUtils.format(breakdown.commissionAmount)}",
            isNegative: true,
          ),
          if (breakdown.hasInstallmentCost)
            _BreakdownRow(
              label:
                  "Costo financiación (${breakdown.installmentPercentage.toStringAsFixed(1)}%)",
              value: "-${CurrencyUtils.format(breakdown.installmentAmount)}",
              isNegative: true,
            ),
          if (breakdown.hasShippingCost)
            _BreakdownRow(
              label: "Costo de envío",
              value: "-${CurrencyUtils.format(breakdown.shippingAmount)}",
              isNegative: true,
            ),
          if (breakdown.hasFixedCharge)
            _BreakdownRow(
              label: "Cargo fijo",
              value: "-${CurrencyUtils.format(breakdown.fixedChargeAmount)}",
              isNegative: true,
            ),
          if (breakdown.hasUnitCost)
            _BreakdownRow(
              label: "Costo unitario (< umbral)",
              value: "-${CurrencyUtils.format(breakdown.unitCostAmount)}",
              isNegative: true,
            ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Dinero neto recibido",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
                Text(
                  CurrencyUtils.format(breakdown.actualReceived),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ProportionalBreakdownBar extends StatelessWidget {
  const _ProportionalBreakdownBar({
    required this.total,
    required this.net,
    required this.commission,
    required this.installment,
    required this.otherCosts,
  });

  final double total;
  final double net;
  final double commission;
  final double installment;
  final double otherCosts;

  @override
  Widget build(BuildContext context) {
    if (total <= 0) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    final values = [net, commission, installment, otherCosts]
        .map((value) => value.clamp(0.0, double.infinity))
        .toList();
    final sum = values.fold<double>(0, (a, b) => a + b);
    if (sum <= 0) return const SizedBox.shrink();
    final colors = [colorScheme.primary, const Color(0xFFF59E0B),
      const Color(0xFFE11D48), colorScheme.outline];
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero : const Duration(milliseconds: 350);

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LayoutBuilder(builder: (context, constraints) {
        return Row(children: [
          for (var i = 0; i < values.length; i++)
            AnimatedContainer(
              duration: duration,
              curve: Curves.easeOutCubic,
              width: constraints.maxWidth * values[i] / sum,
              height: 8,
              color: colors[i],
            ),
        ]);
      }),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.value,
    this.isNegative = false,
  });

  final String label;
  final String value;
  final bool isNegative;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: isNegative ? colorScheme.error : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
