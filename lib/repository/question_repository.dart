import 'dart:developer';

import '../model/model.dart';
import '../utils/utlis.dart';

class QuestionRepository {
  static final QuestionRepository _instance = QuestionRepository._internal();
  factory QuestionRepository() => _instance;
  QuestionRepository._internal();

  // fetch question  survey by id
  Future<ApiResponse<List<Question>>> fetchQuestionBySurvey(String id) async {
    final response =
        await ApiHelper.get<List<dynamic>>('$epQuestionBySurvey/$id');
    if (response.isSuccess && response.data != null) {
      final questions = response.data!
          .map((json) => Question.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(questions);
    }
    return ApiResponse.error(response.error!);
  }

  // fetch question by id
  Future<ApiResponse<Question>> fetchQuestion(String id) async {
    final response =
        await ApiHelper.get<Map<String, dynamic>>('$epQuestionById/$id');
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(Question.fromJson(response.data!));
    }
    return ApiResponse.error(response.error!);
  }

  //fetch all questions
  Future<ApiResponse<List<Question>>> getAllQuestions() async {
    final response = await ApiHelper.get<List<dynamic>>(epQuestion);
    if (response.isSuccess && response.data != null) {
      final questions = response.data!
          .map((json) => Question.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(questions);
    }
    return ApiResponse.error(response.error!);
  }

  // create question
  Future<ApiResponse<Question>> createQuestion(Question question) async {
    log(question.toJson().toString(), name: "createQuestion");
    final response = await ApiHelper.post<Map<String, dynamic>>(
        epQuestion, question.toJson());

    if (response.isSuccess && response.data != null) {
     
      return ApiResponse.success(Question.fromJson(response.data!));
    }
    return ApiResponse.error(response.error!);
  }

  // update question
  Future<ApiResponse<Question>> updateQuestion(Question question) async {
    log(question.toJson().toString(), name: "updateQuestion");
    final response = await ApiHelper.put<Map<String, dynamic>>(
        epQuestion, question.toJson());
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(Question.fromJson(response.data!));
    }
    return ApiResponse.error(response.error!);
  }

  // delete question
  Future<ApiResponse<NormalResponse>> deleteQuestion(String id) async {
    final response =
        await ApiHelper.get<Map<String, dynamic>>('$epQuestionDelete/$id');
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(NormalResponse(
        isSuccess: response.isSuccess,
        message: "Question deleted successfully",
      ));
    }
    return ApiResponse.error(response.error!);
  }
}
