import 'package:flutter/material.dart';

class DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final double labelWidth;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const DetailItem({
    super.key,
    required this.label,
    required this.value,
    this.labelWidth = 100,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              '$label:',
              style: labelStyle ?? const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ?? const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced version with more features
class EnhancedDetailItem extends StatelessWidget {
  final String label;
  final String value;
  final double labelWidth;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final Widget? trailing;
  final bool showDivider;

  const EnhancedDetailItem({
    super.key,
    required this.label,
    required this.value,
    this.labelWidth = 120,
    this.labelStyle,
    this.valueStyle,
    this.trailing,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: labelWidth,
                child: Text(
                  '$label:',
                  style: labelStyle ?? const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: valueStyle ?? const TextStyle(fontSize: 12),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
        if (showDivider) ...[
          const SizedBox(height: 4),
          const Divider(height: 1),
        ],
      ],
    );
  }
}