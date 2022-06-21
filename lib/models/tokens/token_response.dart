import 'dart:convert';

import '../credit_card.dart';
import '../payment_type.dart';

class TokenResponse {
  final CreditCard card;
  final String token;
  final PaymentMethod type;
  TokenResponse({
    required this.card,
    required this.token,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'card': card.toMap(),
      'token': token,
      'type': type.name,
    };
  }

  factory TokenResponse.fromMap(Map<String, dynamic> map) {
    return TokenResponse(
      card: CreditCard.fromJson(json.encode(map)),
      token: map['token'] ?? '',
      type: PaymentMethod.values
          .firstWhere((e) => e.name.toLowerCase() == map['type']),
    );
  }

  String toJson() => json.encode(toMap());

  factory TokenResponse.fromJson(String source) =>
      TokenResponse.fromMap(json.decode(source));
}
