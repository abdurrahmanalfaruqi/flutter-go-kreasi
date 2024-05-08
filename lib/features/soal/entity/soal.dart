import 'package:equatable/equatable.dart';

/// [Soal] merupakan model dari tabel t\_Soal pada db\_banksoalV2.<br>
/// Kumpulan [Soal] didapat berdasarkan c\_IdBundel dari db\_banksoalV2.t\_IsiSoalBundel.
// ignore: must_be_immutable
class Soal extends Equatable {
  final String idSoal;
  final int nomorSoal;

  /// [nomorSoalSiswa] merupakan generate nomor soal untuk siswa.
  /// Didapat dari firebase.
  int nomorSoalSiswa;

  /// [textSoal] merupakan String Text Soal dengan format HTML.
  final String textSoal;

  /// [tingkatKesulitan] merupakan level kesulitan pada tiap soal (1-5).
  final int tingkatKesulitan;

  /// [tipeSoal] enum('PBS','PBK','PBCT','PBM','PBT','ESSAY','ESSAY MAJEMUK','PBB')
  final String tipeSoal;

  /// [opsi] merupakan json Jawaban (opsi, kunci, nilai)
  final String opsi;

  /// [idVideo] wacana pada soal.
  final String? idVideo;

  /// [idWacana] wacana pada soal.
  final String? idWacana;

  /// [wacana] merupakan wacana soal seperti cerita panjang.
  final String? wacana;

  /// [namaKelompokUjian] di gunakan untuk soal dengan Timer dan Paket
  final String namaKelompokUjian;

  /// [idKelompokUjian] di gunakan untuk soal dengan Timer dan Paket
  final String idKelompokUjian;

  /// [kodePaket] di gunakan untuk soal dengan Timer
  final String? kodePaket;

  /// [idBundle] di gunakan untuk soal dengan Timer
  final String? idBundle;

  /// [kodeBab] di gunakan untuk soal bundel
  final String? kodeBab;

  /// [kunciJawaban] di generate saat getDaftarSoal
  final dynamic kunciJawaban;

  /// [translatorEPB] di generate saat getDaftarSoal.
  /// Berfungsi sebagai bahan tranlate json soal ke [kunciJawabanEPB].
  final dynamic translatorEPB;

  /// [kunciJawabanEPB] di generate saat getDaftarSoal.
  /// Berfungsi sebagai display kunci jawaban pada EPB
  final dynamic kunciJawabanEPB;

  /// [isReportSubmitted] digunakan untuk mengecek apakah report masalah soal
  /// sudah disubmit
  bool isReportSubmitted;

  // Mutable variable
  String initial;
  double nilai;
  bool isBookmarked;
  bool isRagu;
  bool sudahDikumpulkan;
  int? kesempatanMenjawab;
  dynamic jawabanSiswa;
  dynamic jawabanSiswaEPB;
  String? lastUpdate;

  /// [validateTipeSoal] digunakan untuk memastikan tipe soal sesuai type datanya.
  /// <br><br> Supaya menghindari gagal ketika submit soal di BE.
  bool validateTipeSoal(dynamic jawabanSiswa) {
    switch (tipeSoal) {
      case 'PGB':
        return jawabanSiswa is String;
      case 'PBK':
        return jawabanSiswa is List<String>;
      case 'PBCT':
        return jawabanSiswa is List<String>;
      case 'PBM':
        return jawabanSiswa is List<int>;
      case 'PBT':
        return jawabanSiswa is List<int>;
      case 'PBB':
        return jawabanSiswa is Map<String, dynamic>;
      case 'ESSAY':
        return jawabanSiswa is String;
      case 'ESSAY MAJEMUK':
        return jawabanSiswa is List<String>;
      default:
        return jawabanSiswa is String;
    }
  }

