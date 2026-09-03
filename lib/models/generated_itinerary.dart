class GeneratedItinerary {
  const GeneratedItinerary({
    required this.summary,
    required this.days,
    required this.matchedGuides,
    required this.aiProvider,
  });

  final String summary;
  final List<ItineraryDay> days;
  final List<MatchedGuide> matchedGuides;
  final String aiProvider;

  factory GeneratedItinerary.fromJson(Map<String, dynamic> json) {
    return GeneratedItinerary(
      summary: json['summary']?.toString() ?? '',
      days: (json['days'] as List<dynamic>? ?? [])
          .map((item) => ItineraryDay.fromJson(item as Map<String, dynamic>))
          .toList(),
      matchedGuides: (json['matchedGuides'] as List<dynamic>? ?? [])
          .map((item) => MatchedGuide.fromJson(item as Map<String, dynamic>))
          .toList(),
      aiProvider: json['aiProvider']?.toString() ?? 'unknown',
    );
  }
}

class ItineraryDay {
  const ItineraryDay({
    required this.day,
    required this.title,
    required this.morning,
    required this.afternoon,
    required this.evening,
    required this.notes,
  });

  final int day;
  final String title;
  final String morning;
  final String afternoon;
  final String evening;
  final List<String> notes;

  factory ItineraryDay.fromJson(Map<String, dynamic> json) {
    return ItineraryDay(
      day: int.tryParse(json['day']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      morning: json['morning']?.toString() ?? '',
      afternoon: json['afternoon']?.toString() ?? '',
      evening: json['evening']?.toString() ?? '',
      notes: (json['notes'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}

class MatchedGuide {
  const MatchedGuide({
    required this.id,
    required this.name,
    required this.city,
    required this.specialties,
    required this.languages,
    required this.rating,
    required this.reviews,
    required this.pricePerDay,
    required this.matchScore,
    required this.matchReasons,
    required this.available,
    required this.image,
    required this.about,
  });

  final int id;
  final String name;
  final String city;
  final List<String> specialties;
  final List<String> languages;
  final double rating;
  final int reviews;
  final int pricePerDay;
  final int matchScore;
  final List<String> matchReasons;
  final bool available;
  final String image;
  final String about;

  factory MatchedGuide.fromJson(Map<String, dynamic> json) {
    return MatchedGuide(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      specialties: _stringList(json['specialties']),
      languages: _stringList(json['languages']),
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0,
      reviews: int.tryParse(json['reviews']?.toString() ?? '') ?? 0,
      pricePerDay: int.tryParse(json['pricePerDay']?.toString() ?? '') ?? 0,
      matchScore: int.tryParse(json['matchScore']?.toString() ?? '') ?? 0,
      matchReasons: _stringList(json['matchReasons']),
      available: json['available'] == true,
      image: json['image']?.toString() ?? '',
      about: json['about']?.toString() ?? '',
    );
  }
}

List<String> _stringList(dynamic value) {
  return (value as List<dynamic>? ?? [])
      .map((item) => item.toString())
      .toList();
}
