import 'dart:convert';
import 'dart:io';

import 'package:checkout_api/utils/api_exception.dart';
import 'package:http/http.dart' as http;

enum RESTOption { get, post, patch, delete }

///T is repsonse
class ApiBase {
  final String _baseUrl;

  ApiBase(this._baseUrl);

  Future<dynamic> call(
    RESTOption option, {
    required String resource,
    required headers,
    String? body,
  }) async {
    dynamic responseJson;
    http.Response response;
    try {
      switch (option) {
        case RESTOption.get:
          response =
              await http.get(Uri.parse(_baseUrl + resource), headers: headers);
          break;
        case RESTOption.post:
          response = await http.post(
            Uri.parse(_baseUrl + resource),
            headers: headers,
            body: body,
          );
          break;
        case RESTOption.patch:
          response = await http.patch(
            Uri.parse(_baseUrl + resource),
            headers: headers,
            body: body,
          );
          break;
        case RESTOption.delete:
          response = await http.delete(
            Uri.parse(_baseUrl + resource),
            headers: headers,
            body: body,
          );
          break;
      }

      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        final responseJson = json.decode(response.body.toString());
        return responseJson;
      case 201:
        final responseJson = json.decode(response.body.toString());
        return responseJson;
      case 202:
        final responseJson = json.decode(response.body.toString());
        return responseJson;
      case 204:
        final responseJson = json.decode(response.body.toString());
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
        throw UnauthorizedException(response.body.toString());
      case 403:
        throw UnauthorizedException(response.body.toString());
      case 404:
        throw NotFound(response.body.toString());
      case 422:
        throw InvalidRequestException(response.body.toString());
      case 429:
        throw TooManyRequests(response.body.toString());
      case 502:
        throw BadGateway(response.body.toString());
      default:
        throw FetchDataException(
            'Error occurred while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}
