import 'dart:math';

import 'package:checkout_api/lib.dart';
import 'package:checkout_api/utils/api_base.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checkout_api/checkout_api.dart';
import 'package:http/http.dart';

void main() async {
  group("payments", () {
    String pubKey = "";
    String secretKey = "";
    String paymentsUri = "";
    String tokensUri = "";
    String instrumentsUri = "";
    String customersUri = "";

    pubKey = "pk_test_aca36a51-2bd8-4a9b-8706-130312f65b88";
    secretKey = "sk_test_637952cc-4747-4557-87dc-0729ecf639c1";
    paymentsUri = "https://api.sandbox.checkout.com/payments";
    tokensUri = "https://api.sandbox.checkout.com/tokens";
    instrumentsUri = "https://api.sandbox.checkout.com/instruments";
    customersUri = "https://api.sandbox.checkout.com/customers";

    final apiBase = ApiBase("https://api.sandbox.checkout.com/");

    final customersRepository = HttpCustomersRepository(
      headers: {'Content-Type': 'Application/json', 'Authorization': secretKey},
      apiBase: apiBase,
    );

    final randomNumber = Random().nextInt(3000000);
    Customer customer = Customer(
      id: "",
      email: "$randomNumber@gmail.com",
      instruments: [],
      name: "Saleh",
    );

    test("add customer", () async {
      final customerId = await customersRepository.createCustomer(customer);

      customer = customer.copyWith(id: customerId);
      expect(customer.id!.isNotEmpty, true);
    });

    final HttpTokensRepository tokensRepository = HttpTokensRepository(
      headers: {
        'Content-Type': 'Application/json',
        'Authorization': pubKey,
      },
      apiBase: apiBase,
    );

    String token = "";

    final CreditCard card = CreditCard(
      number: "4242424242424242",
      cvv: "100",
      expiryMonth: 6,
      expiryYear: 2025,
      last4: "4242",
      scheme: "visa",
    );
    test("tokenize card", () async {
      final TokenRequest tokenRequest =
          TokenRequest(type: PaymentMethod.Card, card: card);

      final TokenResponse tokenResponse =
          await tokensRepository.requestToken(tokenRequest);

      token = tokenResponse.token;
      expect(token.isNotEmpty, true);
    });

    final HttpInstrumentRepository instrumentRepository =
        HttpInstrumentRepository(
      headers: {'Content-Type': 'Application/json', 'Authorization': secretKey},
      apiBase: apiBase,
    );

    String instrumentId = "";

    test("add instrument to customer", () async {
      final InstrumentRequest instrumentRequest = InstrumentRequest(
        type: PaymentSourceType.Token,
        token: token,
        customer: customer,
      );

      Instrument instrument = await instrumentRepository.createInstrument(
          instrumentRequest: instrumentRequest);
      instrumentId = instrument.id;
      expect(instrument.last4, "4242");
      expect(instrument.type, PaymentMethod.Card);
    });

    test("get instruments details", () async {
      Instrument instrument =
          await instrumentRepository.getInstrumentDetails(instrumentId);

      expect(instrument.last4, "4242");
      expect(instrument.type, PaymentMethod.Card);
    });

    test("get customer details", () async {
      final customerDetails =
          await customersRepository.getCustomerDetails(customer.id!);

      expect(customerDetails.id, customer.id);
      expect(customerDetails.instruments.isNotEmpty, true);
      expect(customerDetails.instruments.first.last4, "4242");
    });

    final HttpPaymentsRepository paymentsRepository = HttpPaymentsRepository(
      headers: {'Content-Type': 'Application/json', 'Authorization': secretKey},
      tokensRepo: tokensRepository,
      apiBase: apiBase,
    );

    test("pay", () async {
      final PaymentRequest paymentRequest = PaymentRequest(
        type: PaymentSourceType.Token,
        amount: 20,
        currency: "SAR",
        customer: customer,
        description: "participants payment",
        reference: "",
      );

      final PaymentResponse paymentResponse =
          await paymentsRepository.requestTokenPayment(
        paymentRequest: paymentRequest,
        //for tokenizing
        card: card,
        method: PaymentMethod.Card,
      );

      expect(paymentResponse.approved, true);
    });

    test("id pay", () async {
      final paymentRequest = PaymentRequest(
          type: PaymentSourceType.Id,
          amount: 200,
          reference: "1q23",
          description: "a payment",
          customer: customer,
          cardId: instrumentId,
          currency: "SAR");

      final PaymentResponse response = await paymentsRepository
          .requestIdPayment(paymentRequest: paymentRequest);

      expect(response.approved, true);
    });
  });
}
