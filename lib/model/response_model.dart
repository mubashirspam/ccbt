

import 'participant_model.dart';
import 'survey_model.dart';

class ResponseModel {
    int? id;
    int? linkId;
    Survey? survey;
    Participant? participant;

    ResponseModel({
        this.id,
        this.linkId,
        this.survey,
        this.participant,
    });

    factory ResponseModel.fromJson(Map<String, dynamic> json) => ResponseModel(
        id: json["id"],
        linkId: json["linkId"],
        survey: json["survey"] == null ? null : Survey.fromJson(json["survey"]),
        participant: json["participant"] == null ? null : Participant.fromJson(json["participant"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "linkId": linkId,
        "survey": survey?.toJson(),
        "participant": participant?.toJson(),
    };
}

