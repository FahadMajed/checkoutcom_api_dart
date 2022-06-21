## Getting started

please make sure that you have carefully read checkout.com api reference, and have created an account (requires 30k$ per month for income).
you can easily create your sandbox account for testing.



## Usage

The package has FOUR repositories.

1. Customers
2. Payments
3. Tokens
4. Instruments

```dart

//initialize api base
final apiBase = ApiBase("https://api.sandbox.checkout.com/");

//create customer
Customer customer = Customer(
      id: "",
      email: "$randomNumber@gmail.com",
      instruments: [],
      name: "Saleh",
    );
    
final customerId = await customersRepository.createCustomer(customer);

customer = customer.copyWith(id: customerId);

//fetch customer
customer = await getCustomerDetails(customer.email) 
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
//2. tokenize the card
final HttpTokensRepository tokensRepository = HttpTokensRepository(
      headers: {
        'Content-Type': 'Application/json',
        'Authorization': pubKey,
      },
      apiBase: apiBase,
    );

String token = "";

final TokenRequest tokenRequest =
          TokenRequest(type: PaymentMethod.Card, card: card);

final TokenResponse tokenResponse =
          await tokensRepository.requestToken(tokenRequest);

token = tokenResponse.token;
      
//3. add instrument to customer
  
final HttpInstrumentRepository instrumentRepository =
        HttpInstrumentRepository(
      headers: {'Content-Type': 'Application/json', 'Authorization': secretKey},
      apiBase: apiBase,
    );
    
final InstrumentRequest instrumentRequest = InstrumentRequest(
        type: PaymentSourceType.Token,
        token: token,
        customer: customer,
      );

Instrument instrument = await instrumentRepository.createInstrument(
          instrumentRequest: instrumentRequest);
          
//get instrument detials
Instrument instrument =
          await instrumentRepository.getInstrumentDetails(instrument.instrumentId);
          
          
//pay with token
final HttpPaymentsRepository paymentsRepository = HttpPaymentsRepository(
      headers: {'Content-Type': 'Application/json', 'Authorization': secretKey},
      tokensRepo: tokensRepository,
      apiBase: apiBase,
    );
    
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
      
//pay with instrument id
      
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


```
## Additional information

for users who are familiar with riverpod, the package has a CustomerNotifer class that handles all the state management for you, also a providers for each repository that inject the dependenies.

##### Example with Riverpod

``` dart 
enum Environment { DEV, PROD }

Future<void> mainCommon(Environment env) async {
  WidgetsFlutterBinding.ensureInitialized();

  // await ConfigReader.initialize();
  String pubKey = "";
  String secretKey = "";
  String baseUri = "";

  switch (env) {
    case Environment.DEV:
      // pubKey = ConfigReader.getPubKeyDev();
      // secretKey = ConfigReader.getSecretKeyDev();
      baseUri = "https://api.sandbox.checkout.com/";
      break;
    case Environment.PROD:
      // pubKey = ConfigReader.getPubKeyProd();
      // secretKey = ConfigReader.getSecretKeyProd();
      baseUri = "https://api.checkout.com/";
      break;
  }

  runApp(
    ProviderScope(
      overrides: [
        //avaialble from package
        paymentApiPubKeyPvdr.overrideWithValue(pubKey),
        paymentApiSecretKeyPvdr.overrideWithValue(secretKey),
        baseUriPvdr.overrideWithValue(baseUri),
      ],
      child: const Home(),
    ),
  );
}



//create the customer provider
//if the customer was not register, the notifer will create a new customer
//using the email, to fetch it later with this identifier
final customerAsyncPvdr =
    StateNotifierProvider<CustomerNotifier, AsyncValue<Customer>>(
  (ref) {
    return CustomerNotifier(
      customersRepo: ref.watch(customersRepoPvdr),
      instrumentsRepo: ref.watch(instrumentsRepoPvdr),
      tokensRepo: ref.watch(tokensRepoPvdr),
      //give it you auth service email
      //e.g watch(firebaseUser).email
      customerId: "email",
      //give it a name
      name: "",
    );
  },
);

class Home extends ConsumerWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(context, ref) {
    // now you can access the instruments of the customer and other data

    final customer = ref.watch(customerAsyncPvdr).value!;
    final customerNotifier = ref.watch(customerAsyncPvdr.notifier);

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
            onPressed: () => ref.read(paymentsRepoPvdr).requestIdPayment(
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
    return Column(children: [
      Text(instrument.last4),
      const SizedBox(
        height: 8,
      ),
      Text(instrument.isDefault.toString())
    ]);
  }
}



//also note that the repositories instances will be created automatiically based on
//your environement, no need to spicify the headers or the apiBase,
// just override the keys providers. you can access them like this:
// 
ref.read(paymentsRepoPvdr).requestPayment(*params);
ref.read(customersRepoPvdr).createCustomer(*params);
// same for tokens and instruments

```
Rememeber to understand the code before coping it, this is just a demo and not well orgnized and architectured!
take care :)
