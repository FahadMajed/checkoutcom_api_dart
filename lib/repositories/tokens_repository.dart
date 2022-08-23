import 'package:checkout_api/utils/api_base.dart';
import 'package:http/http.dart' as http;

import '../models/tokens/token_request.dart';
import '../models/tokens/token_response.dart';

///Create a token that represents a card's details
///(or their tokenized form in a digital wallet) that you can later
///use to request a payment,
/// without you having to process or store any sensitive information.
abstract class BaseTokensRepository {
  ///Exchange a digital wallet payment token or card details
  ///for a reference token that can be used later to request a card payment.
  /// Tokens are single use and expire after 15 minutes.
  ///To create a token, please authenticate using your public key.
  Future<TokenResponse> requestToken(TokenRequest tokenRequest);
}

class HttpTokensRepository implements BaseTokensRepository {
  final headers;
  final ApiBase apiBase;
  static const _tokens = "tokens";

  HttpTokensRepository({
    required this.headers,
    required this.apiBase,
  });

  @override
  Future<TokenResponse> requestToken(TokenRequest tokenRequest) async {
    Map responseMap = await apiBase.call(
      RESTOption.post,
      resource: _tokens,
      headers: headers,
      body: tokenRequest.toJson(),
    );

    return TokenResponse.fromMap(responseMap);
  }
}
