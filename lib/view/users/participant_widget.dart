import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/participant_model.dart';
import '../../provider/provider.dart';
import '../widgets/pagination_widget.dart';

class ParticipantWidget extends StatefulWidget {
  const ParticipantWidget({super.key});

  @override
  State<ParticipantWidget> createState() => _ParticipantWidgetState();
}

class _ParticipantWidgetState extends State<ParticipantWidget> {
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ParticipantProvider>().fetchAllParticipantsWithPagination();
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Debounce search input and update provider
  Timer? _debounce;
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<PersonProvider>().searchPersons(_searchController.text);
    });
  }

  int _currentPage = 0;

  Future<void> _loadPage(int page) async {
    if (page < 0) return;

    final provider = Provider.of<ParticipantProvider>(context, listen: false);
    final pagination = provider.allParticipantsWithPaginationResponse.data;

    if (pagination != null && page < (pagination.totalPages ?? 0)) {
      await provider.loadMoreParticipants(page);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This is now handled in initState
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16).copyWith(bottom: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Participants",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () {
                  _showPersonSelectionDialog(context);
                },
                label: const Text('Add Participant'),
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor:
                      Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Consumer<ParticipantProvider>(
            builder: (context, provider, child) {
              if (provider.allParticipantsWithPaginationResponse.isLoading &&
                  _currentPage == 0) {
                return const Center(child: CircularProgressIndicator());
              } else if (provider
                  .allParticipantsWithPaginationResponse.isError) {
                return Center(
                    child: Text(
                        provider.allParticipantsWithPaginationResponse.error ??
                            'Error loading participants'));
              } else if (provider.allParticipantsWithPaginationResponse.data
                      ?.content?.isEmpty ??
                  true) {
                return const Center(child: Text('No participants found'));
              }

              final participants = provider
                      .allParticipantsWithPaginationResponse.data!.content ??
                  [];

              return RefreshIndicator(
                onRefresh: () async {
                  _currentPage = 0;
                  await provider.fetchAllParticipantsWithPagination(
                      isRefresh: true);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: participants.length,
                  itemBuilder: (context, index) {
                    if (index >= participants.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final participant = participants[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: provider.selectedParticipantId ==
                                  participant.id
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.primaryContainer,
                        ),
                      ),
                      color: provider.selectedParticipantId == participant.id
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerLow,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        onTap: () {
                          provider.selecteParticipant(participant.id!);
                          context
                              .read<ResponseProvider>()
                              .fetchResponsesByParticipant(
                                  participant.id.toString(),
                                  isRefresh: true);
                        },
                        title: Text(
                            '${participant.person?.firstName ?? ''} ${participant.person?.lastName ?? ''}'),
                        subtitle: Text('ID: ${participant.id}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _showDeleteConfirmation(context, participant);
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        // add pagination element
        Consumer<ParticipantProvider>(
          builder: (context, provider, child) {
            final pagination =
                provider.allParticipantsWithPaginationResponse.data;

            final totalPages = pagination?.totalPages ?? 0;
            final currentPage = pagination?.number ?? 0;
            _currentPage = currentPage;

            return PaginationWidget(
              currentPage: currentPage,
              totalPages: totalPages,
              loadPage: _loadPage,
            );
          },
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, Participant participant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Participant'),
        content: Text(
            'Are you sure you want to delete participant \n ${participant.person?.firstName ?? ''} ${participant.person?.lastName ?? ''}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<ParticipantProvider>()
                  .deleteParticipant(participant.id.toString());
              Navigator.pop(context);

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Participant deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showPersonSelectionDialog(BuildContext context) {
    // Reset search field and clear provider's search
    _searchController.clear();
    context.read<PersonProvider>().searchPersons('');

    // Fetch all persons
    Future.microtask(() {
      context.read<PersonProvider>().fetchAllPersons(isRefresh: true);
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer<PersonProvider>(
          builder: (context, personProvider, child) {
            return Center(
              child: Container(
                width: 600,
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.surface,
                ),
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Person',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name or email',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).colorScheme.surfaceContainerLow,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (personProvider.allPersonsResponse.isLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (personProvider
                              .allPersonsResponse.isError) {
                            return Center(
                              child: Text(
                                  personProvider.allPersonsResponse.error ??
                                      'Error loading persons'),
                            );
                          } else if (personProvider
                                  .filteredPersonsResponse.data?.isEmpty ??
                              true) {
                            return const Center(
                                child: Text('No persons found'));
                          }

                          final filteredPersons =
                              personProvider.filteredPersonsResponse.data ?? [];

                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredPersons.length,
                            itemBuilder: (context, index) {
                              final person = filteredPersons[index];
                              return Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                  ),
                                ),
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerLow,
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(
                                      '${person.firstName ?? ''} ${person.lastName ?? ''}'),
                                  subtitle: Text(person.email ?? ''),
                                  onTap: () {
                                    if (person.id != null) {
                                      final participantProvider =
                                          Provider.of<ParticipantProvider>(
                                              context,
                                              listen: false);
                                      participantProvider
                                          .createParticipant(person.id!);
                                      Navigator.of(context).pop();

                                      // Show success message
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Creating participant for ${person.firstName} ${person.lastName}'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
