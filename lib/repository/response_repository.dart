import '../model/model.dart';
import '../utils/utlis.dart';

class ResponseRepository {
  static final ResponseRepository _instance = ResponseRepository._internal();
  factory ResponseRepository() => _instance;
  ResponseRepository._internal();

  // fetch response by id
  Future<ApiResponse<ResponseModel>> getResponse(String id) async {
    final response = await ApiHelper.get<Map<String, dynamic>>("$epResponseById/$id");
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(ResponseModel.fromJson(response.data!));
    }
    return ApiResponse.error(response.error!);
  }

  // fetch all responses
  Future<ApiResponse<List<ResponseModel>>> getAllResponses() async {
    final response = await ApiHelper.get<List<dynamic>>(epResponse);
    if (response.isSuccess && response.data != null) {
      final responses = response.data!
          .map((json) => ResponseModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(responses);
    }
    return ApiResponse.error(response.error!);
  }

  // fetch responses by participant
  Future<ApiResponse<List<ResponseModel>>> getResponsesByParticipant(String participantId) async {
    final response = await ApiHelper.get<List<dynamic>>("$epResponseByParticipant/$participantId");
    if (response.isSuccess && response.data != null) {
      final responses = response.data!
          .map((json) => ResponseModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(responses);
    }
    return ApiResponse.error(response.error!);
  }

  // fetch responses by survey
  Future<ApiResponse<List<ResponseModel>>> getResponsesBySurvey(String surveyId) async {
    final response = await ApiHelper.get<List<dynamic>>("$epResponseBySurvey/$surveyId");
    if (response.isSuccess && response.data != null) {
      final responses = response.data!
          .map((json) => ResponseModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(responses);
    }
    return ApiResponse.error(response.error!);
  }

  // create response
  Future<ApiResponse<NormalResponse>> createResponse(ResponseModel responseData) async {
    final response =
        await ApiHelper.post<Map<String, dynamic>>(epResponse, responseData.toJson());
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(NormalResponse(
        isSuccess: response.isSuccess,
        message: "Response created successfully",
      ));
    }
    return ApiResponse.error(response.error!);
  }

  // update response
  Future<ApiResponse<NormalResponse>> updateResponse(ResponseModel responseData) async {
    final response = await ApiHelper.put<Map<String, dynamic>>(
        epResponse, responseData.toJson());
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(NormalResponse(
        isSuccess: response.isSuccess,
        message: "Response updated successfully",
      ));
    }
    return ApiResponse.error(response.error!);
  }

  // delete response
  Future<ApiResponse<NormalResponse>> deleteResponse(String id) async {
    final response = await ApiHelper.delete<Map<String, dynamic>>(
        getDeleteUrl(epResponseDelete, id));
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(NormalResponse(
        isSuccess: response.isSuccess,
        message: "Response deleted successfully",
      ));
    }
    return ApiResponse.error(response.error!);
  }

}