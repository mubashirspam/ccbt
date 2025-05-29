import 'package:flutter/material.dart';

import '../model/model.dart';
import '../repository/person_repository.dart';
import '../utils/api_response.dart';

class PersonProvider extends ChangeNotifier {
  final _repository = PersonRepository();
  ApiResponse<Person> _personResponse = ApiResponse.idle();
  ApiResponse<List<Person>> _allPersonsResponse = ApiResponse.idle();
  ApiResponse<List<Person>> _filteredPersonsResponse = ApiResponse.idle();
  ApiResponse<NormalResponse> _currentPersonResponse = ApiResponse.idle();
  ApiResponse<PersonPagination> _allPersonsWithPaginationResponse =
      ApiResponse.idle();
      
  String _searchQuery = '';
  
  // Cache to store loaded pages
  final Map<int, List<Person>> _loadedPages = {};
  
  ApiResponse<Person> get personResponse => _personResponse;
  ApiResponse<List<Person>> get allPersonsResponse => _allPersonsResponse;
  ApiResponse<List<Person>> get filteredPersonsResponse => _filteredPersonsResponse;
  ApiResponse<NormalResponse> get currentPersonResponse =>
      _currentPersonResponse;
  ApiResponse<PersonPagination> get allPersonsWithPaginationResponse => _allPersonsWithPaginationResponse;
  Person? get currentPerson => _personResponse.data;
  
  String get searchQuery => _searchQuery;

  int _selectedPersonId = 0;

  Person? get selectedPerson => _allPersonsResponse.data?.firstWhere(
      (person) => person.id == _selectedPersonId,
      orElse: () => Person());

  int get selectedPersonId => _selectedPersonId;

  void selectPerson(int id) {
    _selectedPersonId = id;
    notifyListeners();
  }

  Future<void> fetchAllPersonsWithPagination({bool isRefresh = false, int page = 0}) async {
    // If we're not refreshing and the data is already loading or loaded, return early
    if (!isRefresh && 
        (_allPersonsWithPaginationResponse.isLoading ||
            _allPersonsWithPaginationResponse.isSuccess)) {
      return;
    }
    
    // Set loading state
    _allPersonsWithPaginationResponse = ApiResponse.loading();
    notifyListeners();
    
    // Fetch data from API
    final response = await _repository.getAllPersonsWithPagination(page);
    
    if (response.isSuccess && response.data != null) {
      // Cache the loaded page
      _loadedPages[page] = response.data!.content ?? [];
    }
    
    _allPersonsWithPaginationResponse = response;
    notifyListeners();
  }
  
  Future<void> loadMorePersons(int page) async {
    if (_allPersonsWithPaginationResponse.isLoading) {
      return;
    }
    
    final currentResponse = _allPersonsWithPaginationResponse;
    if (!currentResponse.isSuccess) {
      return;
    }
    
    // Check if the page is already in cache
    if (_loadedPages.containsKey(page)) {
      final currentData = currentResponse.data!;
      final cachedPageContent = _loadedPages[page]!;
      
      // Create a new PersonPagination with merged content and updated pagination info
      final mergedPagination = PersonPagination(
        content: [...(currentData.content ?? []), ...cachedPageContent],
        pageable: currentData.pageable?.copyWith(pageNumber: page),
        last: page >= (currentData.totalPages ?? 1) - 1,
        totalPages: currentData.totalPages,
        totalElements: currentData.totalElements,
        first: false,
        sort: currentData.sort,
        numberOfElements: (currentData.content?.length ?? 0) + cachedPageContent.length,
        size: currentData.size,
        number: page,
      );
      
      _allPersonsWithPaginationResponse = ApiResponse.success(mergedPagination);
      notifyListeners();
      return;
    }
    
    // If not in cache, fetch from API
    final newResponse = await _repository.getAllPersonsWithPagination(page);
    
    if (newResponse.isSuccess && newResponse.data != null) {
      final currentData = currentResponse.data!;
      final newData = newResponse.data!;
      
      // Cache the loaded page
      _loadedPages[page] = newData.content ?? [];
      
      // Merge the content from both responses
      final List<Person> mergedContent = [...(currentData.content ?? []), ...(newData.content ?? [])];
      
      // Create a new PersonPagination with merged content and updated pagination info
      final mergedPagination = PersonPagination(
        content: mergedContent,
        pageable: newData.pageable,
        last: newData.last,
        totalPages: newData.totalPages,
        totalElements: newData.totalElements,
        first: newData.first,
        sort: newData.sort,
        numberOfElements: mergedContent.length,
        size: newData.size,
        number: newData.number,
      );
      
      _allPersonsWithPaginationResponse = ApiResponse.success(mergedPagination);
      notifyListeners();
    }
  }
  
