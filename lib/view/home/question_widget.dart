import 'dart:developer';

import 'package:ccbt_survey/provider/answer_option_provider.dart';
import 'package:ccbt_survey/view/widgets/button_widget.dart';
import 'package:ccbt_survey/view/widgets/textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/question_provider.dart';
import '../../model/model.dart';
import '../../provider/survey_provider.dart';

class QuestionWidget extends StatefulWidget {
  const QuestionWidget({super.key});

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  @override
  void initState() {
    super.initState();
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
                  "Questions",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Consumer<QuestionProvider>(builder: (context, provider, child) {
                  return TextButton.icon(
                    label: Text('Add Question'),
                    onPressed: !provider.questionsBySurveyResponse.isSuccess
                        ? null
                        : () {
                            _showQuestionBottomSheet(
                              context,
                            );
                          },
                    icon: Icon(Icons.add),
                    style: TextButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  );
                })
              ],
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            child: Consumer<QuestionProvider>(
              builder: (context, provider, child) {
                if (provider.questionsBySurveyResponse.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.questionsBySurveyResponse.isError) {
                  return Center(
                    child: Text(
                      provider.questionsBySurveyResponse.error ??
                          'An error occurred',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final questions = provider.questionsBySurveyResponse.data ?? [];

                if (questions.isEmpty) {
                  return const Center(
                    child: Text('No questions available'),
                  );
                }

                return ListView.builder(
                  itemCount: questions.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: provider.selectedQuestionId == question.id
                              ? question.children?.isNotEmpty ?? false
                                  ? Colors.transparent
                                  : Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.primaryContainer,
                        ),
                      ),
                      color: provider.selectedQuestionId == question.id
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerLow,
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: question.questionType?.id == 2
                          ? ExpansionTile(
                              collapsedBackgroundColor: Theme.of(context)
                                  .colorScheme
                                  .tertiaryContainer,
                              collapsedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: Text(question.text ?? 'Untitled Question'),
                              subtitle: Text(
                                question.questionType?.questionType ??
                                    'Unknown',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: PopupMenuButton(
                                icon: Icon(Icons.more_vert,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                    onTap: () => _showQuestionBottomSheet(
                                        parentQuestionId: question.id,
                                        context,
                                        question: question),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                    onTap: () => _showDeleteConfirmation(
                                        context, question),
                                  ),
                                  PopupMenuItem(
                                    value: 'duplicate',
                                    child: Text('Duplicate'),
                                    onTap: () =>
                                        _duplicateQuestion(context, question),
                                  ),
                                  PopupMenuItem(
                                    value: 'Add Child',
                                    child: Text('Add Child'),
                                    onTap: () => _showQuestionBottomSheet(
                                        context,
                                        parentQuestionId: question.id),
                                  ),
                                ],
                              ),
                              onExpansionChanged: (expanded) {
                                if (expanded) {
                                  context
                                      .read<QuestionProvider>()
                                      .selectedQuestionId = question.id!;
                                  context
                                      .read<AnswerOptionProvider>()
                                      .fetchAnswerOptionByQuestion(
                                          question.id.toString());
                                }
                              },
                              backgroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              childrenPadding: EdgeInsets.only(top: 10),
                              children: question.children!.map((childQuestion) {
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: provider.selectedChildQuestionId ==
                                              childQuestion.id
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                    ),
                                  ),
                                  color: provider.selectedChildQuestionId ==
                                          childQuestion.id
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                      : Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerLow,
                                  elevation: 0,
                                  margin:
                                      const EdgeInsets.all(10).copyWith(top: 0),
                                  child: ListTile(
                                    onTap: () {
                                      context
                                              .read<QuestionProvider>()
                                              .selectedChildQuestionId =
                                          childQuestion.id!;
                                      context
                                          .read<AnswerOptionProvider>()
                                          .fetchAnswerOptionByQuestion(
                                              childQuestion.id.toString());
                                    },
                                    title: Text(childQuestion.text ??
                                        'Untitled Question'),
                                    subtitle: Text(
                                      childQuestion
                                              .questionType?.questionType ??
                                          'Unknown',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                        fontSize: 12,
                                      ),
                                    ),
                                    trailing: PopupMenuButton(
                                      icon: Icon(Icons.more_vert,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit'),
                                          onTap: () => _showQuestionBottomSheet(
                                              context,
                                              parentQuestionId: question.id,
                                              question: childQuestion),
                                        ),
                                        PopupMenuItem(
                                          value: 'duplicate',
                                          child: Text('Duplicate'),
                                          onTap: () => _duplicateQuestion(
                                              context, childQuestion),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete'),
                                          onTap: () => _showDeleteConfirmation(
                                              context, childQuestion),
                                        ),
                                      ],
                                      onSelected: (value) {},
                                    ),
                                  ),
                                );
                              }).toList())
                          : ListTile(
                              onTap: () {
                                context
                                    .read<QuestionProvider>()
                                    .selectedQuestionId = question.id!;
                                context
                                    .read<AnswerOptionProvider>()
                                    .fetchAnswerOptionByQuestion(
                                        question.id.toString());
                              },
                              title: Text(question.text ?? 'Untitled Question'),
                              subtitle: Text(
                                question.questionType?.questionType ??
                                    'Unknown',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: PopupMenuButton(
                                icon: Icon(Icons.more_vert,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: const Text('Edit'),
                                  ),
                                  PopupMenuItem(
                                    value: 'duplicate',
                                    child: const Text('Duplicate'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: const Text('Delete'),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showQuestionBottomSheet(
                                      context,
                                      question: question,
                                    );
                                  } else if (value == 'duplicate') {
                                    _duplicateQuestion(context, question);
                                  } else if (value == 'delete') {
                                    _showDeleteConfirmation(
                                      context,
                                      question,
                                    );
                                  }
                                },
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

  Future<void> _showQuestionBottomSheet(BuildContext context,
      {int? parentQuestionId, QuestionModel? question}) async {
    final formKey = GlobalKey<FormState>();
    final questionController = TextEditingController(text: question?.text);
    String selectedQuestionType = question?.questionType?.questionType ?? 'MCQ';

    final questionTypes = [
      {'id': 1, 'questionType': 'MCQ'},
      {'id': 2, 'questionType': 'ParentQuestion'},
      {'id': 3, 'questionType': 'LongAnswer'},
    ];

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
                    question == null ? 'Add Question' : 'Edit Question',
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
                child: Column(
                  children: [
                    TextFieldWidget(
                      hintText: 'Enter question text',
                      controller: questionController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a question';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          value: selectedQuestionType,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Question Type',
                          ),
                          items: questionTypes.map((type) {
                            return DropdownMenuItem<String>(
                              value: type['questionType'].toString(),
                              child: Text(type['questionType']!.toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            selectedQuestionType = value!;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a question type';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ButtonWidget(
                      isSecondary: true,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      text: 'Cancel',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Consumer<QuestionProvider>(
                      builder: (context, provider, child) {
                        return ButtonWidget(
                          onPressed: () {
                            final selectedSurvey =
                                context.read<SurveyProvider>().selectedSurvey;
                            if (formKey.currentState!.validate()) {
                              if (question == null) {
                                context.read<QuestionProvider>().createQuestion(
                                      Question(
                                        text: questionController.text,
                                        childOrder: 0,
                                        surveyOrder: 0,
                                        survey: selectedSurvey,
                                        parentQuestion: parentQuestionId == null
                                            ? null
                                            : ParentQuestion(
                                                id: parentQuestionId,
                                              ),
                                        questionType: QuestionType(
                                          id: questionTypes.firstWhere((type) =>
                                                  type['questionType'] ==
                                                  selectedQuestionType)['id']
                                              as int,
                                          questionType: selectedQuestionType,
                                        ),
                                      ),
                                    );
                              } else {
                                context.read<QuestionProvider>().updateQuestion(
                                      Question(
                                        id: question.id,
                                        text: questionController.text,
                                        childOrder: 0,
                                        surveyOrder: 0,
                                        survey: selectedSurvey,
                                        parentQuestion: parentQuestionId == null
                                            ? null
                                            : ParentQuestion(
                                                id: parentQuestionId,
                                              ),
                                        questionType: QuestionType(
                                          id: questionTypes.firstWhere((type) =>
                                                  type['questionType'] ==
                                                  selectedQuestionType)['id']
                                              as int,
                                          questionType: selectedQuestionType,
                                        ),
                                      ),
                                    );
                              }
                              Navigator.pop(context);
                            }
                          },
                          isLoading: provider.currentQuestionResponse.isLoading,
                          text: question == null
                              ? 'Add Question'
                              : 'Save Changes',
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
      BuildContext context, QuestionModel question) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<QuestionProvider>().deleteQuestion(
                  question.id.toString(), question.surveyId.toString());
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _duplicateQuestion(
      BuildContext context, QuestionModel question) async {
    // Store providers needed for async operations to avoid context usage across async gaps
    final questionProvider = context.read<QuestionProvider>();
    final answerOptionProvider = context.read<AnswerOptionProvider>();
    final selectedSurvey = context.read<SurveyProvider>().selectedSurvey;
    final themeData = Theme.of(context);

    // Create the question
    await questionProvider.createQuestion(
      Question(
        text: '${question.text} (Copy)',
        survey: selectedSurvey,
        questionType: question.questionType != null
            ? QuestionType(
                id: question.questionType!.id,
                questionType: question.questionType!.questionType,
              )
            : QuestionType(id: 1, questionType: 'MCQ'),
      ),
    );
    final questionValue = questionProvider.currentQuestionResponse.data;

    if (questionValue != null &&
        questionValue.questionType?.id == 1 &&
        question.id != null) {
      final optionValue =
          await answerOptionProvider.fetchAnswerOptionByQuestion(
        question.id.toString(),
        isDuplicate: true,
      );

      if (optionValue != null && questionValue.questionType?.id == 1) {
        for (var option in optionValue) {
          log(option.optionValue.toString());
          final newOption = AnswerOption(
            optionValue: option.optionValue,
            question: Question(
              id: questionValue.id,
              questionType: QuestionType(
                id: questionValue.questionType?.id,
              ),
            ),
          );
          await answerOptionProvider.createAnswerOption(newOption);
        }
      }
    }

    // Only access context if the widget is still mounted
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Question duplicated successfully!'),
          backgroundColor: themeData.colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
