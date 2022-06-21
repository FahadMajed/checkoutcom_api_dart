import 'package:http/http.dart' as http;

import '../models/tokens/token_request.dart';
import '../models/tokens/token_response.dart';

///Create a token that represents a card's details
///(or their tokenized form in a digital wallet) that you can later
///use to request a payment,
/// without you having to process or store any sensitive information.
abstract class TokensRepository {
  ///Exchange a digital wallet payment token or card details
  ///for a reference token that can be used later to request a card payment.
  /// Tokens are single use and expire after 15 minutes.
  ///To create a token, please authenticate using your public key.
  Future<TokenResponse> requestToken(TokenRequest tokenRequest);
}

class HttpTokensRepository implements TokensRepository {
  final headers;
  final String tokensUri;

  HttpTokensRepository({
    required this.headers,
    required this.tokensUri,
  });

  @override
  Future<TokenResponse> requestToken(TokenRequest tokenRequest) async {
    http.Response response = await http.post(
      Uri.parse(tokensUri),
      headers: headers,
      body: tokenRequest.toJson(),
    );

    switch (response.statusCode) {
      case 201:
        return TokenResponse.fromJson(response.body);

      case 401:
        throw Exception("unauthorized");

      case 422:
        throw Exception("invalid data was sent: ${response.statusCode}");

      default:
        throw Exception("Error: ${response.statusCode}");
    }
  }
}
