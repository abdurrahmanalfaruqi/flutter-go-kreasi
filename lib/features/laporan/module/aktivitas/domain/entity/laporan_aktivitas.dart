import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/core/util/data_formatter.dart';

class LaporanAktivitas extends Equatable {
  final String id;
  final String menu;
  final String detail;
  final String masuk;
  final String keluar;

  const LaporanAktivitas({
    required this.id,
    required this.menu,
    required this.detail,
    required this.masuk,
    required this.keluar,
  });

  DateTime get masukDateTime => DataFormatter.stringToDate(masuk);

  DateTime get keluarDateTime => DataFormatter.stringToDate(keluar);

  @override
  List<Object> get props => [id, menu, detail, masuk, keluar];
}
