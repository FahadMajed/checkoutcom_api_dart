import 'dart:math';

import 'package:checkout_api/lib.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group("payments", () {
    String pubKey = "";
    String secretKey = "";

    pubKey = "pk_test_aca36a51-2bd8-4a9b-8706-130312f65b88";
    secretKey = "sk_test_637952cc-4747-4557-87dc-0729ecf639c1";

    final checkout = Checkout(
      secretKey: secretKey,
      publicKey: pubKey,
      testing: true,
    );

    final randomNumber = Random().nextInt(3000000);
    Customer customer = Customer(
      id: "",
      email: "$randomNumber@gmail.com",
      instruments: [],
      name: "Saleh",
    );

    test("add customer", () async {
      final customerId = await checkout.createCustomer(customer);

      customer = customer.copyWith(id: customerId);
      expect(customer.id!.isNotEmpty, true);
    });

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
          TokenRequest(type: PaymentMethod.card, card: card);

      final TokenResponse tokenResponse =
          await checkout.requestToken(tokenRequest);

      token = tokenResponse.token;
      expect(token.isNotEmpty, true);
    });

    String instrumentId = "";

    test("add instrument to customer", () async {
      final InstrumentRequest instrumentRequest = InstrumentRequest(
        type: PaymentSourceType.token,
        token: token,
        customer: customer,
      );

      Instrument instrument =
          await checkout.createInstrument(instrumentRequest: instrumentRequest);
      instrumentId = instrument.id;
      expect(instrument.last4, "4242");
      expect(instrument.type, PaymentMethod.card);
    });

    test("get instruments details", () async {
      Instrument instrument = await checkout.getInstrumentDetails(instrumentId);

      expect(instrument.last4, "4242");
      expect(instrument.type, PaymentMethod.card);
    });

    test("get customer details", () async {
      final customerDetails = await checkout.getCustomerDetails(customer.id!);

      expect(customerDetails.id, customer.id);
      expect(customerDetails.instruments.isNotEmpty, true);
      expect(customerDetails.instruments.first.last4, "4242");
    });

    test("pay", () async {
      final PaymentRequest paymentRequest = PaymentRequest(
        type: PaymentSourceType.token,
        amount: 20,
        currency: "SAR",
        customer: customer,
        description: "participants payment",
        reference: "",
      );

      final PaymentResponse paymentResponse =
          await checkout.requestTokenPayment(
        paymentRequest: paymentRequest,
        //for tokenizing
        card: card,
        method: PaymentMethod.card,
      );

      expect(paymentResponse.approved, true);
    });

    test("id pay", () async {
      final paymentRequest = PaymentRequest(
          type: PaymentSourceType.id,
          amount: 200,
          reference: "1q23",
          description: "a payment",
          customer: customer,
          cardId: instrumentId,
          currency: "SAR");

      final PaymentResponse response =
          await checkout.requestIdPayment(paymentRequest: paymentRequest);

      expect(response.approved, true);
    });
  });
}
