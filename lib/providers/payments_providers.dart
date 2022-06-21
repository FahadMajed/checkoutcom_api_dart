import 'package:riverpod/riverpod.dart';

import '../lib.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../utils/api_base.dart';

final paymentApiPubKeyPvdr = Provider<String>((ref) => "");
final paymentApiSecretKeyPvdr = Provider<String>((ref) => "");
final paymentsUriPvdr = Provider<String>((ref) => "payments");
final tokensUriPvdr = Provider<String>((ref) => "tokens");
final instrumentsUriPvdr = Provider<String>((ref) => "instruments");
final customersUriPvdr = Provider<String>((ref) => "customers");
final baseUri = Provider<String>((ref) => "https://api.sandbox.checkout.com/");

final apiBasePvdr = Provider((ref) => ApiBase(ref.read(baseUri)));

final paymentsRepoPvdr = Provider(
  (ref) => HttpPaymentsRepository(
    headers: {
      'Content-Type': 'Application/json',
      'Authorization': ref.read(paymentApiSecretKeyPvdr)
    },
    apiBase: ref.read(apiBasePvdr),
    tokensRepo: ref.read(tokensRepoPvdr),
  ),
);

final tokensRepoPvdr = Provider(
  (ref) => HttpTokensRepository(
    apiBase: ref.read(apiBasePvdr),
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
    apiBase: ref.read(apiBasePvdr),
  ),
);

final customersRepoPvdr = Provider(
  (ref) => HttpCustomersRepository(
    headers: {
      'Content-Type': 'Application/json',
      'Authorization': ref.read(paymentApiSecretKeyPvdr)
    },
    apiBase: ref.read(apiBasePvdr),
  ),
);
