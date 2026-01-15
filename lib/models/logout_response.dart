class LogoutResponse {
  final String message;
  final String httpStatus;

  LogoutResponse({required this.message, required this.httpStatus});

  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(
      message: json['message'],
      httpStatus: json['httpStatus'],
    );
  }
}
