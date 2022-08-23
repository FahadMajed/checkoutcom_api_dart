library checkout_api;

import 'package:checkout_api/lib.dart';

const baseUrl = "https://api.checkout.com/";
const testingUrl = "https://api.sandbox.checkout.com/";

class Checkout
    implements
        BaseTokensRepository,
        BaseCustomerRepository,
        BasePaymentsRepository,
        BaseInstrumentRepository {
  late final BaseTokensRepository tokensRepository;
  late final BaseCustomerRepository customerRepository;
  late final BasePaymentsRepository paymentsRepository;
  late final BaseInstrumentRepository instrumentRepository;

  //sandbox or production

  Checkout(
      {bool testing = false,
      BaseTokensRepository? tokensRepository,
      BaseCustomerRepository? customerRepository,
      BasePaymentsRepository? paymentsRepository,
      BaseInstrumentRepository? instrumentRepository,
      required String secretKey,
      required String publicKey}) {
    final secretHeaders = {
      'Content-Type': 'Application/json',
      'Authorization': secretKey,
    };

    final publicHeaders = {
      'Content-Type': 'Application/json',
      'Authorization': publicKey,
    };

    if (customerRepository == null) {
      this.customerRepository = HttpCustomersRepository(
          apiBase: testing ? ApiBase(testingUrl) : ApiBase(testingUrl),
          headers: secretHeaders);
    } else {
      this.customerRepository = customerRepository;
    }
    if (instrumentRepository == null) {
      this.instrumentRepository = HttpInstrumentRepository(
          apiBase: testing ? ApiBase(testingUrl) : ApiBase(testingUrl),
          headers: secretHeaders);
    } else {
      this.instrumentRepository = instrumentRepository;
    }
    if (tokensRepository == null) {
      this.tokensRepository = HttpTokensRepository(
          apiBase: testing ? ApiBase(testingUrl) : ApiBase(testingUrl),
          headers: publicHeaders);
    } else {
      this.tokensRepository = tokensRepository;
    }
    if (paymentsRepository == null) {
      this.paymentsRepository = HttpPaymentsRepository(
          apiBase: testing ? ApiBase(testingUrl) : ApiBase(testingUrl),
          tokensRepo: this.tokensRepository,
          headers: secretHeaders);
    } else {
      this.paymentsRepository = paymentsRepository;
    }
  }

  @override
  Future<String?> createCustomer(Customer customer) async =>
      await customerRepository.createCustomer(customer);

  @override
  Future<Customer> getCustomerDetails(String id) async =>
      await customerRepository.getCustomerDetails(id);

  @override
  Future<Instrument> createInstrument(
          {required InstrumentRequest instrumentRequest}) async =>
      await instrumentRepository.createInstrument(
          instrumentRequest: instrumentRequest);

  @override
  Future<Instrument> updateInstrument(
          {required Instrument instrument,
          required InstrumentRequest instrumentRequest}) async =>
      await instrumentRepository.updateInstrument(
        instrument: instrument,
        instrumentRequest: instrumentRequest,
      );

  @override
  Future<void> deleteInstrument(String id) async =>
      await instrumentRepository.deleteInstrument(id);

  @override
  Future<Instrument> getInstrumentDetails(String id) async =>
      await instrumentRepository.getInstrumentDetails(id);

  @override
  Future<Instrument?> getDefaultInstrument(
          List<Instrument> instruments) async =>
      await instrumentRepository.getDefaultInstrument(instruments);

  @override
  Future<PaymentResponse> getPaymentDetails(String id) async =>
      await paymentsRepository.getPaymentDetails(id);

  @override
  Future<PaymentResponse> requestIdPayment(
          {required PaymentRequest paymentRequest}) async =>
      await paymentsRepository.requestIdPayment(
        paymentRequest: paymentRequest,
      );

  @override
  Future<TokenResponse> requestToken(TokenRequest tokenRequest) async =>
      await tokensRepository.requestToken(tokenRequest);

  @override
  Future<PaymentResponse> requestTokenPayment(
          {required PaymentRequest paymentRequest,
          CreditCard? card,
          ApplePayTokenData? applePayTokenData,
          required PaymentMethod method}) async =>
      await paymentsRepository.requestTokenPayment(
        paymentRequest: paymentRequest,
        method: method,
        card: card,
        applePayTokenData: applePayTokenData,
      );
}
