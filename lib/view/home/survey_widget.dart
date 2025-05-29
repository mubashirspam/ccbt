import 'package:ccbt_survey/view/widgets/button_widget.dart';
import 'package:ccbt_survey/view/widgets/textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/provider.dart';
import '../../model/model.dart';
import '../widgets/pagination_widget.dart';

class SurveyWidget extends StatefulWidget {
  const SurveyWidget({super.key});

  @override
  State<SurveyWidget> createState() => _SurveyWidgetState();
}

class _SurveyWidgetState extends State<SurveyWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<SurveyProvider>().fetchAllSurveys());
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SurveyProvider>().fetchAllSurveys();
    });
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16).copyWith(bottom: 0),
          child: SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Surveys",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    _showSurveyBottomSheet(context);
                  },
                  label: Text('Add Survey'),
                  icon: Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                )
              ],
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            child: Consumer<SurveyProvider>(
              builder: (context, provider, child) {
                if (provider.allSurveysResponse.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.allSurveysResponse.isError) {
                  return Center(
                    child: Text(
                      provider.allSurveysResponse.error ?? 'An error occurred',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final surveys = provider.allSurveysResponse.data ?? [];

                if (surveys.isEmpty) {
                  return const Center(
                    child: Text('No surveys available'),
                  );
                }

                return ListView.builder(
                  itemCount: surveys.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final survey = surveys[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: provider.selectedSurveyId == survey.id
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.primaryContainer,
                        ),
                      ),
                      color: provider.selectedSurveyId == survey.id
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerLow,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        // leading: CircleAvatar(child: Text((index + 1).toString())),
                        onTap: () {
                          context.read<SurveyProvider>().selectedSurveyId =
                              survey.id!;
                          context
                              .read<QuestionProvider>()
                              .fetchQuestionBySurvey(survey.id.toString());
                        },
                        title: Text(survey.survey ?? 'Untitled Survey'),

                        trailing: _buildPopupMenuItem(context, survey),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showSurveyBottomSheet(BuildContext context,
      [Survey? survey]) async {
    final formKey = GlobalKey<FormState>();
    final surveyController = TextEditingController(text: survey?.survey);

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Center(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    survey == null ? 'Add Survey' : 'Edit Survey',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Form(
                key: formKey,
                child: TextFieldWidget(
                  hintText: 'Enter survey name',
                  controller: surveyController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a survey name';
                    }
                    return null;
                  },
                ),
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
                    child: SizedBox(
                      width: double.infinity,
                      child: Consumer<SurveyProvider>(
                          builder: (context, provider, child) {
                        return ButtonWidget(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              if (survey == null) {
                                context.read<SurveyProvider>().createSurvey(
                                      Survey(survey: surveyController.text),
                                    );
                              } else {
                                context.read<SurveyProvider>().updateSurvey(
                                      Survey(
                                        id: survey.id,
                                        survey: surveyController.text,
                                      ),
                                    );
                              }
                              Navigator.pop(context);
                            }
                          },
                          isLoading: provider.currentSurveyResponse.isLoading,
                          text: survey == null ? 'Add Survey' : 'Save Changes',
                        );
                      }),
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
  }

  Future<void> _showAssignSurveyBottomSheet(
      BuildContext context, Survey survey) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height,
      ),
      builder: (context) => Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surface,
        ),
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Assign survey',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: SizedBox(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          // color: Theme.of(context).colorScheme.onPrimary,
                          border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Consumer<ParticipantProvider>(
                                builder: (context, provider, child) {
                                  if (provider
                                      .allParticipantsWithPaginationResponse
                                      .isLoading) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (provider
                                      .allParticipantsWithPaginationResponse
                                      .isError) {
                                    return Center(
                                        child: Text(provider
                                                .allParticipantsWithPaginationResponse
                                                .error ??
                                            'Error loading participants'));
                                  } else if (provider
                                          .allParticipantsWithPaginationResponse
                                          .data
                                          ?.content
                                          ?.isEmpty ??
                                      true) {
                                    return const Center(
                                        child: Text('No participants found'));
                                  }

                                  final participants = provider
                                          .allParticipantsWithPaginationResponse
                                          .data!
                                          .content ??
                                      [];

                                  return ListView.builder(
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
                                      bool isSelected = provider
                                          .selectedParticipants
                                          .contains(participant);
                                      bool isMatched = context
                                              .read<ResponseProvider>()
                                              .responsesBySurveyResponse
                                              .data
                                              ?.any((response) =>
                                                  response.participant?.id ==
                                                  participants[index].id) ??
                                          false;
                                      return Card(
                                        key: ValueKey(participant.id),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          side: BorderSide(
                                            color: isMatched
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .outlineVariant
                                                : isSelected
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .primaryContainer,
                                          ),
                                        ),
                                        color: isMatched
                                            ? Theme.of(context)
                                                .colorScheme
                                                .outlineVariant
                                            : isSelected
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primaryContainer
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainerLow,
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        child: ListTile(
                                          onTap: () {
                                            if (isMatched) {
                                              return;
                                            }
                                            if (isSelected) {
                                              provider.removeParticipant(
                                                  participant);
                                            } else {
                                              provider
                                                  .addParticipant(participant);
                                            }
                                          },
                                          title: Text(
                                              '${participant.person?.firstName ?? ''} ${participant.person?.lastName ?? ''}'),
                                          subtitle:
                                              Text('ID: ${participant.id}'),
                                          trailing: isSelected
                                              ? const Icon(Icons.check,
                                                  color: Colors.green)
                                              : null,
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            Consumer<ParticipantProvider>(
                              builder: (context, provider, child) {
                                final pagination = provider
                                    .allParticipantsWithPaginationResponse.data;

                                final totalPages = pagination?.totalPages ?? 0;
                                final currentPage = pagination?.number ?? 0;

                                return PaginationWidget(
                                  currentPage: currentPage,
                                  totalPages: totalPages,
                                  loadPage: _loadPage,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          // color: Theme.of(context).colorScheme.onPrimary,
                          border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Select Participants',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  )),
                              const SizedBox(height: 16),
                              Expanded(
                                child: Consumer<ParticipantProvider>(
                                    builder: (context, provider, child) {
                                  return SizedBox(
                                    child: Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: List.generate(
                                        provider.selectedParticipants.length,
                                        (index) => Chip(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          onDeleted: () {
                                            provider.removeParticipant(provider
                                                .selectedParticipants[index]);
                                          },
                                          label: Text(
                                              '${provider.selectedParticipants[index].person?.firstName ?? ''} ${provider.selectedParticipants[index].person?.lastName ?? ''}'),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
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
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Consumer<ResponseProvider>(
                                          builder: (context, provider, child) {
                                        final participants = context
                                            .read<ParticipantProvider>()
                                            .selectedParticipants;
                                        return ButtonWidget(
                                          onPressed: () async {
                                            if (participants.isNotEmpty) {
                                              final List<ResponseModel>
                                                  response = participants
                                                      .map((p) => ResponseModel(
                                                            survey: survey,
                                                            participant:
                                                                Participant(
                                                              id: p.id,
                                                            ),
                                                          ))
                                                      .toList();
                                              await provider
                                                  .createResponseBulk(response);

                                              Navigator.pop(context);

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Survey assigned to ${participants.length} participant(s)'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                          },
                                          isLoading: provider
                                              .currentResponseResponse
                                              .isLoading,
                                          text: 'Apply',
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _loadPage(int page) async {
    if (page < 0) return;

    final provider = Provider.of<ParticipantProvider>(context, listen: false);
    final pagination = provider.allParticipantsWithPaginationResponse.data;

    if (pagination != null && page < (pagination.totalPages ?? 0)) {
      await provider.loadMoreParticipants(page);
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Survey survey) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Survey'),
        content: const Text('Are you sure you want to delete this survey?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<SurveyProvider>().deleteSurvey(survey.id.toString());
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupMenuItem(BuildContext context, Survey survey) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.primary),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Text('Edit'),
          onTap: () => _showSurveyBottomSheet(context, survey),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text('Delete'),
          onTap: () => _showDeleteConfirmation(context, survey),
        ),
        PopupMenuItem(
          value: 'assign',
          child: Text('Assign'),
          onTap: () => {
            _showAssignSurveyBottomSheet(context, survey),
            context
                .read<ResponseProvider>()
                .fetchResponsesBySurvey(survey.id.toString()),
            context
                .read<ParticipantProvider>()
                .fetchAllParticipantsWithPagination()
          },
        ),
      ],
      onSelected: (value) {},
    );
  }
}
