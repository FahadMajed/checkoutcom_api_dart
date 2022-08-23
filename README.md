## Getting started

please make sure that you have carefully read checkout.com api reference, and have created an account (requires 30k$ per month for income).
you can easily create your sandbox account for testing.



## Usage

The package implements the following apis:

1. Customers
2. Payments
3. Tokens
4. Instruments

```dart

//initialize checkout
final checkout = Checkout(secretKey: 'secretKey', publicKey: 'publicKey');

//create customer
Customer customer = Customer(
      id: "",
      email: "$randomNumber@gmail.com",
      instruments: [],
      name: "Saleh",
    );
    
final customerId = await checkout.createCustomer(customer);

customer = customer.copyWith(id: customerId);

//fetch customer
customer = await checkout.getCustomerDetails(customer.email) 
// both email and id can be used

//create instrument for customer


//1. create card model
 final CreditCard card = CreditCard(
      number: "4242424242424242",
      cvv: "100",
      expiryMonth: 6,
      expiryYear: 2025,
      last4: "4242",
      scheme: "visa",
    );


String token = "";

final TokenRequest tokenRequest =
          TokenRequest(type: PaymentMethod.Card, card: card);

final TokenResponse tokenResponse =
          await checkout.requestToken(tokenRequest);

token = tokenResponse.token;
      
//3. add instrument to customer
  

    
final InstrumentRequest instrumentRequest = InstrumentRequest(
        type: PaymentSourceType.Token,
        token: token,
        customer: customer,
      );

Instrument instrument = await checkout.createInstrument(
          instrumentRequest: instrumentRequest);
          
//get instrument detials
Instrument instrument =
          await checkout.getInstrumentDetails(instrument.instrumentId);
          
          
//pay with token
    
final PaymentRequest paymentRequest = PaymentRequest(
        type: PaymentSourceType.Token,
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
        method: PaymentMethod.Card,
      );
      
//pay with instrument id
      
final paymentRequest = PaymentRequest(
          type: PaymentSourceType.Id,
          amount: 200,
          reference: "1q23",
          description: "a payment",
          customer: customer,
          cardId: instrumentId,
          currency: "SAR");

final PaymentResponse response = await checkout
          .requestIdPayment(paymentRequest: paymentRequest);


```
## Additional information

not all operations are implemeneted, for example, refunds. 
you can check Checkout class implementation to see what is covered.

##### Example with Riverpod and Flavors

``` dart 

//Singleton
final checkoutPvdr =
    Provider((ref) => Checkout(secretKey: 'your key', publicKey: 'your key',));


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


```
Rememeber to understand the code before coping it, this is just a demo and not well orgnized and architectured!
take care :)
