import 'dart:convert';

import '../payment_type.dart';

class Instrument {
  final String id;
  final PaymentMethod type;
  final String fingerprint; //
  final int expiryMonth;
  final int expiryYear;
  final String last4;
  final String bin; //bank id number
  final String scheme;
  final bool? isDefault;
  Instrument({
    required this.id,
    required this.type,
    required this.fingerprint,
    required this.expiryMonth,
    required this.expiryYear,
    required this.last4,
    required this.bin,
    required this.scheme,
    this.isDefault,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name.toLowerCase(),
      'fingerprint': fingerprint,
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'last4': last4,
      'bin': bin,
      'scheme': scheme,
      'default': isDefault,
    };
  }

  factory Instrument.fromMap(Map<String, dynamic> map) {
    return Instrument(
        id: map['id'] ?? '',
        type: PaymentMethod.values
            .firstWhere((e) => e.name.toLowerCase() == map["type"]),
        fingerprint: map['fingerprint'] ?? '',
        expiryMonth: map['expiry_month']?.toInt() ?? 0,
        expiryYear: map['expiry_year']?.toInt() ?? 0,
        last4: map['last4'] ?? '',
        bin: map['bin'] ?? '',
        scheme: map['scheme'] ?? '',
        isDefault:
            map["customer"] != null ? map["customer"]["default"] : false);
  }

  String toJson() => json.encode(toMap());

  factory Instrument.fromJson(String source) =>
      Instrument.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Instrument &&
        other.id == id &&
        other.type == type &&
        other.fingerprint == fingerprint &&
        other.expiryMonth == expiryMonth &&
        other.expiryYear == expiryYear &&
        other.last4 == last4 &&
        other.bin == bin &&
        other.scheme == scheme &&
        other.isDefault == isDefault;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        type.hashCode ^
        fingerprint.hashCode ^
        expiryMonth.hashCode ^
        expiryYear.hashCode ^
        last4.hashCode ^
        bin.hashCode ^
        scheme.hashCode ^
        isDefault.hashCode;
  }

  @override
  String toString() {
    return 'Instrument(id: $id, type: $type, fingerprint: $fingerprint, expiryMonth: $expiryMonth, expiryYear: $expiryYear, last4: $last4, bin: $bin, scheme: $scheme, isDefault: $isDefault)';
  }

  Instrument copyWith({
    String? id,
    PaymentMethod? type,
    String? fingerprint,
    int? expiryMonth,
    int? expiryYear,
    String? last4,
    String? bin,
    String? scheme,
    bool? isDefault,
  }) {
    return Instrument(
      id: id ?? this.id,
      type: type ?? this.type,
      fingerprint: fingerprint ?? this.fingerprint,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      last4: last4 ?? this.last4,
      bin: bin ?? this.bin,
      scheme: scheme ?? this.scheme,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
