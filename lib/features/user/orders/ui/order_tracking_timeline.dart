import 'package:ecom/shared/widgets/const/color_const.dart';
import 'package:flutter/material.dart';

class OrderTrackingTimeline extends StatelessWidget {
  final String status;

  const OrderTrackingTimeline({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = _stepsForStatus(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Order Tracking",
          style: TextStyle(
            color: ColorConst.textLight,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        ...steps.map((e) => _stepTile(e.title, e.isDone)).toList(),
      ],
    );
  }

  Widget _stepTile(String title, bool done) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: done ? ColorConst.accent : ColorConst.textMuted,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            title,
            style: TextStyle(
              color: done ? ColorConst.textLight : ColorConst.textMuted,
              fontWeight: done ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  List<_Step> _stepsForStatus(String status) {
    if (status == "SUCCESS") {
      return [
        _Step("Order Placed", true),
        _Step("Payment Successful", true),
      ];
    }

    if (status == "FAILED") {
      return [
        _Step("Order Placed", true),
        _Step("Payment Failed", false),
      ];
    }

    return [
      _Step("Order Placed", true),
      _Step("Waiting for Payment", false),
    ];
  }
}

class _Step {
  final String title;
  final bool isDone;

  _Step(this.title, this.isDone);
}
