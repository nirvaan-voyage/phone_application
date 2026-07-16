class Flight {
  final String id;
  final String airline;
  final String departure;
  final String arrival;
  final String price;
  final String currency;
  final String flightNumber;
  final String status;

  Flight({
    required this.id,
    required this.airline,
    required this.departure,
    required this.arrival,
    required this.price,
    required this.currency,
    required this.flightNumber,
    required this.status,
  });

  // Factory constructor to parse the JSON safely
  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id']?.toString() ?? '',
      airline: json['airline'] ?? 'Unknown Airline',
      departure: json['departure'] ?? '',
      arrival: json['arrival'] ?? '',
      price: json['price']?.toString() ?? '0.00',
      currency: json['currency'] ?? 'INR',
      flightNumber: json['flightNumber'] ?? json['flight_number'] ?? 'N/A',
      status: json['status']?.toString().toLowerCase() ?? 'unknown',
    );
  }
}
