/// A postal address, used for a [NotchPayCustomer]'s billing or shipping
/// information.
class NotchPayAddress {
  /// Creates an address. Use [NotchPayAddress.fromJson] to parse an API
  /// response instead.
  const NotchPayAddress({
    this.country,
    this.city,
    this.addressLine1,
    this.addressLine2,
  });

  /// Parses an address from a decoded NotchPay API JSON response.
  factory NotchPayAddress.fromJson(Map<String, dynamic> json) {
    return NotchPayAddress(
      country: json['country'] as String?,
      city: json['city'] as String?,
      addressLine1: json['address_line1'] as String?,
      addressLine2: json['address_line2'] as String?,
    );
  }

  /// ISO 3166-1 alpha-2 country code, e.g. `cm`.
  final String? country;

  /// The city name.
  final String? city;

  /// The primary street address line.
  final String? addressLine1;

  /// An optional secondary address line (apartment, suite, ...).
  final String? addressLine2;

  /// Serializes this address into the payload expected by the customer
  /// create/update endpoints.
  Map<String, dynamic> toJson() => {
        if (country != null) 'country': country,
        if (city != null) 'city': city,
        if (addressLine1 != null) 'address_line1': addressLine1,
        if (addressLine2 != null) 'address_line2': addressLine2,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotchPayAddress &&
          runtimeType == other.runtimeType &&
          country == other.country &&
          city == other.city &&
          addressLine1 == other.addressLine1 &&
          addressLine2 == other.addressLine2;

  @override
  int get hashCode => Object.hash(country, city, addressLine1, addressLine2);
}
