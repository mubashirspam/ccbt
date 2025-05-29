import '../model/model.dart';
import '../utils/utlis.dart';

class AnswerOptionRepository {
  static final AnswerOptionRepository _instance =
      AnswerOptionRepository._internal();
  factory AnswerOptionRepository() => _instance;
  AnswerOptionRepository._internal();

  // fetch answer option by id
  Future<ApiResponse<AnswerOption>> getAnswerOption(String id) async {
    final response =
        await ApiHelper.get<Map<String, dynamic>>("$epAnswerOptionById/$id");
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(AnswerOption.fromJson(response.data!));
    }
    return ApiResponse.error(response.error!);
  }

// fetch all answer options by question
  Future<ApiResponse<List<AnswerOption>>> getAllAnswerOptionsByQuestion(
      String questionId) async {
    final response = await ApiHelper.get<List<dynamic>>(
        "$epAnswerOptionByQuestion/$questionId");
    if (response.isSuccess && response.data != null) {
      final options = response.data!
          .map((json) => AnswerOption.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(options);
    }
    return ApiResponse.error(response.error!);
  }

  //fetch all answer options
  Future<ApiResponse<List<AnswerOption>>> getAllAnswerOptions() async {
    final response = await ApiHelper.get<List<dynamic>>(epAnswerOption);
    if (response.isSuccess && response.data != null) {
      final options = response.data!
          .map((json) => AnswerOption.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(options);
    }
    return ApiResponse.error(response.error!);
  }

  // create answer option
  Future<ApiResponse<NormalResponse>> createAnswerOption(
      AnswerOption option) async {
    final response = await ApiHelper.post<Map<String, dynamic>>(
        epAnswerOption, option.toJson());
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(NormalResponse(
        isSuccess: response.isSuccess,
        message: "Answer option created successfully",
      ));
    }
    return ApiResponse.error(response.error!);
  }

  // update answer option
  Future<ApiResponse<NormalResponse>> updateAnswerOption(
      AnswerOption option) async {
    final response = await ApiHelper.put<Map<String, dynamic>>(
        epAnswerOption, option.toJson());
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(NormalResponse(
        isSuccess: response.isSuccess,
        message: "Answer option updated successfully",
      ));
    }
    return ApiResponse.error(response.error!);
  }

  // delete answer option
  Future<ApiResponse<NormalResponse>> deleteAnswerOption(String id) async {
    final response =
        await ApiHelper.get<Map<String, dynamic>>("$epAnswerOptionDelete/$id");
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(NormalResponse(
        isSuccess: response.isSuccess,
        message: "Answer option deleted successfully",
      ));
    }
    return ApiResponse.error(response.error!);
  }

  // ==================== Answer Option Template Methods ====================

  // fetch answer option template by id
  Future<ApiResponse<AnswerOptionTemplate>> getAnswerOptionTemplate(
      String id) async {
    final response = await ApiHelper.get<Map<String, dynamic>>(
        "$epAnswerOptionTemplateById/$id");
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(AnswerOptionTemplate.fromJson(response.data!));
    }
    return ApiResponse.error(response.error!);
  }

  // fetch all answer option templates
  Future<ApiResponse<List<AnswerOptionTemplateItem>>>
      getAllAnswerOptionTemplates() async {
    final response =
        await ApiHelper.get<List<dynamic>>(epAnswerOptionTemplateItem);
    if (response.isSuccess && response.data != null) {
      final templates = response.data!
          .map((json) =>
              AnswerOptionTemplateItem.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(templates);
    }
    return ApiResponse.error(response.error!);
  }

  // create answer option template
  Future<ApiResponse<NormalResponse>> createAnswerOptionTemplate(
      AnswerOptionTemplate template) async {
    final response = await ApiHelper.post<Map<String, dynamic>>(
        epAnswerOptionTemplate, template.toJson());
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(NormalResponse(
        isSuccess: response.isSuccess,
        message: "Answer option template created successfully",
      ));
    }
    return ApiResponse.error(response.error!);
  }

  // update answer option template
  Future<ApiResponse<NormalResponse>> updateAnswerOptionTemplate(
      AnswerOptionTemplate template) async {
    final response = await ApiHelper.put<Map<String, dynamic>>(
        epAnswerOptionTemplate, template.toJson());
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(NormalResponse(
        isSuccess: response.isSuccess,
        message: "Answer option template updated successfully",
      ));
    }
    return ApiResponse.error(response.error!);
  }

  // delete answer option template
  Future<ApiResponse<NormalResponse>> deleteAnswerOptionTemplate(
      String id) async {
    final response = await ApiHelper.get<Map<String, dynamic>>(
        "$epAnswerOptionTemplateDelete/$id");
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(NormalResponse(
        isSuccess: response.isSuccess,
        message: "Answer option template deleted successfully",
      ));
    }
    return ApiResponse.error(response.error!);
  }

  Future<ApiResponse<NormalResponse>> postAnswerOptionFromTemplate(
      String templateId, String questionId) async {
    final url =
        "/AnswerOption/$templateId/ToQuestion/$questionId?questionId=$questionId&templateId=$templateId";
    final response = await ApiHelper.post<Map<String, dynamic>>(url, null);
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(NormalResponse(
        isSuccess: response.isSuccess,
        message: "Answer option created successfully",
      ));
    }
    return ApiResponse.error(response.error!);
  }
}
