import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../lib.dart';

///Checkout Customer Notifier
class CustomerNotifier extends StateNotifier<AsyncValue<Customer>> {
  final HttpCustomersRepository customersRepo;
  final HttpInstrumentRepository instrumentsRepo;
  final HttpTokensRepository tokensRepo;

  ///email address, e.g. FirebaseAuth user email
  final String customerId;
  final String name;
  final Reader read;

  CustomerNotifier({
    required this.customersRepo,
    required this.instrumentsRepo,
    required this.tokensRepo,
    required this.customerId,
    required this.name,
    required this.read,
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
      final customer = await customersRepo.getCustomerDetails(id);

      final Instrument? defaultInstrument =
          await instrumentsRepo.getDefaultInstrument(customer.instruments);

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

      final customerId = await customersRepo.createCustomer(customer);

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
        TokenRequest(type: PaymentMethod.Card, card: creditCard);

    final tokenResponse = await tokensRepo.requestToken(tokenRequest);
    return tokenResponse.token;
  }

  Future<Instrument> _createInstrument(String token, Customer customer) async {
    final instrumentRequest = InstrumentRequest(
      type: PaymentSourceType.Token,
      token: token,
      customer: customer,
    );

    return await instrumentsRepo.createInstrument(
        instrumentRequest: instrumentRequest);
  }

  ///switch a given instrument to default instrument for the customer
  Future<void> setInstrumentToDefault(Instrument instrument) async {
    final customer = state.value;

    final updatedInstrument = await instrumentsRepo.updateInstrument(
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

    await instrumentsRepo.deleteInstrument(id);

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

    final updatedInstrument = await instrumentsRepo.updateInstrument(
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
