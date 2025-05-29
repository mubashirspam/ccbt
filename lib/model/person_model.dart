class PersonPagination {
  List<Person>? content;
  Pageable? pageable;
  bool? last;
  int? totalPages;
  int? totalElements;
  bool? first;
  Sort? sort;
  int? numberOfElements;
  int? size;
  int? number;

  PersonPagination({
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

  factory PersonPagination.fromJson(Map<String, dynamic> json) =>
      PersonPagination(
        content: json["content"] == null
            ? []
            : List<Person>.from(
                json["content"]!.map((x) => Person.fromJson(x))),
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

class Pageable {
  Sort? sort;
  int? pageSize;
  int? pageNumber;
  int? offset;
  bool? unpaged;
  bool? paged;

  Pageable({
    this.sort,
    this.pageSize,
    this.pageNumber,
    this.offset,
    this.unpaged,
    this.paged,
  });

  // Add copyWith method to create a new instance with updated values
  Pageable copyWith({
    Sort? sort,
    int? pageSize,
    int? pageNumber,
    int? offset,
    bool? unpaged,
    bool? paged,
  }) {
    return Pageable(
      sort: sort ?? this.sort,
      pageSize: pageSize ?? this.pageSize,
      pageNumber: pageNumber ?? this.pageNumber,
      offset: offset ?? this.offset,
      unpaged: unpaged ?? this.unpaged,
      paged: paged ?? this.paged,
    );
  }

  factory Pageable.fromJson(Map<String, dynamic> json) => Pageable(
        sort: json["sort"] == null ? null : Sort.fromJson(json["sort"]),
        pageSize: json["pageSize"],
        pageNumber: json["pageNumber"],
        offset: json["offset"],
        unpaged: json["unpaged"],
        paged: json["paged"],
      );
}

class Sort {
  bool? sorted;
  bool? unsorted;

  Sort({
    this.sorted,
    this.unsorted,
  });

  factory Sort.fromJson(Map<String, dynamic> json) => Sort(
        sorted: json["sorted"],
        unsorted: json["unsorted"],
      );
}

class Person {
  int? id;
  String? email;
  String? firstName;
  String? lastName;
  String? phone;

  Person({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
  });

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        id: json["id"],
        email: json["email"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        phone: json["phone"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
        "phone": phone,
      };
}
