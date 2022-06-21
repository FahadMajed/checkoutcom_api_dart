import 'dart:convert';

import 'package:checkout_api/models/models.dart';

class InstrumentRequest {
  final PaymentSourceType? type;
  final String? token;
  final Customer customer;
  final String? id;
  final int? expiryMonth;
  final int? expiryYear;
  final bool? isDefault;
  InstrumentRequest({
    this.type,
    this.token,
    required this.customer,
    this.id,
    this.expiryMonth,
    this.expiryYear,
    this.isDefault,
  });

  Map<String, dynamic> toMap() {
    if (id == null) {
      return {
        'type': type!.name.toLowerCase(),
        'token': token,
        'customer': customer.toInstrumentMap(),
      };
    } else {
      return {
        //updating
        "expiry_month": expiryMonth,
        "expiry_year": expiryYear,
        "customer": {
          "id": customer.id,
          "default": isDefault,
        }
      };
    }
  }

  String toJson() => json.encode(toMap());
}
