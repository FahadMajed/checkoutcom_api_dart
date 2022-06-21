/*
Create a payment instrument that you can later use as the source or destination 
for one or more payments
*/
import 'dart:convert';

import 'package:checkout_api/utils/api_base.dart';
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
  static const _instruments = "instruments";
  final ApiBase apiBase;

  HttpInstrumentRepository({required this.headers, required this.apiBase});

  @override
  Future<Instrument> createInstrument(
      {required InstrumentRequest instrumentRequest}) async {
    //
    Map<String, dynamic> responseMap = await apiBase.call(RESTOption.post,
        resource: _instruments,
        headers: headers,
        body: instrumentRequest.toJson());

    return Instrument.fromMap(responseMap);
  }

  @override
  Future<bool> deleteInstrument(String id) async {
    //
    await apiBase.call(
      RESTOption.delete,
      resource: _instruments + "/" + id,
      headers: headers,
    );

    return true;
  }

  @override
  Future<Instrument> getInstrumentDetails(String id) async {
    //
    Map<String, dynamic> responseMap = await apiBase.call(
      RESTOption.get,
      resource: _instruments + "/" + id,
      headers: headers,
    );

    return Instrument.fromMap(responseMap);
  }

  @override
  Future<Instrument> updateInstrument({
    required Instrument instrument,
    required InstrumentRequest instrumentRequest,
  }) async {
    Map responseMap = await apiBase.call(
      RESTOption.patch,
      resource: _instruments + "/" + instrumentRequest.id!,
      headers: headers,
      body: instrumentRequest.toJson(),
    );

    return instrument.copyWith(
        fingerprint: responseMap["fingerprint"],
        expiryMonth: instrumentRequest.expiryMonth,
        isDefault: instrumentRequest.isDefault,
        expiryYear: instrumentRequest.expiryYear);
  }

  Future<Instrument?> getDefaultInstrument(List<Instrument> instruments) async {
    for (final instrument in instruments) {
      final fetchedInstrument = await getInstrumentDetails(instrument.id);
      if (fetchedInstrument.isDefault!) return fetchedInstrument;
    }
    return null;
  }
}
