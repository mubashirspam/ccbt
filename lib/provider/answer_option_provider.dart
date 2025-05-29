import 'package:flutter/material.dart';
import '../model/model.dart';
import '../repository/answer_option_repository.dart';
import '../utils/api_response.dart';

class AnswerOptionProvider extends ChangeNotifier {
  final _repository = AnswerOptionRepository();

  ApiResponse<AnswerOption> _optionResponse = ApiResponse.idle();
  ApiResponse<List<AnswerOption>> _allOptionsResponse = ApiResponse.idle();
  ApiResponse<NormalResponse> _currentOptionResponse = ApiResponse.idle();
  ApiResponse<List<AnswerOption>> _optionsByQuestionResponse =
      ApiResponse.idle();

  // Template related responses
  ApiResponse<AnswerOptionTemplate> _templateResponse = ApiResponse.idle();
  ApiResponse<List<AnswerOptionTemplateItem>> _allTemplatesResponse =
      ApiResponse.idle();
  ApiResponse<NormalResponse> _currentTemplateResponse = ApiResponse.idle();

  ApiResponse<AnswerOption> get optionResponse => _optionResponse;
  ApiResponse<List<AnswerOption>> get allOptionsResponse => _allOptionsResponse;
  ApiResponse<NormalResponse> get currentOptionResponse =>
      _currentOptionResponse;
  ApiResponse<List<AnswerOption>> get optionsByQuestionResponse =>
      _optionsByQuestionResponse;
  AnswerOption? get currentOption => _optionResponse.data;

  // Template getters
  ApiResponse<AnswerOptionTemplate> get templateResponse => _templateResponse;
  ApiResponse<List<AnswerOptionTemplateItem>> get allTemplatesResponse =>
      _allTemplatesResponse;
  ApiResponse<NormalResponse> get currentTemplateResponse =>
      _currentTemplateResponse;

  Future<void> fetchAnswerOption(String optionId) async {
    _optionResponse = ApiResponse.loading();
    notifyListeners();
    _optionResponse = await _repository.getAnswerOption(optionId);
    notifyListeners();
  }

  Future<List<AnswerOption>?> fetchAnswerOptionByQuestion(String questionId,
      {bool isDuplicate = false}) async {
    _optionsByQuestionResponse = ApiResponse.loading();
    notifyListeners();
    _optionsByQuestionResponse =
        await _repository.getAllAnswerOptionsByQuestion(questionId);

    if (isDuplicate && _optionsByQuestionResponse.data?.isNotEmpty == true) {
      return _optionsByQuestionResponse.data;
    }
    notifyListeners();
    return null;
  }

  // ==================== Template Methods ====================

  // Fetch a specific template by ID
  Future<void> fetchTemplate(String templateId) async {
    _templateResponse = ApiResponse.loading();
    notifyListeners();
    _templateResponse = await _repository.getAnswerOptionTemplate(templateId);
    notifyListeners();
  }

  // Fetch all templates
  Future<void> fetchAllTemplates() async {
    _allTemplatesResponse = ApiResponse.loading();
    notifyListeners();
    _allTemplatesResponse = await _repository.getAllAnswerOptionTemplates();
    notifyListeners();
  }

  // Create a new template
  Future<bool> createTemplate(AnswerOptionTemplate template) async {
    _currentTemplateResponse = ApiResponse.loading();
    notifyListeners();
    _currentTemplateResponse =
        await _repository.createAnswerOptionTemplate(template);
    notifyListeners();
    return _currentTemplateResponse.isSuccess;
  }

  // Update an existing template
  Future<bool> updateTemplate(AnswerOptionTemplate template) async {
    _currentTemplateResponse = ApiResponse.loading();
    notifyListeners();
    _currentTemplateResponse =
        await _repository.updateAnswerOptionTemplate(template);
    notifyListeners();
    return _currentTemplateResponse.isSuccess;
  }

  // Delete a template
  Future<bool> deleteTemplate(String templateId) async {
    _currentTemplateResponse = ApiResponse.loading();
    notifyListeners();
    _currentTemplateResponse =
        await _repository.deleteAnswerOptionTemplate(templateId);
    notifyListeners();
    return _currentTemplateResponse.isSuccess;
  }

  Future<void> fetchAllAnswerOptions() async {
    _allOptionsResponse = ApiResponse.loading();
    notifyListeners();
    _allOptionsResponse = await _repository.getAllAnswerOptions();
    notifyListeners();
  }

  Future<void> createAnswerOption(AnswerOption option) async {
    _currentOptionResponse = ApiResponse.loading();
    notifyListeners();
    _currentOptionResponse = await _repository.createAnswerOption(option);
    notifyListeners();
    fetchAnswerOptionByQuestion(option.question!.id.toString());
  }

  Future<void> updateAnswerOption(AnswerOption option) async {
    _currentOptionResponse = ApiResponse.loading();
    notifyListeners();
    _currentOptionResponse = await _repository.updateAnswerOption(option);
    notifyListeners();
    fetchAnswerOptionByQuestion(option.question!.id.toString());
  }

  Future<void> deleteAnswerOption(String optionId, String questionId) async {
    _currentOptionResponse = ApiResponse.loading();
    notifyListeners();
    _currentOptionResponse = await _repository.deleteAnswerOption(optionId);

    notifyListeners();
    fetchAnswerOptionByQuestion(questionId);
  }

  Future<void> postAnswerOptionFromTemplate(
      String templateId, String questionId) async {
    _currentOptionResponse = ApiResponse.loading();
    notifyListeners();
    _currentOptionResponse =
        await _repository.postAnswerOptionFromTemplate(templateId, questionId);
    notifyListeners();
    fetchAnswerOptionByQuestion(questionId);
  }
}
