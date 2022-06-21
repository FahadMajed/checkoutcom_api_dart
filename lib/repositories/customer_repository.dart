import 'package:checkout_api/utils/api_base.dart';
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
  static const _customers = "customers";
  final ApiBase apiBase;

  HttpCustomersRepository({required this.headers, required this.apiBase});

  @override
  Future<String?> createCustomer(Customer customer) async {
    //
    final Map<String, dynamic> responseMap = await apiBase.call(RESTOption.post,
        resource: _customers, headers: headers, body: customer.toJson());

    return Customer.fromMap(responseMap).id;
  }

  @override
  Future<Customer> getCustomerDetails(String id) async {
    final Map<String, dynamic> responseMap = await apiBase.call(
      RESTOption.get,
      resource: _customers + "/" + id,
      headers: headers,
    );

    return Customer.fromMap(responseMap);
  }
}
