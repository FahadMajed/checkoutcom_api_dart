import 'dart:convert';

class CreditCard {
  final String number;
  final String? last4;
  final String? bin;
  final String? cardHolderName;
  final String? expiresOn;
  final String? scheme;
  final int expiryMonth;
  final int expiryYear;
  final String cvv;
  CreditCard({
    required this.number,
    this.last4,
    this.bin,
    this.cardHolderName,
    this.expiresOn,
    this.scheme,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
  });

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'last4': last4,
      'bin': bin,
      'expires_on': expiresOn,
      'scheme': scheme,
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'cvv': cvv,
    };
  }

  Map<String, dynamic> toTokenMap() {
    return {
      'number': number.trim(),
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'name': cardHolderName,
      'cvv': cvv,
    };
  }

  factory CreditCard.fromMap(Map<String, dynamic> map) {
    return CreditCard(
      number: map['number'] ?? '',
      last4: map['last4'] ?? '',
      bin: map['bin'] ?? '',
      cardHolderName: map['cardHolderName'] ?? "",
      expiresOn: map['expires_on'] ?? '',
      scheme: map['scheme'] ?? '',
      expiryMonth: map['expiry_month'] ?? '',
      expiryYear: map['expiry_year'] ?? '',
      cvv: map['cvv'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CreditCard.fromJson(String source) =>
      CreditCard.fromMap(json.decode(source));
}
