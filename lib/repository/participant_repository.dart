import '../model/model.dart';
import '../utils/utlis.dart';

class ParticipantRepository {
  static final ParticipantRepository _instance =
      ParticipantRepository._internal();
  factory ParticipantRepository() => _instance;
  ParticipantRepository._internal();

  // fetch all participants with pagination
  Future<ApiResponse<ParticipantPagination>> getAllParticipantsWithPagination(
      int page) async {
    final response = await ApiHelper.get<Map<String, dynamic>>(
        getPageUrl(epParticipantPage, page));
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(
          ParticipantPagination.fromJson(response.data!));
    }
    return ApiResponse.error(response.error!);
  }

  // fetch participant by id
  Future<ApiResponse<Participant>> getParticipant(String id) async {
    final response =
        await ApiHelper.get<Map<String, dynamic>>("$epParticipantById/$id");
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(Participant.fromJson(response.data!));
    }
    return ApiResponse.error(response.error!);
  }

  // fetch all participants
  Future<ApiResponse<List<Participant>>> getAllParticipants() async {
    final response = await ApiHelper.get<List<dynamic>>(epParticipant);
    if (response.isSuccess && response.data != null) {
      final participants = response.data!
          .map((json) => Participant.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(participants);
    }
    return ApiResponse.error(response.error!);
  }

  // fetch participants by person
  Future<ApiResponse<List<Participant>>> getParticipantsByPerson(
      String personId) async {
    final response =
        await ApiHelper.get<List<dynamic>>("$epParticipantByPerson/$personId");
    if (response.isSuccess && response.data != null) {
      final participants = response.data!
          .map((json) => Participant.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(participants);
    }
    return ApiResponse.error(response.error!);
  }

  // create participant
  Future<ApiResponse<NormalResponse>> createParticipant(int personId) async {
    final Participant newParticipant = Participant(
      person: Person(id: personId),
    );
    final response = await ApiHelper.post<Map<String, dynamic>>(
        epParticipant, newParticipant.toJson());
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(NormalResponse(
        isSuccess: response.isSuccess,
        message: "Participant created successfully",
      ));
    }
    return ApiResponse.error(response.error!);
  }

  // update participant
  Future<ApiResponse<NormalResponse>> updateParticipant(
      Participant participant) async {
    final response = await ApiHelper.put<Map<String, dynamic>>(
        epParticipant, participant.toJson());
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(NormalResponse(
        isSuccess: response.isSuccess,
        message: "Participant updated successfully",
      ));
    }
    return ApiResponse.error(response.error!);
  }

  // delete participant
  Future<ApiResponse<NormalResponse>> deleteParticipant(String id) async {
    final response = await ApiHelper.get<Map<String, dynamic>>(
        getDeleteUrl(epParticipantDelete, id));
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(NormalResponse(
        isSuccess: response.isSuccess,
        message: "Participant deleted successfully",
      ));
    }
    return ApiResponse.error(response.error!);
  }
}
