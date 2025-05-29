import 'package:flutter/material.dart';

import '../model/model.dart';
import '../repository/response_repository.dart';
import '../utils/api_response.dart';

class ResponseProvider extends ChangeNotifier {
  final _repository = ResponseRepository();
  ApiResponse<ResponseModel> _responseResponse = ApiResponse.idle();
  ApiResponse<List<ResponseModel>> _allResponsesResponse = ApiResponse.idle();
  ApiResponse<List<ResponseModel>> _responsesByParticipantResponse =
      ApiResponse.idle();
  ApiResponse<List<ResponseModel>> _responsesBySurveyResponse =
      ApiResponse.idle();

  ApiResponse<NormalResponse> _currentResponseResponse = ApiResponse.idle();

  ApiResponse<ResponseModel> get responseResponse => _responseResponse;
  ApiResponse<List<ResponseModel>> get allResponsesResponse =>
      _allResponsesResponse;
  ApiResponse<List<ResponseModel>> get responsesByParticipantResponse =>
      _responsesByParticipantResponse;
  ApiResponse<List<ResponseModel>> get responsesBySurveyResponse =>
      _responsesBySurveyResponse;

  ApiResponse<NormalResponse> get currentResponseResponse =>
      _currentResponseResponse;

  int _selectedResponseId = 0;
  ResponseModel? get selectedResponse => _allResponsesResponse.data?.firstWhere(
      (response) => response.id == _selectedResponseId,
      orElse: () => ResponseModel());
  int get selectedResponseId => _selectedResponseId;
  set selectedResponseId(int id) {
    _selectedResponseId = id;
    notifyListeners();
  }

  Future<void> fetchResponse(String responseId) async {
    _responseResponse = ApiResponse.loading();
    notifyListeners();
    _responseResponse = await _repository.getResponse(responseId);
    notifyListeners();
  }

  Future<void> fetchAllResponses({bool isRefresh = false}) async {
    if (!isRefresh &&
        (_allResponsesResponse.isLoading || _allResponsesResponse.isSuccess)) {
      return;
    }
    _allResponsesResponse = ApiResponse.loading();
    notifyListeners();
    _allResponsesResponse = await _repository.getAllResponses();
    notifyListeners();
  }

  Future<void> fetchResponsesByParticipant(String participantId,
      {bool isRefresh = false}) async {
    if (!isRefresh &&
        (_responsesByParticipantResponse.isLoading ||
            _responsesByParticipantResponse.isSuccess)) {
      return;
    }
    _responsesByParticipantResponse = ApiResponse.loading();
    notifyListeners();
    _responsesByParticipantResponse =
        await _repository.getResponsesByParticipant(participantId);
    notifyListeners();
  }

  Future<void> fetchResponsesBySurvey(String surveyId,
      {bool isRefresh = false}) async {
    if (!isRefresh &&
        (_responsesBySurveyResponse.isLoading ||
            _responsesBySurveyResponse.isSuccess)) {
      return;
    }
    _responsesBySurveyResponse = ApiResponse.loading();
    notifyListeners();
    _responsesBySurveyResponse =
        await _repository.getResponsesBySurvey(surveyId);
    notifyListeners();
  }

  Future<void> createResponse(ResponseModel responseData) async {
    _currentResponseResponse = ApiResponse.loading();
    notifyListeners();

    _currentResponseResponse = await _repository.createResponse(responseData);
    if (_currentResponseResponse.isSuccess) {
      await fetchAllResponses(isRefresh: true);
    }
    notifyListeners();
  }

  Future<void> createResponseBulk(List<ResponseModel> responseData) async {
    _currentResponseResponse = ApiResponse.loading();
    notifyListeners();
    ApiResponse<NormalResponse> r = ApiResponse.loading();
    for (var response in responseData) {
      r = await _repository.createResponse(response);
      if (!r.isSuccess) {
        _currentResponseResponse = r;
        break;
      }
    }
    _currentResponseResponse = r;
    notifyListeners();
    if (_currentResponseResponse.isSuccess) {
      await fetchAllResponses(isRefresh: true);
    }
  }

  Future<void> updateResponse(ResponseModel responseData) async {
    _currentResponseResponse = ApiResponse.loading();
    notifyListeners();

    _currentResponseResponse = await _repository.updateResponse(responseData);
    if (_currentResponseResponse.isSuccess) {
      await fetchAllResponses(isRefresh: true);
    }
    notifyListeners();
  }

  Future<void> deleteResponse(String id) async {
    _currentResponseResponse = ApiResponse.loading();
    notifyListeners();

    _currentResponseResponse = await _repository.deleteResponse(id);
    if (_currentResponseResponse.isSuccess) {
      await fetchAllResponses(isRefresh: true);
    }
    notifyListeners();
  }
}
