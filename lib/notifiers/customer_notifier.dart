import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../lib.dart';

///Checkout Customer Notifier
///
class CustomerNotifier extends StateNotifier<AsyncValue<Customer>> {
  final Checkout checkout;

  ///email address, e.g. FirebaseAuth user email
  final String customerId;
  final String name;

  CustomerNotifier({
    required this.checkout,
    required this.customerId,
    required this.name,
  }) : super(const AsyncValue.loading()) {
    if (customerId.isNotEmpty) {
      getCustomerDetails(customerId);
    } else {
      state = AsyncValue.data(
          Customer(id: "", instruments: [], email: '', name: ''));
    }
  }

  ///tries to fetch customer details using [id], if not found, new customer will be created using [id] as an email address to fetch with it next time.
  Future<void> getCustomerDetails(String id) async {
    try {
      final customer = await checkout.getCustomerDetails(id);

      final Instrument? defaultInstrument =
          await checkout.getDefaultInstrument(customer.instruments);

      if (mounted) {
        state = AsyncValue.data(
          customer.copyWith(defaultInstrument: defaultInstrument, name: name),
        );
      }
    } catch (e) {
      //not found

      final customer = Customer(
        id: "",
        email: id,
        name: name,
        instruments: [],
      );

      final customerId = await checkout.createCustomer(customer);

      if (mounted) state = AsyncValue.data(customer.copyWith(id: customerId));
    }
  }

  ///adds new instrument to the customer for future use
  Future<void> addInstrument({required CreditCard creditCard}) async {
    final customer = state.value;
    final token = await _requestToken(creditCard);
    final instrument = await _createInstrument(token, customer!);

    state = AsyncValue.data(
      customer.copyWith(
          instruments: [...customer.instruments, instrument],
          defaultInstrument: customer.instruments.isEmpty ? instrument : null),
    );
  }

  Future<String> _requestToken(CreditCard creditCard) async {
    final tokenRequest =
        TokenRequest(type: PaymentMethod.card, card: creditCard);

    final tokenResponse = await checkout.requestToken(tokenRequest);
    return tokenResponse.token;
  }

  Future<Instrument> _createInstrument(String token, Customer customer) async {
    final instrumentRequest = InstrumentRequest(
      type: PaymentSourceType.token,
      token: token,
      customer: customer,
    );

    return await checkout.createInstrument(
        instrumentRequest: instrumentRequest);
  }

  ///switch a given instrument to default instrument for the customer
  Future<void> setInstrumentToDefault(Instrument instrument) async {
    final customer = state.value;

    final updatedInstrument = await checkout.updateInstrument(
      instrument: instrument,
      instrumentRequest: InstrumentRequest(
        id: instrument.id,
        isDefault: true,
        customer: customer!,
        expiryMonth: instrument.expiryMonth,
        expiryYear: instrument.expiryYear,
      ),
    );

    state = AsyncValue.data(
      customer.copyWith(defaultInstrument: updatedInstrument),
    );
  }

  ///deletes customer instrument using [id]
  Future<void> deleteInstrument(String id) async {
    final customer = state.value;

    await checkout.deleteInstrument(id);

    state = AsyncValue.data(
      customer!.copyWith(
        instruments: [
          for (final i in customer.instruments)
            if (i.id != id) i,
        ],
      ),
    );
  }

  ///updates [instrument] expiry date
  Future<void> updateInstrument(
      {required Instrument instrument,
      required InstrumentRequest instrumentRequest}) async {
    final customer = state.value!;

    final updatedInstrument = await checkout.updateInstrument(
        instrument: instrument, instrumentRequest: instrumentRequest);

    state = AsyncValue.data(
      customer.copyWith(
        instruments: [
          for (final i in customer.instruments)
            if (i.id == updatedInstrument.id) updatedInstrument else i
        ],
        defaultInstrument:
            updatedInstrument.id == customer.defaultInstrument?.id
                ? updatedInstrument
                : null,
      ),
    );
  }
}
