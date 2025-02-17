enum QuestionType {
  shortAnswer,
  multipleChoice,
  parentChild,
}

class Question {
  final String id;
  final String text;
  final QuestionType type;
  List<Option>? options;
  List<ChildQuestion>? childQuestions;
  String? answer;

  Question({
    required this.id,
    required this.text,
    required this.type,
    this.options,
    this.childQuestions,
    this.answer,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'type': type.toString(),
        'options': options?.map((e) => e.toJson()).toList(),
        'childQuestions': childQuestions?.map((e) => e.toJson()).toList(),
        'answer': answer,
      };

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'],
        text: json['text'],
        type: QuestionType.values.firstWhere(
            (e) => e.toString() == json['type'],
            orElse: () => QuestionType.shortAnswer),
        options: json['options'] == null
            ? null
            : List<Option>.from(json['options'].map((x) => Option.fromJson(x))),
        childQuestions: json['childQuestions'] == null
            ? null
            : List<ChildQuestion>.from(
                json['childQuestions'].map((x) => ChildQuestion.fromJson(x))),
        answer: json['answer'],
      );
}

class Option {
  final String id;
  final String text;
  bool isSelected;

  Option({
    required this.id,
    required this.text,
    this.isSelected = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isSelected': isSelected,
      };

  factory Option.fromJson(Map<String, dynamic> json) => Option(
        id: json['id'],
        text: json['text'],
        isSelected: json['isSelected'] ?? false,
      );
}

class ChildQuestion {
  final String id;
  final String text;
  final QuestionType type;
  List<Option>? options;
  String? answer;

  ChildQuestion({
    required this.id,
    required this.text,
    required this.type,
    this.options,
    this.answer,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'type': type.toString(),
        'options': options?.map((e) => e.toJson()).toList(),
        'answer': answer,
      };

  factory ChildQuestion.fromJson(Map<String, dynamic> json) => ChildQuestion(
        id: json['id'],
        text: json['text'],
        type: QuestionType.values.firstWhere(
            (e) => e.toString() == json['type'],
            orElse: () => QuestionType.shortAnswer),
        options: json['options'] == null
            ? null
            : List<Option>.from(json['options'].map((x) => Option.fromJson(x))),
        answer: json['answer'],
      );
}
