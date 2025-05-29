import 'package:flutter/material.dart';

import '../model/model.dart';
import '../repository/survey_repository.dart';
import '../utils/api_response.dart';

class SurveyProvider extends ChangeNotifier {
  final _repository = SurveyRepository();
  ApiResponse<Survey> _surveyResponse = ApiResponse.idle();

  ApiResponse<List<Survey>> _allSurveysResponse = ApiResponse.idle();

  ApiResponse<NormalResponse> _currentSurveyResponse = ApiResponse.idle();

  ApiResponse<Survey> get surveyResponse => _surveyResponse;
  ApiResponse<List<Survey>> get allSurveysResponse => _allSurveysResponse;
  ApiResponse<NormalResponse> get currentSurveyResponse =>
      _currentSurveyResponse;
  Survey? get currentSurvey => _surveyResponse.data;

  int _selectedSurveyId = 0;
  Survey? get selectedSurvey => _allSurveysResponse.data?.firstWhere((survey) => survey.id == _selectedSurveyId);
  int get selectedSurveyId => _selectedSurveyId;
  set selectedSurveyId(int id) {
    _selectedSurveyId = id;
    notifyListeners();
  }

  Future<void> fetchSurvey(String surveyId) async {
    _surveyResponse = ApiResponse.loading();
    notifyListeners();
    _surveyResponse = await _repository.getSurvey(surveyId);
    notifyListeners();
  }

  Future<void> fetchAllSurveys({bool isRefresh = false}) async {
    if (!isRefresh &&
        (_allSurveysResponse.isLoading || _allSurveysResponse.isSuccess)) {
      return;
    }
    _allSurveysResponse = ApiResponse.loading();
    notifyListeners();
    _allSurveysResponse = await _repository.getAllSurveys();
    notifyListeners();
  }

  Future<void> createSurvey(Survey survey) async {
    _currentSurveyResponse = ApiResponse.loading();
    notifyListeners();

    _currentSurveyResponse = await _repository.createSurvey(survey);

    notifyListeners();
    fetchAllSurveys(isRefresh: true);
  }

  Future<void> updateSurvey(Survey survey) async {
    _currentSurveyResponse = ApiResponse.loading();
    notifyListeners();
    _currentSurveyResponse = await _repository.updateSurvey(survey);
    notifyListeners();
    fetchAllSurveys(isRefresh: true);
  }

  Future<void> deleteSurvey(String surveyId) async {
    _currentSurveyResponse = ApiResponse.loading();
    notifyListeners();
    _currentSurveyResponse = await _repository.deleteSurvey(surveyId);
    notifyListeners();
    fetchAllSurveys(isRefresh: true);
  }
}
