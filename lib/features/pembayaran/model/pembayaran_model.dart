import '../entity/pembayaran.dart';
import '../../../core/util/data_formatter.dart';

class PembayaranModel extends Pembayaran {
  const PembayaranModel({
    required String id,
    required String total,
    required String current,
    required String remaining,
    required String status,
    String? message,
    DateTime? jatuhTempo,
  }) : super(
          id: id,
          total: total,
          current: current,
          remaining: remaining,
          status: status,
          message: message,
          jatuhTempo: jatuhTempo,
        );

  factory PembayaranModel.fromJson(Map<String, dynamic> json) =>
      PembayaranModel(
        id: json['id'].toString(),
        total: json['total'].toString(),
        current: json['current'].toString(),
        remaining: json['remaining'].toString(),
        status: json['status'],
        message: json['message'],
        jatuhTempo: (json['jatuhTempo'] != null && json['jatuhTempo'] != '')
            ? DataFormatter.stringToDate(json['jatuhTempo'], 'yyy-MM-dd')
            : null,
      );
}
