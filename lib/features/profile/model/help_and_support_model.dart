class HelpAndSupportModel {
  final String email;
  final String subject;
  final String description;

  HelpAndSupportModel({
    required this.email,
    required this.subject,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'subject': subject,
      'description': description,
    };
  }
}
