import 'package:checkout_api/utils/api_base.dart';
import 'package:http/http.dart' as http;

import '../lib.dart';

///To accept payments from cards, digital wallets and many alternative
///payment methods, specify the source.type field, along with
///the source-specific data.
///
///To pay out to a card, specify the destination
///of your payout using the destination.type field, along with the destination-specific data.
///
///To verify the success of the payment,
///check the approved field in the response.

abstract class BasePaymentsRepository {
  /// pay using The Checkout.com token (e.g., a card or digital wallet token)
  Future<PaymentResponse> requestTokenPayment(
      {required PaymentRequest paymentRequest,
      ApplePayTokenData? applePayTokenData,
      required PaymentMethod method});

  ///Returns the details of the payment with the specified identifier string.
  ///
  /// If the payment method requires a redirection to a third party (e.g., 3D Secure),
  ///  the redirect URL back to your site will include a
  /// cko-session-id query parameter containing a payment
  /// session ID that can be used to obtain the details of the payment,
  /// for example:
  /// http://example.com/success?cko-session-id=sid_ubfj2q76miwundwlk72vxt2i7q
  Future<PaymentResponse> getPaymentDetails(String id);

//pay using The payment source identifer (e.g., a card source identifier)
  Future<PaymentResponse> requestIdPayment({
    required PaymentRequest paymentRequest,
  });
}

class HttpPaymentsRepository implements BasePaymentsRepository {
  final BaseTokensRepository tokensRepo;
  final headers;
  static const _payments = "payments";

  final ApiBase apiBase;
  HttpPaymentsRepository(
      {required this.tokensRepo, required this.headers, required this.apiBase});

  @override
  Future<PaymentResponse> requestTokenPayment({
    required PaymentRequest paymentRequest,
    CreditCard? card,
    ApplePayTokenData? applePayTokenData,
    required PaymentMethod method,
  }) async {
    final token = await _tokenize(
      method,
      applePayTokenData: applePayTokenData,
      card: card,
    );

    Map<String, dynamic> response = await apiBase.call(
      RESTOption.post,
      resource: _payments,
      headers: headers,
      body: paymentRequest.copyWith(token: token).toJson(),
    );

    return PaymentResponse.fromMap(response);
  }

  Future<String> _tokenize(
    PaymentMethod method, {
    ApplePayTokenData? applePayTokenData,
    CreditCard? card,
  }) async {
    //
    final tokenRequest = TokenRequest(
      type: method,
      walletTokenData: applePayTokenData,
      card: card,
    );

    final tokenResponse = await tokensRepo.requestToken(tokenRequest);

    return tokenResponse.token;
  }

  @override
  Future<PaymentResponse> getPaymentDetails(String id) async {
    http.Response response = await apiBase.call(
      RESTOption.get,
      resource: _payments,
      headers: headers,
    );

    return PaymentResponse.fromJson(response.body);
  }

  @override
  Future<PaymentResponse> requestIdPayment(
      {required PaymentRequest paymentRequest}) async {
    dynamic responseMap = await apiBase.call(
      RESTOption.post,
      resource: _payments,
      headers: headers,
      body: paymentRequest.toJson(),
    );

    switch (responseMap["status"] as String) {
      case "Authorized":
        return PaymentResponse.fromMap(responseMap);
      case "Pending":
        return PaymentResponse3DS.fromMap(responseMap);

      default:
        return PaymentResponse.fromMap(responseMap);
    }
  }
}
