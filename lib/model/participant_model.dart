import 'person_model.dart';

class ParticipantPagination {
  List<Participant>? content;
  Pageable? pageable;
  bool? last;
  int? totalPages;
  int? totalElements;
  bool? first;
  Sort? sort;
  int? numberOfElements;
  int? size;
  int? number;

  ParticipantPagination({
    this.content,
    this.pageable,
    this.last,
    this.totalPages,
    this.totalElements,
    this.first,
    this.sort,
    this.numberOfElements,
    this.size,
    this.number,
  });

  factory ParticipantPagination.fromJson(Map<String, dynamic> json) =>
      ParticipantPagination(
        content: json["content"] == null
            ? []
            : List<Participant>.from(
                json["content"]!.map((x) => Participant.fromJson(x))),
        pageable: json["pageable"] == null
            ? null
            : Pageable.fromJson(json["pageable"]),
        last: json["last"],
        totalPages: json["totalPages"],
        totalElements: json["totalElements"],
        first: json["first"],
        sort: json["sort"] == null ? null : Sort.fromJson(json["sort"]),
        numberOfElements: json["numberOfElements"],
        size: json["size"],
        number: json["number"],
      );
}

class Participant {
  int? id;
  Person? person;

  Participant({
    this.id,
    this.person,
  });

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
        id: json["id"],
        person: json["person"] == null ? null : Person.fromJson(json["person"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "person": person?.toJson(),
      };
}