  Future<void> fetchPageOfPersons(int page) async {
    if (_allPersonsWithPaginationResponse.isLoading) {
      return;
    }
    
    // Check if the page is already loaded in the cache
    if (_loadedPages.containsKey(page) && 
        _allPersonsWithPaginationResponse.isSuccess && 
        _allPersonsWithPaginationResponse.data != null) {
      
      // Create a new pagination object with the cached page content
      final currentData = _allPersonsWithPaginationResponse.data!;
      final cachedPageContent = _loadedPages[page]!;
      
      final updatedPagination = PersonPagination(
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
      
      _allPersonsWithPaginationResponse = ApiResponse.success(updatedPagination);
      notifyListeners();
      return;
    }
    
    // If not in cache, fetch from API
    _allPersonsWithPaginationResponse = ApiResponse.loading();
    notifyListeners();
    
    final response = await _repository.getAllPersonsWithPagination(page);
    
    if (response.isSuccess && response.data != null) {
      // Cache the loaded page
      _loadedPages[page] = response.data!.content ?? [];
    }
    
    _allPersonsWithPaginationResponse = response;
    notifyListeners();
  }

  Future<void> fetchPerson(String personId) async {
    _personResponse = ApiResponse.loading();
    notifyListeners();
    _personResponse = await _repository.getPerson(personId);
    notifyListeners();
  }

  Future<void> fetchAllPersons({bool isRefresh = false}) async {
    if (!isRefresh &&
        (_allPersonsResponse.isLoading || _allPersonsResponse.isSuccess)) {
      return;
    }
    _allPersonsResponse = ApiResponse.loading();
    _filteredPersonsResponse = ApiResponse.loading();
    notifyListeners();
    _allPersonsResponse = await _repository.getAllPersons();
    
    // Initialize filtered persons with all persons
    if (_allPersonsResponse.isSuccess && _allPersonsResponse.data != null) {
      _filteredPersonsResponse = ApiResponse.success(_allPersonsResponse.data!);
    } else {
      _filteredPersonsResponse = _allPersonsResponse;
    }
    
    notifyListeners();
  }

  void searchPersons(String query) {
    _searchQuery = query.toLowerCase();
    
    if (_allPersonsResponse.isSuccess && _allPersonsResponse.data != null) {
      if (_searchQuery.isEmpty) {
        _filteredPersonsResponse = ApiResponse.success(_allPersonsResponse.data!);
      } else {
        final filteredList = _allPersonsResponse.data!.where((person) {
          final fullName = '${person.firstName ?? ''} ${person.lastName ?? ''}'.toLowerCase();
          final email = (person.email ?? '').toLowerCase();
          return fullName.contains(_searchQuery) || email.contains(_searchQuery);
        }).toList();
        
        _filteredPersonsResponse = ApiResponse.success(filteredList);
      }
      notifyListeners();
    }
  }

  Future<void> createPerson(Person person) async {
    _currentPersonResponse = ApiResponse.loading();
    notifyListeners();

    _currentPersonResponse = await _repository.createPerson(person);
    if (_currentPersonResponse.isSuccess) {
      await fetchAllPersonsWithPagination(isRefresh: true);
    }
    
    notifyListeners();
  }

  Future<void> updatePerson(Person person) async {
    _currentPersonResponse = ApiResponse.loading();
    notifyListeners();

    _currentPersonResponse = await _repository.updatePerson(person);
    if (_currentPersonResponse.isSuccess) {
      await fetchAllPersonsWithPagination(isRefresh: true);
    }
    notifyListeners();
  }

  Future<void> deletePerson(String id ,int page ) async {
    _currentPersonResponse = ApiResponse.loading();
    notifyListeners();

    _currentPersonResponse = await _repository.deletePerson(id);
    if (_currentPersonResponse.isSuccess) {
      await fetchAllPersonsWithPagination(isRefresh: true, page: page);
    }
    notifyListeners();
  }
}
