/// Describes the customer information to attach to a checkout.
///
/// Only [phone] is required by NotchPay when the customer pays with Mobile
/// Money; provide [email] and [name] as well when you have them, for a
/// better fraud-prevention signal and receipt experience.
class NotchPayCheckoutCustomer {
  /// Creates customer information for a checkout. At least one of [name],
  /// [email] or [phone] must be provided.
  const NotchPayCheckoutCustomer({
    this.name,
    this.email,
    this.phone,
  }) : assert(
          name != null || email != null || phone != null,
          'Provide at least one of name, email or phone',
        );

  /// The customer's full name.
  final String? name;

  /// The customer's email address.
  final String? email;

  /// The customer's phone number, required to pay with Mobile Money.
  final String? phone;

  /// Serializes this customer into the payload expected by the initialize
  /// payment endpoint.
  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      };
}

/// Everything needed to start a checkout with [NotchPay.checkout].
class NotchPayCheckoutRequest {
  /// Creates a checkout request. [amount] must be greater than zero.
  const NotchPayCheckoutRequest({
    required this.amount,
    required this.currency,
    this.description,
    this.customer,
    this.reference,
    this.metadata = const {},
  }) : assert(amount > 0, 'amount must be greater than zero');

  /// The amount to charge, in the currency's major unit (e.g. `1500` for
  /// 1500 XAF).
  final double amount;

  /// ISO 4217 currency code, e.g. `XAF`.
  final String currency;

  /// A short description shown to the customer and merchant, e.g.
  /// `Order #4831`.
  final String? description;

  /// Information about the paying customer.
  final NotchPayCheckoutCustomer? customer;

  /// An optional merchant-defined idempotency reference for this
  /// transaction.
  final String? reference;

  /// Free-form metadata attached to the transaction, echoed back on webhooks
  /// and when fetching the transaction later.
  final Map<String, dynamic> metadata;

  /// Serializes this request into the payload expected by the initialize
  /// payment endpoint.
  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currency': currency,
        if (description != null) 'description': description,
        if (customer != null) 'customer': customer!.toJson(),
        if (reference != null) 'reference': reference,
        if (metadata.isNotEmpty) 'metadata': metadata,
      };
}
