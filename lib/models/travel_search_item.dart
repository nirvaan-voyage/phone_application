class TravelSearchItem {
  const TravelSearchItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.provider,
    this.origin,
    this.destination,
    this.date,
    this.price,
    this.currency,
    this.bookingUrl,
    this.imageUrl,
  });

  final String id;
  final String type;
  final String title;
  final String subtitle;
  final String provider;
  final String? origin;
  final String? destination;
  final String? date;
  final String? price;
  final String? currency;
  final String? bookingUrl;
  final String? imageUrl;

  factory TravelSearchItem.fromJson(Map<String, dynamic> json) {
    return TravelSearchItem(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      provider: json['provider']?.toString() ?? '',
      origin: _nullableString(json['origin']),
      destination: _nullableString(json['destination']),
      date: _nullableString(json['date']),
      price: _nullableString(json['price']),
      currency: _nullableString(json['currency']),
      bookingUrl: _nullableString(json['bookingUrl']),
      imageUrl: _nullableString(json['imageUrl']),
    );
  }
}

String? _nullableString(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}
