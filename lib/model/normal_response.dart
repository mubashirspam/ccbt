class NormalResponse {
  final bool isSuccess;
  final String? message;
  dynamic data;

  NormalResponse({
    required this.isSuccess,
    required this.message,
    this.data,
  });
}
