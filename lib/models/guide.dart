class Guide {
  final String id;
  final String name;
  final String city;
  final String image;
  final double rating;
  final int reviews;
  final int pricePerDay;
  final List<String> languages;
  final List<String> specialties;
  final String about;

  const Guide({
    required this.id,
    required this.name,
    required this.city,
    required this.image,
    required this.rating,
    required this.reviews,
    required this.pricePerDay,
    required this.languages,
    required this.specialties,
    required this.about,
  });
}
