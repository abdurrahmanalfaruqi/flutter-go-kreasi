import 'package:equatable/equatable.dart';

class AppVersion extends Equatable {
  final String url;
  final String altUrl;
  final String version;
  final int versionNumber;
  final int buildNumber;

  const AppVersion({
    required this.url,
    required this.altUrl,
    required this.version,
    required this.versionNumber,
    required this.buildNumber,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) => AppVersion(
        url: json['url'],
        altUrl: json['altUrl'],
        version: json['version'],
        versionNumber: json['versionNumber'],
        buildNumber: json['buildNumber'],
      );

  @override
  List<Object?> get props => [
        url,
        altUrl,
        version,
        buildNumber,
      ];
}
