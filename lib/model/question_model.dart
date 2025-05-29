



import 'survey_model.dart';

class Question {
   int? id;
   String? section;
   int? childOrder;
   int? surveyOrder;
   Survey? survey;
   QuestionType? questionType;
   ParentQuestion? parentQuestion;
   String? text;

  Question({
    this.id,
    this.section,
    this.childOrder,
    this.surveyOrder,
    this.survey,
    this.questionType,
    this.text,
    this.parentQuestion,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int?,
      text: json['text'] as String?,
      section: json['section'] as String?,
      childOrder: json['childOrder'] as int?,
      surveyOrder: json['surveyOrder'] as int?,
      survey: json['survey'] != null ? Survey.fromJson(json['survey'] as Map<String, dynamic>) : null,
      questionType: json['questionType'] != null ? QuestionType.fromJson(json['questionType'] as Map<String, dynamic>) : null,
      parentQuestion: json['parentQuestion'] != null ? ParentQuestion.fromJson(json['parentQuestion'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section': section,
      'text': text,
      'childOrder': childOrder,
      'surveyOrder': surveyOrder,
      'survey': survey?.toJson(),
      'questionType': questionType?.toJson(),
      'parentQuestion': parentQuestion?.toJson(),
    };
  }
}

class ParentQuestion {
  final int? id;
  final String? section;

  ParentQuestion({
    this.id,
    this.section,
  });

  factory ParentQuestion.fromJson(Map<String, dynamic> json) {
    return ParentQuestion(
      id: json['id'] as int?,
      section: json['section'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section': section,
    };
  }
}

class QuestionType {
  final int? id;
  final String? questionType;

  QuestionType({
    this.id,
    this.questionType,
  });

  factory QuestionType.fromJson(Map<String, dynamic> json) {
    return QuestionType(
      id: json['id'] as int?,
      questionType: json['questionType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionType': questionType,
    };
  }
}


class QuestionModel {
  int? id;
  int? surveyId;
  QuestionType? questionType;
  List<QuestionModel>? children;
  String? text;
  
  QuestionModel({
    this.id,
    this.surveyId,
    this.questionType,
    this.children,
    this.text,
  });
}