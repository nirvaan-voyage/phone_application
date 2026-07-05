import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';
import '../core/data/questionnaire_data.dart';

class QuestionnaireState {
  final String destination;
  final int currentQuestion;
  final Map<String, String> answers;

  const QuestionnaireState({
    this.destination = "",
    this.currentQuestion = 0,
    this.answers = const {},
  });

  QuestionnaireState copyWith({
    String? destination,
    int? currentQuestion,
    Map<String, String>? answers,
  }) {
    return QuestionnaireState(
      destination: destination ?? this.destination,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      answers: answers ?? this.answers,
    );
  }
}

class QuestionnaireNotifier extends StateNotifier<QuestionnaireState> {
  QuestionnaireNotifier() : super(const QuestionnaireState());

  /// Save destination
  void setDestination(String destination) {
    state = state.copyWith(destination: destination);
  }

  /// Save answer for current question
  void saveAnswer(String questionId, String answer) {
    final updatedAnswers = Map<String, String>.from(state.answers);

    updatedAnswers[questionId] = answer;

    state = state.copyWith(
      answers: updatedAnswers,
    );
  }

  /// Next question
  void nextQuestion() {
    if (state.currentQuestion < questionnaireQuestions.length - 1) {
      state = state.copyWith(
        currentQuestion: state.currentQuestion + 1,
      );
    }
  }

  /// Previous question
  void previousQuestion() {
    if (state.currentQuestion > 0) {
      state = state.copyWith(
        currentQuestion: state.currentQuestion - 1,
      );
    }
  }

  /// Restart questionnaire
  void reset() {
    state = const QuestionnaireState();
  }
}

final questionnaireProvider =
    StateNotifierProvider<QuestionnaireNotifier, QuestionnaireState>(
  (ref) => QuestionnaireNotifier(),
);
