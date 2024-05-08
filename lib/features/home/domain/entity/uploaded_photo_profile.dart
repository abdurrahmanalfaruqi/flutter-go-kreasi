class UploadedPhotoProfile {
  final String? name;
  final String? link;

  const UploadedPhotoProfile({
    required this.name,
    required this.link,
  });

  factory UploadedPhotoProfile.fromJson(Map<String, dynamic> json) =>
      UploadedPhotoProfile(
        name: json['name'],
        link: json['link'],
      );
}
