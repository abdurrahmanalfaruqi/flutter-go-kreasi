import 'package:equatable/equatable.dart';

class Promotion extends Equatable {
  final String linkImage;
  final DateTime tanggalKedaluarsa;

  /// [updatedAt] digunakan untuk mengecek kapan data di fetch
  final DateTime updatedAt;
  final String linkPendaftaran;

  const Promotion({
    required this.linkImage,
    required this.linkPendaftaran,
    required this.tanggalKedaluarsa,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        linkImage,
        tanggalKedaluarsa,
        linkPendaftaran,
        updatedAt,
      ];
}
