import 'dart:convert';

class ApplePayTokenData {
  final String data;
  final String version;
  final header;
  final String signature;

  ApplePayTokenData({
    required this.data,
    required this.version,
    required this.header,
    required this.signature,
  });

  Map<String, dynamic> toMap() {
    return {
      'data': data,
      'version': version,
      'header': header,
      'signature': signature,
    };
  }

  factory ApplePayTokenData.fromMap(Map<String, dynamic> map) {
    return ApplePayTokenData(
      data: map['data'] ?? '',
      version: map['version'] ?? '',
      header: map['header'] ?? '',
      signature: map['signature'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ApplePayTokenData.fromJson(String source) =>
      ApplePayTokenData.fromMap(json.decode(source));
}
