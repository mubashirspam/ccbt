import 'package:flutter/material.dart';

import '../model/model.dart';
import '../repository/participant_repository.dart';
import '../utils/api_response.dart';

class ParticipantProvider extends ChangeNotifier {
  final _repository = ParticipantRepository();
  ApiResponse<Participant> _participantResponse = ApiResponse.idle();
  ApiResponse<List<Participant>> _allParticipantsResponse = ApiResponse.idle();
  ApiResponse<List<Participant>> _participantsByPersonResponse =
      ApiResponse.idle();
  ApiResponse<NormalResponse> _currentParticipantResponse = ApiResponse.idle();
  ApiResponse<ParticipantPagination> _allParticipantsWithPaginationResponse =
      ApiResponse.idle();

  // Cache to store loaded pages
  final Map<int, List<Participant>> _loadedPages = {};

  final List<Participant> _selectedParticipants = [];

  ApiResponse<Participant> get participantResponse => _participantResponse;
  ApiResponse<List<Participant>> get allParticipantsResponse =>
      _allParticipantsResponse;
  ApiResponse<List<Participant>> get participantsByPersonResponse =>
      _participantsByPersonResponse;
  ApiResponse<NormalResponse> get currentParticipantResponse =>
      _currentParticipantResponse;
  ApiResponse<ParticipantPagination>
      get allParticipantsWithPaginationResponse =>
          _allParticipantsWithPaginationResponse;
  Participant? get currentParticipant => _participantResponse.data;

  int _selectedParticipantId = 0;
  Participant? get selectedParticipant => _allParticipantsResponse.data
      ?.firstWhere((participant) => participant.id == _selectedParticipantId,
          orElse: () => Participant());
  int get selectedParticipantId => _selectedParticipantId;
  List<Participant> get selectedParticipants => _selectedParticipants;

  void selecteParticipant(int id) {
    _selectedParticipantId = id;
    notifyListeners();
  }

  void addParticipant(Participant participant) {
    _selectedParticipants.add(participant);
    notifyListeners();
  }

  void removeParticipant(Participant participant) {
    _selectedParticipants.remove(participant);
    notifyListeners();
  }

  Future<void> fetchParticipant(String participantId) async {
    _participantResponse = ApiResponse.loading();
    notifyListeners();
    _participantResponse = await _repository.getParticipant(participantId);
    notifyListeners();
  }

  Future<void> fetchAllParticipants({bool isRefresh = false}) async {
    if (!isRefresh &&
        (_allParticipantsResponse.isLoading ||
            _allParticipantsResponse.isSuccess)) {
      return;
    }
    _allParticipantsResponse = ApiResponse.loading();
    notifyListeners();
    _allParticipantsResponse = await _repository.getAllParticipants();
    notifyListeners();
  }

  Future<void> fetchParticipantsByPerson(int personId,
      {bool isRefresh = false}) async {
    if (!isRefresh &&
        (_participantsByPersonResponse.isLoading ||
            _participantsByPersonResponse.isSuccess)) {
      return;
    }
    _participantsByPersonResponse = ApiResponse.loading();
    notifyListeners();
    _participantsByPersonResponse =
        await _repository.getParticipantsByPerson(personId.toString());
    notifyListeners();
  }

  Future<void> createParticipant(int personId) async {
    _currentParticipantResponse = ApiResponse.loading();
    notifyListeners();

    _currentParticipantResponse = await _repository.createParticipant(personId);
    if (_currentParticipantResponse.isSuccess) {
      // Clear cache since data has changed
      _loadedPages.clear();
      await fetchAllParticipantsWithPagination(isRefresh: true);
    }
    notifyListeners();
  }

  Future<void> updateParticipant(Participant participant) async {
    _currentParticipantResponse = ApiResponse.loading();
    notifyListeners();

    _currentParticipantResponse =
        await _repository.updateParticipant(participant);
    if (_currentParticipantResponse.isSuccess) {
      // Clear cache since data has changed
      _loadedPages.clear();
      await fetchAllParticipantsWithPagination(isRefresh: true);
    }
    notifyListeners();
  }

  Future<void> deleteParticipant(String id) async {
    _currentParticipantResponse = ApiResponse.loading();
    notifyListeners();

    _currentParticipantResponse = await _repository.deleteParticipant(id);
    if (_currentParticipantResponse.isSuccess) {
      // Clear cache since data has changed
      _loadedPages.clear();
      await fetchAllParticipantsWithPagination(isRefresh: true);
      
    }
    notifyListeners();
  }

  Future<void> fetchAllParticipantsWithPagination(
      {bool isRefresh = false, int page = 0}) async {
    // If we're not refreshing and the data is already loading or loaded, return early
    if (!isRefresh &&
        (_allParticipantsWithPaginationResponse.isLoading ||
            _allParticipantsWithPaginationResponse.isSuccess)) {
      return;
    }

    // Clear cache if refreshing
    if (isRefresh) {
      _loadedPages.clear();
    }

    // Set loading state
    _allParticipantsWithPaginationResponse = ApiResponse.loading();
    notifyListeners();

    // Fetch data from API
    final response = await _repository.getAllParticipantsWithPagination(page);

    if (response.isSuccess && response.data != null) {
      // Cache the loaded page
      _loadedPages[page] = response.data!.content ?? [];
    }

    _allParticipantsWithPaginationResponse = response;
    notifyListeners();
  }

  Future<void> loadMoreParticipants(int page) async {
    if (_allParticipantsWithPaginationResponse.isLoading) {
      return;
    }

    final currentResponse = _allParticipantsWithPaginationResponse;
    if (!currentResponse.isSuccess || currentResponse.data == null) {
      return;
    }

    // Check if the page is already in cache
    if (_loadedPages.containsKey(page)) {
      final currentData = currentResponse.data!;
      final cachedPageContent = _loadedPages[page]!;

      // Create a new ParticipantPagination with the cached content
      final updatedPagination = ParticipantPagination(
        content: cachedPageContent,
        pageable: currentData.pageable?.copyWith(pageNumber: page),
        last: page >= (currentData.totalPages ?? 1) - 1,
        totalPages: currentData.totalPages,
        totalElements: currentData.totalElements,
        first: page == 0,
        sort: currentData.sort,
        numberOfElements: cachedPageContent.length,
        size: currentData.size,
        number: page,
      );

      _allParticipantsWithPaginationResponse =
          ApiResponse.success(updatedPagination);
      notifyListeners();
      return;
    }

    // If not in cache, fetch from API
    final nextPageResponse =
        await _repository.getAllParticipantsWithPagination(page);


    if (nextPageResponse.isSuccess && nextPageResponse.data != null) {
      // Cache the loaded page
      _loadedPages[page] = nextPageResponse.data!.content ?? [];

      final updatedPagination = ParticipantPagination(
        content: nextPageResponse.data!.content ?? [],
        pageable: nextPageResponse.data!.pageable,
        last: nextPageResponse.data!.last,
        totalPages: nextPageResponse.data!.totalPages,
        totalElements: nextPageResponse.data!.totalElements,
        first: page == 0,
        sort: nextPageResponse.data!.sort,
        numberOfElements: nextPageResponse.data!.content?.length ?? 0,
        size: nextPageResponse.data!.size,
        number: nextPageResponse.data!.number,
      );

      _allParticipantsWithPaginationResponse =
          ApiResponse.success(updatedPagination);
      notifyListeners();
    }
  }
}
