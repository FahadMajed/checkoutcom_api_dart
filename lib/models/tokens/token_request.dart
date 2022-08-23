import 'dart:convert';

import '../models.dart';

class TokenRequest {
  final PaymentMethod type;

  ///apple/ google pay payment token
  final ApplePayTokenData? walletTokenData;
  final CreditCard? card;

  TokenRequest({
    required this.type,
    this.walletTokenData,
    this.card,
  });

  Map<String, dynamic> toMap() {
    if (card?.last4?.isNotEmpty ?? false) {
      return {
        'type': type.name.toLowerCase(),
        ...card!.toTokenMap(),
      };
    } else {
      return {
        'type': type.name.toLowerCase(),
        'token_data': walletTokenData?.toMap(),
      };
    }
  }

  String toJson() => json.encode(toMap());
}
