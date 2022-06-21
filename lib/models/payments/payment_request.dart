import 'dart:convert';

import 'package:flutter/material.dart';

import '../customers/customer.dart';
import '../payment_type.dart';

class PaymentRequest {
  final PaymentSourceType type;
  final bool isPayout;
  final String? token;
  final String? cardId;
  final int amount;
  final String reference;
  final String description;
  final Customer customer;

  final String currency;
  final bool is3dsEnabled;

  PaymentRequest({
    required this.type,
    this.isPayout = false,
    this.token = "",
    this.cardId,
    required this.amount,
    required this.reference,
    required this.description,
    required this.customer,
    required this.currency,
    this.is3dsEnabled = false,
  });

  Map<String, dynamic> toMap() {
    return token!.isNotEmpty
        ? {
            'source': {
              'type': "token",
              'token': token,
            },
            "amount": amount,
            'reference': reference,
            'description': description,
            'customer': customer.toMap(),
            'currency': currency,
            '3ds': {
              "enabled": is3dsEnabled,
            },
          }
        : {
            if (isPayout)
              'destination': {
                "type": "id",
                "id": cardId,
                "first_name": customer.name,
                "last_name": customer.name
              }
            else
              'source': {
                'type': "id",
                'id': cardId,
              },
            "amount": amount,
            'reference': reference,
            'description': description,
            'customer': customer.toMap(),
            'currency': currency,
            '3ds': {
              "enabled": is3dsEnabled,
            },
          };
  }

  String toJson() => json.encode(toMap());

  PaymentRequest copyWith({
    required String token,
  }) {
    return PaymentRequest(
        type: type,
        token: token,
        amount: amount,
        reference: reference,
        description: description,
        customer: customer,
        currency: currency,
        isPayout: isPayout,
        cardId: cardId,
        is3dsEnabled: is3dsEnabled);
  }
}
