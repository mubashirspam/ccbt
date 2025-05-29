import 'package:ccbt_survey/model/model.dart';
import 'package:ccbt_survey/provider/participant_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/person_model.dart';
import '../../provider/person_provider.dart';
import '../widgets/widgets.dart';

class PersonWidget extends StatefulWidget {
  const PersonWidget({super.key});

  @override
  State<PersonWidget> createState() => _PersonWidgetState();
}

class _PersonWidgetState extends State<PersonWidget> {
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => context.read<PersonProvider>().fetchAllPersonsWithPagination());
  }

  Future<void> _loadPage(int page) async {
    if (page < 0) return;

    final provider = Provider.of<PersonProvider>(context, listen: false);
    final pagination = provider.allPersonsWithPaginationResponse.data;

    if (pagination != null && page < (pagination.totalPages ?? 0)) {
      await provider.fetchPageOfPersons(page);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonProvider>().fetchAllPersonsWithPagination();
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16).copyWith(bottom: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "People",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              // TextButton.icon(
              //   onPressed: () {
              //     _showPersonBottomSheet(context);
              //   },
              //   label: const Text('Add Person'),
              //   icon: const Icon(Icons.add),
              //   style: IconButton.styleFrom(
              //     backgroundColor:
              //         Theme.of(context).colorScheme.primaryContainer,
              //     foregroundColor:
              //         Theme.of(context).colorScheme.onPrimaryContainer,
              //   ),
              // ),
            ],
          ),
        ),
        Expanded(
          child: Consumer<PersonProvider>(
            builder: (context, provider, child) {
              if (provider.allPersonsWithPaginationResponse.isLoading &&
                  _currentPage == 0) {
                return const Center(child: CircularProgressIndicator());
              } else if (provider.allPersonsWithPaginationResponse.isError) {
                return Center(
                    child: Text(
                        provider.allPersonsWithPaginationResponse.error ??
                            'Error loading people'));
              } else if (provider.allPersonsWithPaginationResponse.data?.content
                      ?.isEmpty ??
                  true) {
                return const Center(child: Text('No people found'));
              }

              final persons =
                  provider.allPersonsWithPaginationResponse.data!.content!;

              return RefreshIndicator(
                onRefresh: () async {
                  _currentPage = 0;
                  await provider.fetchAllPersonsWithPagination(isRefresh: true);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: persons.length,
                  itemBuilder: (context, index) {
                    final person = persons[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: provider.selectedPersonId == person.id
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.primaryContainer,
                        ),
                      ),
                      color: provider.selectedPersonId == person.id
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerLow,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        onTap: () {
                          provider.selectPerson(person.id!);
                          context
                              .read<ParticipantProvider>()
                              .fetchParticipantsByPerson(person.id!,
                                  isRefresh: true);
                        },
                        title: Text(
                            '${person.firstName ?? ''} ${person.lastName ?? ''}'),
                        subtitle: Text(person.email ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showPersonBottomSheet(context, person: person);
                              },
                            ),
                            // IconButton(
                            //   icon: const Icon(Icons.delete),
                            //   onPressed: () {
                            //     _showDeleteConfirmation(
                            //         context, person.id!, _currentPage);
                            //   },
                            // ),
                          ],
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
        Consumer<PersonProvider>(
          builder: (context, provider, child) {
            // if (!provider.allPersonsWithPaginationResponse.isSuccess) {
            //   return const SizedBox.shrink();
            // }

            final pagination = provider.allPersonsWithPaginationResponse.data;
            // if (pagination == null) return const SizedBox.shrink();

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

  Future<void> _showDeleteConfirmation(
      BuildContext context, int personId, int page) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Person'),
        content: const Text('Are you sure you want to delete this person?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<PersonProvider>()
                  .deletePerson(personId.toString(), page);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showPersonBottomSheet(BuildContext context, {Person? person}) {
    final firstNameController = TextEditingController(text: person?.firstName);
    final lastNameController = TextEditingController(text: person?.lastName);
    final emailController = TextEditingController(text: person?.email);
    final phoneController = TextEditingController(text: person?.phone);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Center(
          child: Container(
            width: 400,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.surface,
            ),
            margin: EdgeInsets.all(20),
            // height: double.maxFinite,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    person == null ? 'Add Person' : 'Edit Person',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFieldWidget(
                    controller: firstNameController,
                    hintText: 'First Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFieldWidget(
                    controller: lastNameController,
                    hintText: 'Last Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFieldWidget(
                    controller: emailController,
                    hintText: 'Email',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFieldWidget(
                    controller: phoneController,
                    hintText: 'Phone',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: ButtonWidget(
                            isSecondary: true,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            text: 'Cancel',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ButtonWidget(
                          text: person == null ? 'Add' : 'Update',
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final updatedPerson = Person(
                                id: person?.id,
                                firstName: firstNameController.text,
                                lastName: lastNameController.text,
                                email: emailController.text,
                                phone: phoneController.text,
                              );

                              if (person == null) {
                                context
                                    .read<PersonProvider>()
                                    .createPerson(updatedPerson);
                              } else {
                                context
                                    .read<PersonProvider>()
                                    .updatePerson(updatedPerson);
                              }

                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
