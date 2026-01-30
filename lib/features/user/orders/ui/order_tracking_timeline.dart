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
    List<_Step> steps = [_Step("Order Placed", true)];

    if (status == "CANCELLED") {
      steps.add(_Step("Order Cancelled", true, isLast: true));
      return steps;
    }

    // Payment step
    steps.add(
      _Step(
        "Payment Successful",
        status == "SUCCESS" || status == "PROCESSING",
      ),
    );

    // Handling / Processing step
    bool isProcessing = status == "PROCESSING" || deliveryStatus != 'pending';
    steps.add(_Step("Order Processing", isProcessing));

    // Delivery steps
    bool isAssigned =
        deliveryStatus == 'assigned' ||
        deliveryStatus == 'picked_up' ||
        deliveryStatus == 'in_transit' ||
        deliveryStatus == 'delivered';
    steps.add(_Step("Handed over to Delivery", isAssigned));

    bool isPickedUp =
        deliveryStatus == 'picked_up' ||
        deliveryStatus == 'in_transit' ||
        deliveryStatus == 'delivered';
    steps.add(_Step("Picked up by Courier", isPickedUp));

    bool isInTransit =
        deliveryStatus == 'in_transit' || deliveryStatus == 'delivered';
    steps.add(_Step("On the Way", isInTransit));

    bool isDelivered = deliveryStatus == 'delivered';
    steps.add(_Step("Delivered", isDelivered, isLast: true));

    return steps;
  }
}

class _Step {
  final String title;
  final bool isDone;
  final bool isLast;

  _Step(this.title, this.isDone, {this.isLast = false});
}
