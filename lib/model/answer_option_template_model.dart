

class AnswerOptionTemplateItem {
    int? id;
    String? answerOption;
    AnswerOptionTemplate? answerOptionTemplate;

    AnswerOptionTemplateItem({
        this.id,
        this.answerOption,
        this.answerOptionTemplate,
    });

    factory AnswerOptionTemplateItem.fromJson(Map<String, dynamic> json) => AnswerOptionTemplateItem(
        id: json["id"],
        answerOption: json["answerOption"],
        answerOptionTemplate: json["answerOptionTemplate"] == null ? null : AnswerOptionTemplate.fromJson(json["answerOptionTemplate"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "answerOption": answerOption,
        "answerOptionTemplate": answerOptionTemplate?.toJson(),
    };
}

class AnswerOptionTemplate {
    int? id;
    String? answerOptionTemplate;

    AnswerOptionTemplate({
        this.id,
        this.answerOptionTemplate,
    });

    factory AnswerOptionTemplate.fromJson(Map<String, dynamic> json) => AnswerOptionTemplate(
        id: json["id"],
        answerOptionTemplate: json["answerOptionTemplate"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "answerOptionTemplate": answerOptionTemplate,
    };
}
