import '../../models/question.dart';

const List<Question> questionnaireQuestions = [
  Question(
    id: "age_group",
    title: "What age group is travelling?",
    options: [
      "Under 18",
      "18 - 25",
      "26 - 35",
      "36 - 50",
      "50+",
    ],
  ),
  Question(
    id: "companions",
    title: "Who are you travelling with?",
    options: [
      "Solo",
      "Partner",
      "Friends",
      "Family",
      "Colleagues",
    ],
  ),
  Question(
    id: "trip_type",
    title: "What type of trip do you want?",
    options: [
      "Adventure",
      "Relaxation",
      "Nature",
      "Cultural",
      "Luxury",
      "Romantic",
    ],
  ),
  Question(
    id: "accommodation",
    title: "What accommodation do you prefer?",
    options: [
      "Hotel",
      "Airbnb",
      "Resort",
      "Homestay",
      "Hostel",
      "Camping",
    ],
  ),
  Question(
    id: "transportation",
    title: "Preferred transportation?",
    options: [
      "Flight",
      "Train",
      "Bus",
      "Self Drive",
      "Bike",
    ],
  ),
  Question(
    id: "food",
    title: "Food preference?",
    options: [
      "Street Food",
      "Local Cuisine",
      "Fine Dining",
      "Vegetarian",
      "Vegan",
      "No Preference",
    ],
  ),
  Question(
    id: "pace",
    title: "Preferred pace of travel?",
    options: [
      "Relaxed",
      "Balanced",
      "Fast-Paced",
    ],
  ),
  Question(
    id: "hidden_gems",
    title: "Do you want hidden gems included?",
    options: [
      "Yes",
      "Maybe",
      "No",
    ],
  ),
  Question(
    id: "guide",
    title: "Would you like a local guide?",
    options: [
      "Yes",
      "No",
      "Only for sightseeing",
    ],
  ),
  Question(
    id: "accessibility",
    title: "Any accessibility requirements?",
    options: [
      "None",
      "Wheelchair Accessible",
      "Senior Friendly",
      "Child Friendly",
    ],
  ),
  Question(
    id: "attractions",
    title: "What attractions interest you the most?",
    multiple: true,
    options: [
      "Historical",
      "Nature",
      "Adventure",
      "Religious",
      "Shopping",
      "Nightlife",
    ],
  ),
  Question(
    id: "activities",
    multiple: true,
    title: "Which activities would you like to experience?",
    options: [
      "Trekking",
      "Boating",
      "Camping",
      "Wildlife Safari",
      "Photography",
      "Shopping",
    ],
  ),
  Question(
    id: "start_time",
    title: "Preferred daily start time?",
    options: [
      "Early Morning",
      "Morning",
      "Afternoon",
      "Flexible",
    ],
  ),
];
