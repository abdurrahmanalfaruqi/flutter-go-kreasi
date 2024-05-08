import 'package:equatable/equatable.dart';

class PengerjaanSoal extends Equatable {
  final int idMapel;
  final int targetHarian;
  final int pengerjaanHarian;
  final int benarHarian;
  final int salahHarian;
  final int targetMingguan;
  final int pengerjaanMingguan;
  final int benarMingguan;
  final int salahMingguan;
  final int targetBulanan;
  final int pengerjaanBulanan;
  final int benarBulanan;
  final int salahBulanan;
  final String nama;
  final String initial;

  const PengerjaanSoal({
    required this.idMapel,
    required this.targetHarian,
    required this.pengerjaanHarian,
    required this.benarHarian,
    required this.salahHarian,
    required this.targetMingguan,
    required this.pengerjaanMingguan,
    required this.benarMingguan,
    required this.salahMingguan,
    required this.targetBulanan,
    required this.pengerjaanBulanan,
    required this.benarBulanan,
    required this.salahBulanan,
    required this.nama,
    required this.initial
  });

  //             "benarharian": "0",
  //             "salahharian": "0",
  //             "benarmingguan": "0",
  //             "salahmingguan": "0",
  //             "benarbulanan": "0",
  //             "salahbulanan": "0"
  //         },
  //
  factory PengerjaanSoal.fromJson(Map<String, dynamic> json) => PengerjaanSoal(
        idMapel: (json['id_kelompok_ujian'] is int)
            ? json['id_kelompok_ujian']
            : (json['id_kelompok_ujian'] == null)
                ? 0
                : int.tryParse(json['id_kelompok_ujian'].toString()) ?? 0,
        targetHarian: (json['targethari'] is int)
            ? json['targethari']
            : (json['targethari'] == null)
                ? 0
                : int.tryParse(json['targethari'].toString()) ?? 0,
        pengerjaanHarian: (json['pengerjaan_harian'] is int)
            ? json['pengerjaan_harian']
            : (json['pengerjaan_harian'] == null)
                ? 0
                : int.tryParse(json['pengerjaan_harian'].toString()) ?? 0,
        benarHarian: (json['benar_harian'] is int)
            ? json['benar_harian']
            : (json['benar_harian'] == null)
                ? 0
                : int.tryParse(json['benar_harian'].toString()) ?? 0,
        salahHarian: (json['salah_harian'] is int)
            ? json['salah_harian']
            : (json['salah_harian'] == null)
                ? 0
                : int.tryParse(json['salah_harian'].toString()) ?? 0,
        targetMingguan: (json['targetminggu'] is int)
            ? json['targetminggu']
            : (json['targetminggu'] == null)
                ? 0
                : int.tryParse(json['targetminggu'].toString()) ?? 0,
        pengerjaanMingguan: (json['pengerjaan_mingguan'] is int)
            ? json['pengerjaan_mingguan']
            : (json['pengerjaan_mingguan'] == null)
                ? 0
                : int.tryParse(json['pengerjaan_mingguan'].toString()) ?? 0,
        benarMingguan: (json['benar_mingguan'] is int)
            ? json['benar_mingguan']
            : (json['benar_mingguan'] == null)
                ? 0
                : int.tryParse(json['benar_mingguan'].toString()) ?? 0,
        salahMingguan: (json['salah_mingguan'] is int)
            ? json['salah_mingguan']
            : (json['salah_mingguan'] == null)
                ? 0
                : int.tryParse(json['salah_mingguan'].toString()) ?? 0,
        targetBulanan: (json['targetbulan'] is int)
            ? json['targetbulan']
            : (json['targetbulan'] == null)
                ? 0
                : int.tryParse(json['targetbulan'].toString()) ?? 0,
        pengerjaanBulanan: (json['pengerjaan_bulanan'] is int)
            ? json['pengerjaan_bulanan']
            : (json['pengerjaan_bulanan'] == null)
                ? 0
                : int.tryParse(json['pengerjaan_bulanan'].toString()) ?? 0,
        benarBulanan: (json['benar_bulanan'] is int)
            ? json['benar_bulanan']
            : (json['benar_bulanan'] == null)
                ? 0
                : int.tryParse(json['benar_bulanan'].toString()) ?? 0,
        salahBulanan: (json['salah_bulanan'] is int)
            ? json['salah_bulanan']
            : (json['salah_bulanan'] == null)
                ? 0
                : int.tryParse(json['salah_bulanan'].toString()) ?? 0,
                nama: json['nama_kelompok_ujian'],
                initial: json['singkatan']
      );

  @override
  List<Object?> get props => [
        idMapel,
        targetHarian,
        pengerjaanHarian,
        targetMingguan,
        pengerjaanMingguan,
        targetBulanan,
        pengerjaanBulanan,
      ];
}
