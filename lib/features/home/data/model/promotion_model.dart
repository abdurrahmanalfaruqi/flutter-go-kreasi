import 'package:gokreasi_new/core/config/extensions.dart';
import 'package:gokreasi_new/features/home/domain/entity/promotion.dart';

class PromotionModel extends Promotion {
  const PromotionModel({
    required super.linkImage,
    required super.linkPendaftaran,
    required super.tanggalKedaluarsa,
    required super.updatedAt,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) => PromotionModel(
        linkImage: json['link_image'] ?? '',
        linkPendaftaran: json['link_pendaftaran'] ?? '',
        tanggalKedaluarsa: (json['tanggal_kedaluarsa'] == null ||
                (json['tanggal_kedaluarsa'] as String).isEmpty)
            ? DateTime.now().serverTimeFromOffset
            : DateTime.parse(json['tanggal_kedaluarsa']),
        updatedAt: (json['updated_at'] != null)
            ? DateTime.parse(json['updated_at'])
            : DateTime.now().toUtc(),
      );

  Map<String, dynamic> toJson() => {
        'link_image': linkImage,
        'link_pendaftaran': linkPendaftaran,
        'tanggal_kedaluarsa': tanggalKedaluarsa.toString(),
        'updated_at': updatedAt.toString(),
      };
}
