import 'package:equatable/equatable.dart';

class Berita extends Equatable {
  final String id;
  final String title;
  final String description;
  final String image;
  final String date;
  final String url;
  final String summary;
  final String viewer;

  const Berita({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.date,
    required this.url,
    required this.summary,
    required this.viewer,
  });

  Berita copyWith({
    String? id,
    String? title,
    String? description,
    String? image,
    String? date,
    String? url,
    String? summary,
    String? viewer,
  }) =>
      Berita(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        image: image ?? this.image,
        date: date ?? this.date,
        url: url ?? this.url,
        summary: summary ?? this.summary,
        viewer: viewer ?? this.viewer,
      );

  @override
  List<Object> get props => [
        id,
        title,
        description,
        image,
        date,
        url,
        summary,
        viewer,
      ];
}
