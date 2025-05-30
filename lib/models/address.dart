class Address {
  final int? addressId;
  final int? userId;
  final String street;
  final String city;
  final String country;
  final String? state;
  final String? postalCode;
  final String? phone;
  final bool isDefault;

  Address({
    this.addressId,
    this.userId,
    required this.street,
    required this.city,
    required this.country,
    this.state,
    this.postalCode,
    this.phone,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressId: json['address_id'],
      userId: json['user_id'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postal_code'],
      phone: json['phone'],
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'street': street,
      'city': city,
      'country': country,
      'is_default': isDefault,
    };

    // Only include optional fields if they are not null
    if (state != null) data['state'] = state;
    if (postalCode != null) data['postal_code'] = postalCode;
    if (phone != null) data['phone'] = phone;

    return data;
  }
}
