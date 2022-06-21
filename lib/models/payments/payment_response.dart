import 'dart:convert';

import '../customers/customer.dart';
import '../payment_type.dart';

class PaymentResponse {
  final String id;
  final String actionId;
  final int amount;
  final bool approved;
  final String status;
  final String responseCode;
  final PaymentMethod? type;
  final String token;
  final String reference;
  final String description;
  final Customer customer;
  final String currency;
  final String processedOn;
  PaymentResponse({
    required this.id,
    required this.actionId,
    required this.amount,
    required this.approved,
    required this.status,
    required this.responseCode,
    this.type,
    required this.token,
    required this.reference,
    required this.description,
    required this.customer,
    required this.currency,
    required this.processedOn,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'actionId': actionId,
      'amount': amount,
      'approved': approved,
      'status': status,
      'responseCode': responseCode,
      'type': type!.name.toLowerCase(),
      'token': token,
      'reference': reference,
      'description': description,
      'customer': customer.toMap(),
      'currency': currency,
      'processedOn': processedOn,
    };
  }

  factory PaymentResponse.fromMap(Map<String, dynamic> map) {
    return PaymentResponse(
      id: map['id'] ?? '',
      actionId: map['actionId'] ?? '',
      amount: map['amount']?.toInt() ?? 0,
      approved: map['approved'] ?? false,
      status: map['status'] ?? '',
      responseCode: map['responseCode'] ?? '',
      token: map['token'] ?? '',
      reference: map['reference'] ?? '',
      description: map['description'] ?? '',
      customer: Customer.fromMap(map['customer']),
      currency: map['currency'] ?? '',
      processedOn: map['processedOn'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory PaymentResponse.fromJson(String source) =>
      PaymentResponse.fromMap(json.decode(source));
}

class PaymentResponse3DS extends PaymentResponse {
  final String redirectUrl;
  PaymentResponse3DS({
    required this.redirectUrl,
    id,
    actionId,
    amount,
    approved,
    status,
    responseCode,
    token,
    reference,
    description,
    customer,
    currency,
    processedOn,
  }) : super(
          id: id,
          actionId: actionId,
          amount: amount,
          approved: approved,
          status: status,
          responseCode: responseCode,
          token: token,
          reference: reference,
          description: description,
          customer: customer,
          currency: currency,
          processedOn: processedOn,
        );

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'actionId': actionId,
      'amount': amount,
      'approved': approved,
      'status': status,
      'responseCode': responseCode,
      'type': type!.name.toLowerCase(),
      'token': token,
      'reference': reference,
      'description': description,
      'customer': customer.toMap(),
      'currency': currency,
      'processedOn': processedOn,
    };
  }

  factory PaymentResponse3DS.fromMap(Map<String, dynamic> map) {
    return PaymentResponse3DS(
        id: map['id'] ?? '',
        actionId: map['actionId'] ?? '',
        amount: map['amount']?.toInt() ?? 0,
        approved: map['approved'] ?? false,
        status: map['status'] ?? '',
        responseCode: map['responseCode'] ?? '',
        token: map['token'] ?? '',
        reference: map['reference'] ?? '',
        description: map['description'] ?? '',
        customer: Customer.fromMap(map['customer']),
        currency: map['currency'] ?? '',
        processedOn: map['processedOn'] ?? '',
        redirectUrl: map["_links"]["redirect"]["href"]);
  }

  @override
  String toJson() => json.encode(toMap());

  factory PaymentResponse3DS.fromJson(String source) =>
      PaymentResponse3DS.fromMap(json.decode(source));
}
