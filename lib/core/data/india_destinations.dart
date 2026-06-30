/// Static destination data used by the Explore and Home tabs.
/// Replace with API calls when the destinations endpoint is ready.
class IndiaDestination {
  const IndiaDestination({
    required this.name,
    required this.category,
    required this.rating,
    required this.imageUrl,
    this.description,
  });

  final String name;
  final String category;
  final String rating;
  final String imageUrl;
  final String? description;
}

const List<IndiaDestination> kIndiaDestinations = [
  IndiaDestination(
    name: 'Manali',
    category: 'Mountains',
    rating: '4.9',
    imageUrl: 'assets/images/manali.jpg',
    description: 'Snow-capped peaks, adventure sports, and mountain serenity.',
  ),
  IndiaDestination(
    name: 'Goa',
    category: 'Beaches',
    rating: '4.7',
    imageUrl:
        'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=400',
    description: 'Sun, sand, and vibrant nightlife on India\'s western coast.',
  ),
  IndiaDestination(
    name: 'Hampi',
    category: 'Heritage',
    rating: '4.8',
    imageUrl: 'assets/images/hampi.jpg',
    description: 'Ancient ruins of the Vijayanagara Empire amid boulder landscapes.',
  ),
  IndiaDestination(
    name: 'Ranthambore',
    category: 'Wildlife',
    rating: '4.6',
    imageUrl:
        'https://images.unsplash.com/photo-1561731216-c3a4d99437d5?w=400',
    description: 'Home to Bengal tigers in a stunning national park setting.',
  ),
  IndiaDestination(
    name: 'Varanasi',
    category: 'Spiritual',
    rating: '4.9',
    imageUrl: 'assets/images/Varanasi.jpg',
    description: 'The spiritual capital of India on the banks of the Ganges.',
  ),
  IndiaDestination(
    name: 'Udaipur',
    category: 'Heritage',
    rating: '4.8',
    imageUrl: 'assets/images/udaipur.jpg',
    description: 'The City of Lakes — palaces, gardens, and romantic sunsets.',
  ),
  IndiaDestination(
    name: 'Kerala',
    category: 'Beaches',
    rating: '4.9',
    imageUrl:
        'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?w=600',
    description: 'Backwaters, houseboats, and lush green landscapes.',
  ),
  IndiaDestination(
    name: 'Ladakh',
    category: 'Mountains',
    rating: '4.7',
    imageUrl: 'assets/images/ladakh.jpg',
    description: 'High-altitude desert with dramatic Himalayan scenery.',
  ),
  IndiaDestination(
    name: 'Andaman',
    category: 'Beaches',
    rating: '4.8',
    imageUrl: 'assets/images/Andaman.jpg',
    description: 'Crystal-clear waters and vibrant coral reefs.',
  ),
  IndiaDestination(
    name: 'Spiti',
    category: 'Mountains',
    rating: '4.9',
    imageUrl: 'assets/images/spiti.jpg',
    description: 'Remote Himalayan valley with ancient monasteries.',
  ),
];
