import 'package:ccbt_survey/view/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../model/response_model.dart';
import '../../provider/response_provider.dart';
import '../../provider/survey_provider.dart';
import '../../provider/participant_provider.dart';
import '../../model/survey_model.dart';
import '../../model/participant_model.dart';

class ResponseWidget extends StatefulWidget {
  const ResponseWidget({super.key});

  @override
  State<ResponseWidget> createState() => _ResponseWidgetState();
}

class _ResponseWidgetState extends State<ResponseWidget> {
  final TextEditingController _linkIdController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // Future.microtask(
    //     () => context.read<ResponseProvider>().fetchAllResponses());
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // context.read<ResponseProvider>().fetchAllResponses();
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16).copyWith(bottom: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Surveys",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () {
                  _showResponseBottomSheet(context);
                },
                label: const Text('Add Survey'),
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
          child: Consumer<ResponseProvider>(
            builder: (context, provider, child) {
              if (provider.responsesByParticipantResponse.isLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (provider.responsesByParticipantResponse.isError) {
                return Center(
                    child: Text(provider.responsesByParticipantResponse.error ??
                        'Error loading responses'));
              } else if (provider
                      .responsesByParticipantResponse.data?.isEmpty ??
                  true) {
                return const Center(child: Text('No responses found'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.responsesByParticipantResponse.data!.length,
                itemBuilder: (context, index) {
                  final response =
                      provider.responsesByParticipantResponse.data![index];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text(
                          'Survey: ${response.survey?.survey ?? 'Unknown'}'),
                      subtitle: Text(
                          'Participant: ${response.participant?.person?.firstName ?? ''} ${response.participant?.person?.lastName ?? ''}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () {
                          _showResponseDetailsDialog(context, response);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showResponseDetailsDialog(
      BuildContext context, ResponseModel response) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Response Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Response ID: ${response.id}'),
              const SizedBox(height: 8),
              Text('Survey: ${response.survey?.survey ?? 'Unknown'}'),
              const SizedBox(height: 8),
              Text(
                  'Participant: ${response.participant?.person?.firstName ?? ''} ${response.participant?.person?.lastName ?? ''}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showResponseBottomSheet(BuildContext context) {
    int? selectedSurveyId;

    // Fetch all surveys
    context.read<SurveyProvider>().fetchAllSurveys();

    // Get the selected participant ID from ParticipantProvider
    final participantProvider =
        Provider.of<ParticipantProvider>(context, listen: false);

    // Make sure all participants are loaded before proceeding
    participantProvider.fetchAllParticipants(isRefresh: true);

    final selectedParticipantId = participantProvider.selectedParticipantId;

    // Check if a participant is selected
    if (selectedParticipantId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a participant first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // context: context,
    // isScrollControlled: true,
    // backgroundColor: Colors.transparent,
    // builder: (context) {
    // return Center(
    //   child: Container(
    //     width: 400,

    //     decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(16),
    //       color: Theme.of(context).colorScheme.surface,
    //     ),
    //     margin: EdgeInsets.all(20),
    //     // height: double.maxFinite,
    //     padding: EdgeInsets.only(
    //       bottom: MediaQuery.of(context).viewInsets.bottom,
    //       left: 16,
    //       right: 16,
    //       top: 16,
    //     ),
    //     child:

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assign Survey',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Display selected participant info
                  Consumer<ParticipantProvider>(
                      builder: (context, provider, _) {
                    final participant = provider.selectedParticipant;
                    final firstName = participant?.person?.firstName ?? '';
                    final lastName = participant?.person?.lastName ?? '';

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Selected Participant:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text('$firstName $lastName',
                                    style: const TextStyle(fontSize: 16)),
                                Text('ID: ${participant?.id}',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  const Text('Link ID:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFieldWidget(
                    controller: _linkIdController,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a link ID';
                      }
                      // Check if the value is a valid integer
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid integer value';
                      }
                      // Check if it contains any decimal point
                      if (value.contains('.')) {
                        return 'Decimal values are not allowed';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text('Select Survey:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // Survey Dropdown
                  Consumer<SurveyProvider>(
                    builder: (context, surveyProvider, child) {
                      if (surveyProvider.allSurveysResponse.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (surveyProvider.allSurveysResponse.isError) {
                        return Text(
                            'Error: ${surveyProvider.allSurveysResponse.error}');
                      } else if (surveyProvider
                              .allSurveysResponse.data?.isEmpty ??
                          true) {
                        return const Text('No surveys available');
                      }

                      return DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Select Survey',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        isExpanded: true, // This prevents overflow
                        icon: const Icon(Icons.arrow_drop_down),
                        value: selectedSurveyId,
                        items: surveyProvider.allSurveysResponse.data!
                            .map((survey) {
                          return DropdownMenuItem<int>(
                            value: survey.id,
                            child: Text(
                              survey.survey ?? 'Unknown Survey',
                              overflow: TextOverflow
                                  .ellipsis, // Truncate text if too long
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSurveyId = value;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              if (selectedSurveyId != null &&
                                  _linkIdController.text.isNotEmpty) {
                                // Create response payload
                                final response = ResponseModel(
                                  survey: Survey(id: selectedSurveyId),
                                  linkId: int.tryParse(_linkIdController.text),
                                  participant:
                                      Participant(id: selectedParticipantId),
                                );

                                // Submit response
                                context
                                    .read<ResponseProvider>()
                                    .createResponse(response);

                                // Close bottom sheet
                                Navigator.pop(context);

                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Response created successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select a survey'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: const Text('Assign'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ));
          },
        );
      },
    );
  }
}
