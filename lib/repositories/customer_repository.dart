import 'package:http/http.dart' as http;

import '../models/customers/customer.dart';

abstract class BaseCustomerRepository {
  ///Store a customer's details in a customer object to reuse in future payments.
  /// Link a payment instrument using the Update customer details endpoint,
  /// so the customer [id] returned can be passed as a source when making a payment.
  Future<String?> createCustomer(Customer customer);

  ///Returns details of a customer and their instruments
  Future<Customer> getCustomerDetails(String id);
}

class HttpCustomersRepository extends BaseCustomerRepository {
  final headers;
  final String customersUri;

  HttpCustomersRepository({required this.headers, required this.customersUri});

  @override
  Future<String?> createCustomer(Customer customer) async {
    //
    final http.Response response = await http.post(Uri.parse(customersUri),
        headers: headers, body: customer.toJson());

    switch (response.statusCode) {
      case 201:
        return Customer.fromJson(response.body).id;

      case 401:
        throw Exception("unauthorized: ${response.body}");

      case 422:

      default:
        throw Exception("ERROR: ${response.body}");
    }
  }

  @override
  Future<Customer> getCustomerDetails(String id) async {
    final http.Response response =
        await http.get(Uri.parse(customersUri + "/" + id), headers: headers);

    switch (response.statusCode) {
      case 200:
        return Customer.fromJson(response.body);

      case 401:
        throw Exception("unauthorized: ${response.body}");

      case 404:
        throw Exception("customer not found: ${response.body}");

      default:
        throw Exception("ERROR: ${response.body}");
    }
  }
}
