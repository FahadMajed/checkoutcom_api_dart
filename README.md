
# Checkout API

checkout_api is a Dart package for interacting with the Checkout.com API. It provides a simple and intuitive interface for making API requests and handling responses.

## Features

- Supports Payments, Tokens, and Instruments endpoints
- Provides easy-to-use requests and response objects for accessing response data

## Getting Started

To use checkout_api in your Dart project, add the following dependency to your pubspec.yaml file:

```yaml
dependencies:
  checkout_api:
    git:
      url: git://github.com/FahadMajed/checkoutcom_api_dart.git
```

Then, import the checkout_api library in your Dart code:

```dart
import 'package:checkout_api/checkout_api.dart';
```

## Usage

To send an API request, create a new instance of the Checkout class and use the appropriate method to send the request. For example:

```dart
var checkout = Checkout(secretKey: 'sk_test_1234567890', publicKey: 'pk_test_1234567890');
var response = await checkout.requestToken(tokenRequest);
```

The methods available in the Checkout class are:

- `createCustomer(customer)`: Create a new customer.
- `getCustomerDetails(id)`: Get details for a specific customer by ID.
- `requestToken(tokenRequest)`: Request a new token.
- `createInstrument(instrumentRequest)`: Create a new instrument.
- `getInstrumentDetails(instrumentId)`: Get details for a specific instrument by ID.
- `updateInstrument(instrument, instrumentRequest)`: Update an existing instrument with a new request.
- `deleteInstrument(id)`: Delete an existing instrument by ID.
- `getDefaultInstrument(instruments)`: Get the default instrument from a list of instruments.
- `requestTokenPayment(paymentRequest, card, paymentMethod)`: Request a new payment with a card or payment method token.
- `requestIdPayment(paymentRequest)`: Request a new payment with a previously created card or payment method ID.
- `getPaymentDetails(id)`: Get details for a specific payment by ID.

For more detailed usage examples, see the examples directory in this repository.

## Contributing

Contributions to this library are welcome! If you find any issues or have suggestions for improvements, feel free to open an issue or submit a pull request.

## License

checkout_api is licensed under the MIT License. See the LICENSE file for more information.
