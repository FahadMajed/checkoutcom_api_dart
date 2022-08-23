import 'package:checkout_api/lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const pubKey = "pk_test_aca36a51-2bd8-4a9b-8706-130312f65b88";
const secretKey = "sk_test_637952cc-4747-4557-87dc-0729ecf639c1";
//Singleton
final checkoutPvdr =
    Provider((ref) => Checkout(secretKey: secretKey, publicKey: pubKey));
