import 'package:flutter/material.dart';
import '../model/model.dart';
import '../repository/question_repository.dart';
import '../utils/api_response.dart';

class QuestionProvider extends ChangeNotifier {
  final _repository = QuestionRepository();

  ApiResponse<Question> _questionResponse = ApiResponse.idle();
  ApiResponse<List<Question>> _allQuestionsResponse = ApiResponse.idle();
  ApiResponse<List<QuestionModel>> _questionsBySurveyResponse =
      ApiResponse.idle();
  ApiResponse<Question> _currentQuestionResponse = ApiResponse.idle();

  ApiResponse<NormalResponse> _deleteQuestionResponse = ApiResponse.idle();

  ApiResponse<NormalResponse> get deleteQuestionResponse =>
      _deleteQuestionResponse;

  ApiResponse<Question> get questionResponse => _questionResponse;
  ApiResponse<List<Question>> get allQuestionsResponse => _allQuestionsResponse;
  ApiResponse<List<QuestionModel>> get questionsBySurveyResponse =>
      _questionsBySurveyResponse;
  ApiResponse<Question> get currentQuestionResponse => _currentQuestionResponse;
  Question? get currentQuestion => _questionResponse.data;

  QuestionModel? get selectedQuestion {
    // Check if data exists
    final questions = _questionsBySurveyResponse.data;
    if (questions == null) return null;

    // Search top-level questions
    try {
      return questions
          .firstWhere((question) => question.id == _selectedQuestionId);
    } on StateError {
      // Search all nested levels using a recursive helper
      for (final question in questions) {
        final found = _findQuestionInHierarchy(question);
        if (found != null) return found;
      }
    }

    return null;
  }

// Helper method to search question hierarchy
  QuestionModel? _findQuestionInHierarchy(QuestionModel question) {
    // Check current question
    if (question.id == _selectedQuestionId) return question;

    // Check children recursively
    if (question.children != null) {
      for (final child in question.children!) {
        final found = _findQuestionInHierarchy(child);
        if (found != null) return found;
      }
    }

    return null;
  }

  int _selectedQuestionId = 0;
  int get selectedQuestionId => _selectedQuestionId;
  set selectedQuestionId(int id) {
    _selectedQuestionId = id;
    notifyListeners();
  }

  int _selectedParentQuestionId = 0;
  int get selectedParentQuestionId => _selectedParentQuestionId;
  set selectedParentQuestionId(int id) {
    _selectedParentQuestionId = id;
    _selectedQuestionId = id;
    notifyListeners();
  }

  int _selectedChildQuestionId = 0;
  int get selectedChildQuestionId => _selectedChildQuestionId;
  set selectedChildQuestionId(int id) {
    _selectedChildQuestionId = id;
    _selectedQuestionId = id;
    notifyListeners();
  }

  Future<void> fetchQuestion(String questionId) async {
    _questionResponse = ApiResponse.loading();
    notifyListeners();
    _questionResponse = await _repository.fetchQuestion(questionId);
    notifyListeners();
  }

  Future<void> fetchQuestionBySurvey(String surveyId) async {
    _questionsBySurveyResponse = ApiResponse.loading();
    notifyListeners();
    final data = await _repository.fetchQuestionBySurvey(surveyId);
    if (data.isSuccess) {
      final convertedData = convertQuestionsToModel(data.data ?? []);
      _questionsBySurveyResponse = ApiResponse.success(convertedData);
    } else {
      _questionsBySurveyResponse =
          ApiResponse.error(data.error ?? 'Unknown error');
    }
    notifyListeners();
  }

  Future<void> fetchAllQuestions() async {
    _allQuestionsResponse = ApiResponse.loading();
    notifyListeners();
    _allQuestionsResponse = await _repository.getAllQuestions();
    notifyListeners();
  }

  Future<void> createQuestion(Question question) async {
    _currentQuestionResponse = ApiResponse.loading();
    notifyListeners();
    final response = await _repository.createQuestion(question);
    _currentQuestionResponse = response;
    fetchQuestionBySurvey(question.survey!.id.toString());
    notifyListeners();
  }

  Future<void> updateQuestion(Question question) async {
    _currentQuestionResponse = ApiResponse.loading();
    notifyListeners();
    _currentQuestionResponse = await _repository.updateQuestion(question);
    notifyListeners();
    fetchQuestionBySurvey(question.survey!.id.toString());
  }

  Future<void> deleteQuestion(String questionId, String surveyId) async {
    _deleteQuestionResponse = ApiResponse.loading();
    notifyListeners();
    _deleteQuestionResponse = await _repository.deleteQuestion(questionId);
    notifyListeners();
    fetchQuestionBySurvey(surveyId);
  }
}

List<QuestionModel> convertQuestionsToModel(List<Question> questions) {
  // Map to store all questions by ID
  Map<int, QuestionModel> questionMap = {};
  // List to store root questions
  List<QuestionModel> rootQuestions = [];

  // First pass: Convert all Questions to QuestionModels
  for (Question question in questions) {
    QuestionModel model = QuestionModel(
      id: question.id,
      surveyId: question.survey?.id,
      questionType: question.questionType != null
          ? QuestionType(
              id: question.questionType!.id,
              questionType: question.questionType!.questionType,
            )
          : null,
      text: question.text,
      children: [], // Initialize empty children list
    );

    if (question.id != null) {
      questionMap[question.id!] = model;
    }

    // If no parent question, add to root questions
    if (question.parentQuestion == null) {
      rootQuestions.add(model);
    }
  }

  // Second pass: Assign children to their parents
  for (Question question in questions) {
    if (question.parentQuestion != null && question.id != null) {
      int parentId = question.parentQuestion!.id!;
      int childId = question.id!;

      if (questionMap.containsKey(parentId) &&
          questionMap.containsKey(childId)) {
        questionMap[parentId]!.children!.add(questionMap[childId]!);
      }
    }
  }

  return rootQuestions;
}
