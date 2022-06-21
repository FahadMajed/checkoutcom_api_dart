/*
Create a payment instrument that you can later use as the source or destination 
for one or more payments
*/
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../lib.dart';

abstract class BaseInstrumentRepository {
  ///Exchange a single use Checkout.com token for a payment instrument reference,
  ///that can be used at any time to request one or more payments.
  Future<Instrument> createInstrument(
      {required InstrumentRequest instrumentRequest});

  ///Returns details of an instrument using [id]
  Future<Instrument> getInstrumentDetails(
    String id,
  );

  ///Update details of an instrument
  Future<Instrument> updateInstrument(
      {required Instrument instrument,
      required InstrumentRequest instrumentRequest});

  ///Delete a payment instrument
  Future<void> deleteInstrument(
    String id,
  );
}

class HttpInstrumentRepository extends BaseInstrumentRepository {
  final headers;
  final String instrumentUri;

  HttpInstrumentRepository(
      {required this.headers, required this.instrumentUri});

  @override
  Future<Instrument> createInstrument(
      {required InstrumentRequest instrumentRequest}) async {
    //
    http.Response response = await http.post(Uri.parse(instrumentUri),
        headers: headers, body: instrumentRequest.toJson());

    switch (response.statusCode) {
      case 201:
        return Instrument.fromJson(response.body);

      case 401:
        throw Exception("unauthorized: ${response.body}");

      case 422:
        throw Exception("invalid data was sent: ${response.body}");

      default:
        throw Exception(response.body);
    }
  }

  @override
  Future<bool> deleteInstrument(String id) async {
    //
    http.Response response = await http.delete(
      Uri.parse(instrumentUri + "/" + id),
      headers: headers,
    );
    switch (response.statusCode) {
      case 204:
        return true;

      default:
        return false;
    }
  }

  @override
  Future<Instrument> getInstrumentDetails(String id) async {
    //
    http.Response response = await http.get(
      Uri.parse(instrumentUri + "/" + id),
      headers: headers,
    );

    switch (response.statusCode) {
      case 200:
        return Instrument.fromJson(response.body);

      case 401:
        throw Exception("unauthorized: ${response.body}");

      case 404:
        throw Exception("instrument not found: ${response.body}");

      default:
        throw Exception(": ${response.body}");
    }
  }

  @override
  Future<Instrument> updateInstrument({
    required Instrument instrument,
    required InstrumentRequest instrumentRequest,
  }) async {
    http.Response response = await http.patch(
      Uri.parse(instrumentUri + "/" + instrumentRequest.id!),
      headers: headers,
      body: instrumentRequest.toJson(),
    );

    switch (response.statusCode) {
      case 200:
        final responseJson = jsonDecode(response.body);

        return instrument.copyWith(
            fingerprint: responseJson["fingerprint"],
            expiryMonth: instrumentRequest.expiryMonth,
            isDefault: instrumentRequest.isDefault,
            expiryYear: instrumentRequest.expiryYear);

      case 401:
        throw Exception("unauthorized: ${response.body}");

      case 404:
        throw Exception("instrument not found: ${response.body}");

      default:
        throw Exception(": ${response.body}");
    }
  }

  Future<Instrument?> getDefaultInstrument(List<Instrument> instruments) async {
    for (final instrument in instruments) {
      final fetchedInstrument = await getInstrumentDetails(instrument.id);
      if (fetchedInstrument.isDefault!) return fetchedInstrument;
    }
    return null;
  }
}