  Soal({
    required this.idSoal,
    required this.nomorSoal,
    required this.nomorSoalSiswa,
    required this.textSoal,
    required this.tingkatKesulitan,
    required this.tipeSoal,
    required this.initial,
    required this.opsi,
    required this.kunciJawaban,
    required this.translatorEPB,
    required this.kunciJawabanEPB,
    this.idVideo,
    this.idWacana,
    this.wacana,
    required this.idKelompokUjian,
    required this.namaKelompokUjian,
    required this.isReportSubmitted,
    this.kodePaket,
    this.idBundle,
    this.kodeBab,
    this.nilai = 0,
    this.kesempatanMenjawab,
    this.isBookmarked = false,
    this.isRagu = false,
    this.sudahDikumpulkan = false,
    this.jawabanSiswa,
    this.jawabanSiswaEPB,
    this.lastUpdate,
  });

  Soal copyWith({
    String? idSoal,
    int? nomorSoal,
    int? nomorSoalSiswa,
    String? textSoal,
    int? tingkatKesulitan,
    String? tipeSoal,
    String? initial,
    String? opsi,
    dynamic kunciJawaban,
    dynamic translatorEPB,
    dynamic kunciJawabanEPB,
    String? idVideo,
    String? idWacana,
    String? wacana,
    String? idKelompokUjian,
    String? namaKelompokUjian,
    String? kodePaket,
    String? idBundle,
    String? kodeBab,
    double? nilai,
    int? kesempatanMenjawab,
    bool? isBookmarked,
    bool? isRagu,
    bool? sudahDikumpulkan,
    dynamic jawabanSiswa,
    dynamic jawabanSiswaEPB,
    String? lastUpdate,
    bool? isReportSubmitted,
  }) =>
      Soal(
        idSoal: idSoal ?? this.idSoal,
        nomorSoal: nomorSoal ?? this.nomorSoal,
        nomorSoalSiswa: nomorSoalSiswa ?? this.nomorSoalSiswa,
        textSoal: textSoal ?? this.textSoal,
        tingkatKesulitan: tingkatKesulitan ?? this.tingkatKesulitan,
        tipeSoal: tipeSoal ?? this.tipeSoal,
        initial: initial ?? this.initial,
        opsi: opsi ?? this.opsi,
        kunciJawaban: kunciJawaban ?? this.kunciJawaban,
        translatorEPB: translatorEPB ?? this.translatorEPB,
        kunciJawabanEPB: kunciJawabanEPB ?? this.kunciJawabanEPB,
        idKelompokUjian: idKelompokUjian ?? this.idKelompokUjian,
        namaKelompokUjian: namaKelompokUjian ?? this.namaKelompokUjian,
        idBundle: idBundle ?? this.idBundle,
        idVideo: idVideo ?? this.idVideo,
        idWacana: idWacana ?? this.idWacana,
        isBookmarked: isBookmarked ?? this.isBookmarked,
        isRagu: isRagu ?? this.isRagu,
        jawabanSiswa: jawabanSiswa ?? this.jawabanSiswa,
        jawabanSiswaEPB: jawabanSiswaEPB ?? this.jawabanSiswaEPB,
        kesempatanMenjawab: kesempatanMenjawab ?? this.kesempatanMenjawab,
        kodeBab: kodeBab ?? this.kodeBab,
        kodePaket: kodePaket ?? this.kodePaket,
        lastUpdate: lastUpdate ?? this.lastUpdate,
        nilai: nilai ?? this.nilai,
        sudahDikumpulkan: sudahDikumpulkan ?? this.sudahDikumpulkan,
        wacana: wacana ?? this.wacana,
        isReportSubmitted: isReportSubmitted ?? this.isReportSubmitted,
      );

  @override
  List<Object?> get props => [
        idSoal,
        nomorSoal,
        initial,
        textSoal,
        tingkatKesulitan,
        tipeSoal,
        opsi,
        kunciJawaban,
        translatorEPB,
        kunciJawabanEPB,
        kodePaket,
        idBundle,
        idVideo,
        idWacana,
        wacana,
        idKelompokUjian,
        namaKelompokUjian,
      ];
}
