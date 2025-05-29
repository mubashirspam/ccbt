import 'dart:developer';

import 'package:ccbt_survey/provider/question_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/answer_option_provider.dart';
import '../../model/model.dart';
import '../../provider/survey_provider.dart';
import '../widgets/button_widget.dart';
import '../widgets/textfield_widget.dart';

class OptionsWidget extends StatefulWidget {
  const OptionsWidget({super.key});

  @override
  State<OptionsWidget> createState() => _OptionsWidgetState();
}

class _OptionsWidgetState extends State<OptionsWidget> {
  @override
  void initState() {
    super.initState();
    // Future.microtask(
    //     () => context.read<AnswerOptionProvider>().fetchAllAnswerOptions());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16).copyWith(bottom: 0),
          child: SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Answer Options",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Consumer<AnswerOptionProvider>(
                    builder: (context, provider, child) {
                  final QuestionModel? question =
                      context.read<QuestionProvider>().selectedQuestion;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        onPressed:
                            question?.questionType?.questionType == 'MCQ' &&
                                    provider.optionsByQuestionResponse.isSuccess
                                ? () {
                                    _showOptionBottomSheet(context);
                                  }
                                : null,
                        icon: Icon(Icons.add),
                        label: Text('Add Option'),
                        style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (question?.questionType?.questionType == 'MCQ' &&
                          provider.optionsByQuestionResponse.isSuccess)
                        TextButton.icon(
                          onPressed: question?.questionType?.questionType ==
                                      'MCQ' &&
                                  provider.optionsByQuestionResponse.isSuccess
                              ? () {
                                  _showTemplateSelectionBottomSheet(context);
                                }
                              : null,
                          icon: Icon(Icons.list_alt_outlined),
                          label: Text('Use Template'),
                          style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            foregroundColor: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                        ),
                    ],
                  );
                })
              ],
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            child: Consumer<AnswerOptionProvider>(
              builder: (context, provider, child) {
                if (provider.optionsByQuestionResponse.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.optionsByQuestionResponse.isError) {
                  return Center(
                    child: Text(
                      provider.optionsByQuestionResponse.error ??
                          'An error occurred',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final options = provider.optionsByQuestionResponse.data ?? [];

                if (options.isEmpty) {
                  return const Center(
                    child: Text('No answer options available'),
                  );
                }

                return ListView.builder(
                  itemCount: options.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text(option.optionValue ?? 'Untitled Option'),
                        // subtitle: Text('Score: ${option.id}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showOptionBottomSheet(
                                context,
                                option,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _showDeleteConfirmation(context, option),
                            ),
                          ],
                        ),
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

  Future<void> _showTemplateSelectionBottomSheet(BuildContext context) async {
    // Fetch templates if not already loaded
    final provider = Provider.of<AnswerOptionProvider>(context, listen: false);
    if (provider.allTemplatesResponse.isIdle) {
      await provider.fetchAllTemplates();
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          Consumer<AnswerOptionProvider>(builder: (context, provider, child) {
        if (provider.allTemplatesResponse.isLoading) {
          return _buildLoadingContainer(context);
        }

        if (provider.allTemplatesResponse.isError) {
          return _buildErrorContainer(context,
              provider.allTemplatesResponse.error ?? 'An error occurred');
        }

        final templateItems = provider.allTemplatesResponse.data ?? [];
        if (templateItems.isEmpty) {
          return _buildErrorContainer(context, 'No templates available');
        }

        // Group template items by template ID
        final Map<int, List<AnswerOptionTemplateItem>> groupedTemplates = {};
        for (var item in templateItems) {
          if (item.answerOptionTemplate?.id != null) {
            final templateId = item.answerOptionTemplate!.id!;
            if (!groupedTemplates.containsKey(templateId)) {
              groupedTemplates[templateId] = [];
            }
            groupedTemplates[templateId]!.add(item);
          }
        }

        return Center(
          child: Container(
            width: 500,
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.surface,
            ),
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Choose Answer Options Template',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: groupedTemplates.length,
                    itemBuilder: (context, index) {
                      final templateId = groupedTemplates.keys.elementAt(index);
                      final templateItems = groupedTemplates[templateId]!;
                      final templateName = templateItems.first
                              .answerOptionTemplate?.answerOptionTemplate ??
                          'Unknown Template';

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ExpansionTile(
                          // backgroundColor:
                          //     Theme.of(context).colorScheme.primaryContainer,
                          collapsedBackgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          collapsedShape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          title: Text(templateName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${templateItems.length} options'),
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: templateItems.length,
                              itemBuilder: (context, i) {
                                final item = templateItems[i];
                                return ListTile(
                                  title: Text(
                                      item.answerOption ?? 'Unnamed Option'),
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ButtonWidget(
                                onPressed: () =>
                                    _createAnswerOptionFromTemplate(
                                        context, templateId),
                                text: 'Choose Template',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Helper method to create a loading container
  Widget _buildLoadingContainer(BuildContext context) {
    return Center(
      child: Container(
        width: 500,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surface,
        ),
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading templates...'),
          ],
        ),
      ),
    );
  }

  // Helper method to create an error container
  Widget _buildErrorContainer(BuildContext context, String errorMessage) {
    return Center(
      child: Container(
        width: 500,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surface,
        ),
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ButtonWidget(
              text: 'Close',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create answer options from a template
  void _createAnswerOptionFromTemplate(BuildContext context, int templateId) {
    final questionProvider =
        Provider.of<QuestionProvider>(context, listen: false);
    final question = questionProvider.selectedQuestion;

    if (question?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No question selected')),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Creating options from template...'),
            ],
          ),
        );
      },
    );

    // Call API to create options from template
    Provider.of<AnswerOptionProvider>(context, listen: false)
        .postAnswerOptionFromTemplate(
            templateId.toString(), question!.id.toString())
        .then((_) {
      // Close both dialogs
      Navigator.of(context).pop(); // Close loading dialog
      Navigator.of(context).pop(); // Close template selection sheet

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Options added from template')),
      );
    }).catchError((error) {
      // Close loading dialog
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    });
  }

  Future<void> _showOptionBottomSheet(BuildContext context,
      [AnswerOption? option]) async {
    final formKey = GlobalKey<FormState>();
    final textController = TextEditingController(text: option?.optionValue);

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
                    option == null ? 'Add New Option' : 'Edit Option',
                    style: Theme.of(context).textTheme.titleLarge,
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
                child: Column(
                  children: [
                    TextFieldWidget(
                      hintText: 'Enter option text',
                      controller: textController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter option text';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ButtonWidget(
                      onPressed: () => Navigator.pop(context),
                      text: 'Cancel',
                      isSecondary: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Consumer<AnswerOptionProvider>(
                      builder: (context, provider, child) {
                        final QuestionModel? question =
                            context.read<QuestionProvider>().selectedQuestion;

                        final Survey? survey =
                            context.read<SurveyProvider>().selectedSurvey;

                        return ButtonWidget(
                          onPressed: () {
                            if (formKey.currentState!.validate() &&
                                question != null) {
                              if (option == null) {
                                log('Creating answer option');
                                context
                                    .read<AnswerOptionProvider>()
                                    .createAnswerOption(
                                      AnswerOption(
                                        optionValue: textController.text,
                                        question: Question(
                                          id: question.id,
                                          childOrder: 1,
                                          surveyOrder: 1,
                                          survey: survey,
                                          questionType: question.questionType,
                                          text: question.text,
                                        ),
                                      ),
                                    );
                              } else {
                                context
                                    .read<AnswerOptionProvider>()
                                    .updateAnswerOption(
                                      AnswerOption(
                                        id: option.id,
                                        optionValue: textController.text,
                                        question: Question(
                                          id: question.id,
                                          childOrder: 1,
                                          surveyOrder: 1,
                                          survey: survey,
                                          questionType: question.questionType,
                                          text: question.text,
                                        ),
                                      ),
                                    );
                              }
                              Navigator.pop(context);
                            }
                          },
                          isLoading: provider.currentOptionResponse.isLoading,
                          text: option == null ? 'Add Option' : 'Save Changes',
                        );
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
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, AnswerOption option) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Answer Option'),
        content:
            const Text('Are you sure you want to delete this answer option?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AnswerOptionProvider>().deleteAnswerOption(
                  option.id.toString(), option.question!.id.toString());
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
