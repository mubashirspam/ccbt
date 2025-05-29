import '../model/model.dart';
import '../utils/utlis.dart';

class PersonRepository {
  static final PersonRepository _instance = PersonRepository._internal();
  factory PersonRepository() => _instance;
  PersonRepository._internal();

  // fetch all persons with pagination
  Future<ApiResponse<PersonPagination>> getAllPersonsWithPagination(
      int page) async {
    final response = await ApiHelper.get<Map<String, dynamic>>(
        getPageUrl(epPersonPage, page));
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(PersonPagination.fromJson(response.data!));
    }
    return ApiResponse.error(response.error!);
  }

  // fetch person by id
  Future<ApiResponse<Person>> getPerson(String id) async {
    final response =
        await ApiHelper.get<Map<String, dynamic>>("$epPersonById/$id");
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(Person.fromJson(response.data!));
    }
    return ApiResponse.error(response.error!);
  }

  // fetch all persons
  Future<ApiResponse<List<Person>>> getAllPersons() async {
    final response = await ApiHelper.get<List<dynamic>>(epPerson);
    if (response.isSuccess && response.data != null) {
      final persons = response.data!
          .map((json) => Person.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(persons);
    }
    return ApiResponse.error(response.error!);
  }

  // create person
  Future<ApiResponse<NormalResponse>> createPerson(Person person) async {
    final response =
        await ApiHelper.post<Map<String, dynamic>>(epPerson, person.toJson());
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(NormalResponse(
        isSuccess: response.isSuccess,
        message: "Person created successfully",
        data: response.data,
      ));
    }
    return ApiResponse.error(response.error!);
  }

  // update person
  Future<ApiResponse<NormalResponse>> updatePerson(Person person) async {
    final response =
        await ApiHelper.put<Map<String, dynamic>>(epPerson, person.toJson());
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(NormalResponse(
        isSuccess: response.isSuccess,
        message: "Person updated successfully",
      ));
    }
    return ApiResponse.error(response.error!);
  }

  // delete person
  Future<ApiResponse<NormalResponse>> deletePerson(String id) async {
    final response = await ApiHelper.get<Map<String, dynamic>>(
        getDeleteUrl(epPersonDelete, id));
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(NormalResponse(
        isSuccess: response.isSuccess,
        message: "Person deleted successfully",
      ));
    }
    return ApiResponse.error(response.error!);
  }
}
