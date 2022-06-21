import 'dart:convert';

import '../instruments/instrument.dart';

class Customer {
  String? id;
  final String email;
  final String name;
  final List<Instrument> instruments;
  final Instrument? defaultInstrument;

  Customer(
      {this.id,
      required this.email,
      required this.name,
      required this.instruments,
      this.defaultInstrument});

  Map<String, dynamic> toMap() {
    if (id!.isNotEmpty) {
      return {
        'id': id,
        'email': email,
        'name': name,
        'instruments': instruments.map((x) => x.toMap()).toList(),
      };
    } else {
      return {
        'email': email,
        'name': name,
      };
    }
  }

  Map<String, dynamic> idToMap() {
    return {
      'id': id,
    };
  }

  Map<String, dynamic> toInstrumentMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'default': true,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      instruments: map['instruments'] != null
          ? List<Instrument>.from(
              map['instruments'].map((x) => Instrument.fromMap(x)))
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory Customer.fromJson(String source) =>
      Customer.fromMap(json.decode(source));

  Customer copyWith({
    String? id,
    String? email,
    String? name,
    List<Instrument>? instruments,
    Instrument? defaultInstrument,
  }) {
    return Customer(
      id: id ?? this.id,
      defaultInstrument: defaultInstrument ?? this.defaultInstrument,
      email: email ?? this.email,
      name: name ?? this.name,
      instruments: instruments ?? this.instruments,
    );
  }
}
