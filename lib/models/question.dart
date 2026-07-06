class Question {
  final String id;
  final String title;
  final List<String> options;

  /// true = multiple options can be selected
  /// false = only one option
  final bool multiple;

  const Question({
    required this.id,
    required this.title,
    required this.options,
    this.multiple = false,
  });
}
