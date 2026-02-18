import 'package:ecom/shared/widgets/const/color_const.dart';
import 'package:flutter/material.dart';

class OrderTrackingTimeline extends StatelessWidget {
  final String status;
  final String deliveryStatus;

  const OrderTrackingTimeline({
    super.key,
    required this.status,
    this.deliveryStatus = 'pending',
  });

  @override
  Widget build(BuildContext context) {
    final steps = _stepsForStatus(status, deliveryStatus);

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
        ...steps.map((e) => _stepTile(e.title, e.isDone, e.isLast)),
      ],
    );
  }

  Widget _stepTile(String title, bool done, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: done ? ColorConst.accent : ColorConst.textMuted,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: done
                        ? ColorConst.accent.withValues(alpha: 0.5)
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: done
                        ? ColorConst.accent
                        : ColorConst.textMuted.withValues(alpha: 0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              title,
              style: TextStyle(
                color: done ? ColorConst.textLight : ColorConst.textMuted,
                fontWeight: done ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_Step> _stepsForStatus(String status, String deliveryStatus) {
    status = status.toUpperCase();
    deliveryStatus = deliveryStatus.toLowerCase();

    List<_Step> steps = [_Step("Order Placed", true)];

    if (status == "CANCELLED") {
      steps.add(_Step("Order Cancelled", true, isLast: true));
      return steps;
    }

    // Payment step (Online payment goes to SUCCESS immediately, but for the timeline we check if it started)
    bool isPaid =
        status == "SUCCESS" ||
        status == "OUT_FOR_DELIVERY" ||
        status == "DELIVERED";
    steps.add(_Step("Payment Successful", isPaid));

    // Handling / Processing step
    bool isProcessing =
        isPaid || status == "PROCESSING" || deliveryStatus != 'pending';
    steps.add(_Step("Order Processing", isProcessing));

    // Delivery steps
    bool isOutForDelivery =
        status == "OUT_FOR_DELIVERY" ||
        status == "DELIVERED" ||
        status == "SUCCESS" ||
        deliveryStatus == 'in_transit' ||
        deliveryStatus == 'picked_up';
    steps.add(_Step("Out for Delivery", isOutForDelivery));

    bool isDelivered =
        status == "DELIVERED" ||
        status == "SUCCESS" ||
        deliveryStatus == 'delivered';
    steps.add(_Step("Delivered", isDelivered));

    bool isFinalized = status == "SUCCESS";
    steps.add(_Step("Order Completed", isFinalized, isLast: true));

    return steps;
  }
}

class _Step {
  final String title;
  final bool isDone;
  final bool isLast;

  _Step(this.title, this.isDone, {this.isLast = false});
}
