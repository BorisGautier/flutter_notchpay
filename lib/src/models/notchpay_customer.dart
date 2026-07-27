import 'notchpay_address.dart';

/// A NotchPay customer (`cus_...`).
///
/// See https://developers.notchpay.co/api/customer
class NotchPayCustomer {
  /// Creates a customer. Use [NotchPayCustomer.fromJson] to parse an API
  /// response instead.
  const NotchPayCustomer({
    this.reference,
    required this.name,
    this.email,
    this.phone,
    this.description,
    this.address,
    this.shipping,
    this.locked = false,
    this.createdAt,
    this.updatedAt,
    this.raw = const {},
  });

  /// Parses a customer from a decoded NotchPay API JSON response.
  factory NotchPayCustomer.fromJson(Map<String, dynamic> json) {
    return NotchPayCustomer(
      reference: (json['reference'] ?? json['id']) as String?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      description: json['description'] as String?,
      address: json['address'] is Map<String, dynamic>
          ? NotchPayAddress.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      shipping: json['shipping'] is Map<String, dynamic>
          ? NotchPayAddress.fromJson(json['shipping'] as Map<String, dynamic>)
          : null,
      locked: json['locked'] as bool? ?? false,
      createdAt: DateTime.tryParse('${json['created_at']}'),
      updatedAt: DateTime.tryParse('${json['updated_at']}'),
      raw: json,
    );
  }

  /// Unique customer reference, e.g. `cus.xxLZjWte8fdc8YNY`.
  final String? reference;

  /// The customer's full name.
  final String name;

  /// The customer's email address, if provided.
  final String? email;

  /// The customer's phone number, if provided.
  final String? phone;

  /// A free-form note about this customer.
  final String? description;

  /// The customer's billing address, if provided.
  final NotchPayAddress? address;

  /// The customer's shipping address, if provided.
  final NotchPayAddress? shipping;

  /// Whether the customer has been blocked from making payments.
  final bool locked;

  /// When this customer was created.
  final DateTime? createdAt;

  /// When this customer was last updated.
  final DateTime? updatedAt;

  /// The untouched JSON payload returned by the API, for advanced use cases.
  final Map<String, dynamic> raw;

  /// Serializes this customer into the payload expected by the create/
  /// update customer endpoints.
  Map<String, dynamic> toJson() => {
        'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (description != null) 'description': description,
        if (address != null) 'address': address!.toJson(),
        if (shipping != null) 'shipping': shipping!.toJson(),
      };
}
