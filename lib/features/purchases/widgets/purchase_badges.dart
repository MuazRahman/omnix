import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/common/widgets/status_pill_widget.dart';
import 'package:omnix/features/purchases/model/purchase_model.dart';

/// Tone of the status pill for a purchase order.
PillTone purchaseStatusTone(PurchaseStatus status) {
  switch (status) {
    case PurchaseStatus.draft:
      return PillTone.blue;
    case PurchaseStatus.ordered:
      return PillTone.amber;
    case PurchaseStatus.inTransit:
      return PillTone.blue;
    case PurchaseStatus.received:
      return PillTone.green;
    case PurchaseStatus.cancelled:
      return PillTone.neutral;
  }
}

/// Accent of a purchase status, used for timeline captions.
Color purchaseStatusColor(PurchaseStatus status) {
  switch (status) {
    case PurchaseStatus.draft:
      return AppTheme.infoBlueLight;
    case PurchaseStatus.ordered:
      return AppTheme.badgeAmberText;
    case PurchaseStatus.inTransit:
      return AppTheme.infoBlueLight;
    case PurchaseStatus.received:
      return AppTheme.lightGreen;
    case PurchaseStatus.cancelled:
      return AppTheme.badgeNeutralText;
  }
}

/// Tone of the payment pill for a purchase order.
PillTone purchasePaymentTone(PaymentStatus status) {
  switch (status) {
    case PaymentStatus.unpaid:
      return PillTone.red;
    case PaymentStatus.partial:
      return PillTone.amber;
    case PaymentStatus.paid:
      return PillTone.green;
  }
}
