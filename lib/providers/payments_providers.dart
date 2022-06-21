import 'package:riverpod/riverpod.dart';


import '../models/customers/customer.dart';
import '../repositories/repositories.dart';

final paymentApiPubKeyPvdr = Provider<String>((ref) => "");
final paymentApiSecretKeyPvdr = Provider<String>((ref) => "");
final paymentsUriPvdr = Provider<String>((ref) => "");
final tokensUriPvdr = Provider<String>((ref) => "");
final instrumentsUriPvdr = Provider<String>((ref) => "");
final customersUriPvdr = Provider<String>((ref) => "");

final paymentsRepoPvdr = Provider(
  (ref) => HttpPaymentsRepository(
    paymentURI: ref.read(paymentsUriPvdr),
    headers: {
      'Content-Type': 'Application/json',
      'Authorization': ref.read(paymentApiSecretKeyPvdr)
    },
    tokensRepo: ref.read(tokensRepoPvdr),
  ),
);

final tokensRepoPvdr = Provider(
  (ref) => HttpTokensRepository(
    tokensUri: ref.read(tokensUriPvdr),
    headers: {
      'Content-Type': 'Application/json',
      'Authorization': ref.read(paymentApiPubKeyPvdr)
    },
  ),
);

final instrumentsRepoPvdr = Provider(
  (ref) => HttpInstrumentRepository(
    headers: {
      'Content-Type': 'Application/json',
      'Authorization': ref.read(paymentApiSecretKeyPvdr)
    },
    instrumentUri: ref.read(instrumentsUriPvdr),
  ),
);

final customersRepoPvdr = Provider(
  (ref) => HttpCustomersRepository(
    headers: {
      'Content-Type': 'Application/json',
      'Authorization': ref.read(paymentApiSecretKeyPvdr)
    },
    customersUri: ref.read(customersUriPvdr),
  ),
);
