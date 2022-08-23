import 'package:checkout_api/providers/checkout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../lib.dart';

enum Environment { dev, prod }

Future<void> mainCommon(Environment env) async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(overrides: [
      if (env == Environment.dev)
        checkoutPvdr.overrideWithValue(
          Checkout(
            secretKey: 'sanbox-key',
            publicKey: 'sandbox-key',
            testing: true,
          ),
        )
    ], child: const Home()),
  );
}

//create the customer provider
//if the customer was not register, the notifer will create a new customer
//using the email, to fetch it later with this identifier
final customerAsyncPvdr =
    StateNotifierProvider<CustomerNotifier, AsyncValue<Customer>>(
  (ref) => CustomerNotifier(
    checkout: ref.watch(checkoutPvdr),
    customerId: "e.g. firebase_auth.email",
    name: "",
  ),
);

class Home extends ConsumerWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(context, ref) {
    final watch = ref.watch;

    final checkout = watch(checkoutPvdr);

    final customer = watch(customerAsyncPvdr).value!;
    final customerNotifier = watch(customerAsyncPvdr.notifier);

    return Column(
      children: [
        for (final i in customer.instruments) ...[
          CreditCardWidget(instrument: i),
          ElevatedButton(
              onPressed: () => customerNotifier.setInstrumentToDefault(i),
              child: const Text("Set To Default")),
          ElevatedButton(
              onPressed: () => customerNotifier.updateInstrument(
                    instrument: i,
                    instrumentRequest: InstrumentRequest(
                      customer: customer,
                      expiryMonth: 7,
                      expiryYear: 2027,
                    ),
                  ),
              child: const Text("Update Card")),
          ElevatedButton(
              onPressed: () => customerNotifier.deleteInstrument(i.id),
              child: const Text("Delete Card")),
        ],
        ElevatedButton(
            onPressed: () {
              customerNotifier.addInstrument(
                creditCard: CreditCard(
                    number: "4242424242424242",
                    expiryMonth: 4,
                    expiryYear: 2027,
                    cvv: "100"),
              );
            },
            child: const Text("Add Card")),
        ElevatedButton(
            onPressed: () => checkout.requestIdPayment(
                paymentRequest: PaymentRequest(
                    type: PaymentSourceType.Id,
                    amount: 200,
                    reference: "1q23",
                    description: "a payment",
                    customer: customer,
                    cardId: customer.defaultInstrument?.id,
                    currency: "SAR")),
            child: Text("Pay 200 With ${customer.defaultInstrument?.last4}")),
      ],
    );
  }
}

class CreditCardWidget extends StatelessWidget {
  final Instrument instrument;
  const CreditCardWidget({
    Key? key,
    required this.instrument,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(instrument.last4),
        const SizedBox(
          height: 8,
        ),
        Text(instrument.isDefault.toString())
      ],
    );
  }
}
