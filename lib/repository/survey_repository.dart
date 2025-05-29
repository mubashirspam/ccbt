
import '../model/model.dart';
import '../utils/utlis.dart';

class SurveyRepository {
  static final SurveyRepository _instance = SurveyRepository._internal();
  factory SurveyRepository() => _instance;
  SurveyRepository._internal();

// fetch survey by id

  Future<ApiResponse<Survey>> getSurvey(String id) async {
    final response = await ApiHelper.get<Map<String, dynamic>>("$epSurveyById/$id");
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(Survey.fromJson(response.data!));
    }
    return ApiResponse.error(response.error!);
  }

  //fetch all surveys

  Future<ApiResponse<List<Survey>>> getAllSurveys() async {
    final response = await ApiHelper.get<List<dynamic>>(epSurvey);
    if (response.isSuccess && response.data != null) {
      final surveys = response.data!
          .map((json) => Survey.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(surveys);
    }
    return ApiResponse.error(response.error!);
  }

  // create survey
  Future<ApiResponse<NormalResponse>> createSurvey(Survey survey) async {
    final response =
        await ApiHelper.post<Map<String, dynamic>>(epSurvey, survey.toJson());
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(NormalResponse(
        isSuccess: response.isSuccess,
        message: "Survey created successfully",
      ));
    }
    return ApiResponse.error(response.error!);
  }

  // update survey
  Future<ApiResponse<NormalResponse>> updateSurvey(Survey survey) async {
    final response = await ApiHelper.put<Map<String, dynamic>>(
        epSurvey, survey.toJson());
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(NormalResponse(
        isSuccess: response.isSuccess,
        message: "Survey updated successfully",
      ));
    }
    return ApiResponse.error(response.error!);
  }

 

  // delete survey
  Future<ApiResponse<NormalResponse>> deleteSurvey(String id) async {
    final response =
        await ApiHelper.get<Map<String, dynamic>>("$epSurveyDelete/$id");
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(NormalResponse(
        isSuccess: response.isSuccess,
        message: "Survey deleted successfully",
      ));
    }
    return ApiResponse.error(response.error!);
  }
}
