import 'package:flutter/material.dart';
import '../../models/question.dart';

class QuestionWidget extends StatefulWidget {
  final Question question;
  final bool isChild;
  final Function(Question) onAnswered;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.onAnswered,
    this.isChild = false,
  });

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.question.answer ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding:
            widget.isChild ? const EdgeInsets.all(15) : const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:
              widget.isChild ? Border.all(color: Colors.grey.shade200) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                widget.isChild
                    ? CircleAvatar(
                        child: Text(widget.question.id.toString()),
                      )
                    : const SizedBox.shrink(),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.question.text,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildQuestionContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionContent() {
    switch (widget.question.type) {
      case QuestionType.shortAnswer:
        return _buildShortAnswer();
      case QuestionType.multipleChoice:
        return _buildMultipleChoice();
      case QuestionType.parentChild:
        return _buildParentChild();
    }
  }

  Widget _buildShortAnswer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: _controller,
        maxLines: 4,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Enter your answer',
          hintStyle: TextStyle(color: Colors.grey),
        ),
        onChanged: (value) {
          widget.question.answer = value;
          widget.onAnswered(widget.question);
        },
      ),
    );
  }

  Widget _buildMultipleChoice() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.question.options?.length ?? 0,
      itemBuilder: (context, index) {
        final option = widget.question.options![index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              setState(() {
                for (var opt in widget.question.options!) {
                  opt.isSelected = opt.id == option.id;
                }
              });
              widget.onAnswered(widget.question);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: option.isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: option.isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: option.isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: option.isSelected
                        ? Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    option.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: option.isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.black87,
                      fontWeight: option.isSelected
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildParentChild() {
    return Column(
      children: [
        _buildMultipleChoice(),
        if (widget.question.options
                ?.any((opt) => opt.isSelected && opt.id == 'o1') ??
            false) ...[
          // const SizedBox(height: 24),
          ...widget.question.childQuestions?.map((childQuestion) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: QuestionWidget(
                    isChild: true,
                    question: Question(
                      id: childQuestion.id,
                      text: childQuestion.text,
                      type: childQuestion.type,
                      options: childQuestion.options,
                      answer: childQuestion.answer,
                    ),
                    onAnswered: (q) {
                      final index = widget.question.childQuestions!
                          .indexWhere((cq) => cq.id == q.id);
                      if (index != -1) {
                        widget.question.childQuestions![index].answer =
                            q.answer;
                        widget.question.childQuestions![index].options =
                            q.options;
                      }
                      widget.onAnswered(widget.question);
                    },
                  ),
                );
              }) ??
              [],
        ],
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
