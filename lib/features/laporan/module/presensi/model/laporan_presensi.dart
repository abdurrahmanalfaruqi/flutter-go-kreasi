class LaporanPresensiDate {
  /// [date] merupakan variabel yang berisi tanggal presensi siswa.
  final String date;

  /// [listPresences] variabel untuk menampung data informasi ekstra dari presensi tersebut.
  final List<LaporanPresensiInfo> listPresences;

  /// [feedbackCount] merupakan variabel yang berisi jumlah feedback yang belum disubmit.
  int get feedbackCount => listPresences
      .where((presence) => presence.feedbackPermission == true)
      .length;

  LaporanPresensiDate({
    required this.date,
    required this.listPresences,
  });

  factory LaporanPresensiDate.fromJson(Map<String, dynamic> json) =>
      LaporanPresensiDate(
        date: json['tanggal'],
        listPresences: (json['list_presensi'] as List)
            .map((presence) => LaporanPresensiInfo.fromJson(presence))
            .toList(),
      );
}

class LaporanPresensiInfo {
  /// [planId] variabel yang berisi data rencana kerja.
  final String? planId;

  /// [classId] variabel yang berisi data id Kelas GO sesuai dengan id Kelas GO yang ada pada QR Presensi.
  final String? classId;

  /// [className] variabel yang berisi data nama Kelas GO.
  final String? className;

  /// [studentClassId] variabel yang berisi data id Kelas GO sesuai dengan id kelas dibeli.
  final String? studentClassId;

  /// [flag] variabel yang berisi keterangan (sama/tidak sama) berdasarkan data dari [classId] dan [studentClassId]
  final String? flag;

  /// [date] variabel yang berisi data tanggal dari kelas tersebut.
  final String? date;

  /// [presenceTime] variabel yang berisi data jadwal melakukan presensi.
  final String? presenceTime;

  /// [teacherId] variabel yang berisi data NIK pengajar.
  final String? teacherId;

  /// [teacherName] variabel yang berisi data nama pengajar.
  final String? teacherName;

  /// [scheduleStart] variabel yang berisi data jadwal mulai.
  final String? scheduleStart;

  /// [scheduleFinish] variabel yang berisi data jadwal akhir.
  final String? scheduleFinish;

  /// [buildingName] variabel yang berisi data nama gedung.
  final String? buildingName;

  /// [session] variabel yang berisi data sesi pembelajaran.
  final String? session;

  /// [lesson] variabel yang berisi data nama kelompok uji.
  final String? lesson;

  /// [activity] variabel yang berisi data jenis aktivitas.
  final String? activity;

  /// [isFeedback] variabel yang berisi data boolean untuk menentukan apakah sudah feedback atau belum.
  final bool? isFeedback;

  /// [feedbackPermission] variabel yang berisi data boolean untuk menentukan apakah masih bisa melakukan feedback atau tidak.
  final bool? feedbackPermission;

  LaporanPresensiInfo({
    this.planId,
    this.classId,
    this.className,
    this.studentClassId,
    this.flag,
    this.date,
    this.presenceTime,
    this.teacherId,
    this.teacherName,
    this.scheduleStart,
    this.scheduleFinish,
    this.buildingName,
    this.session,
    this.lesson,
    this.activity,
    this.isFeedback,
    this.feedbackPermission,
  });

  factory LaporanPresensiInfo.fromJson(Map<String, dynamic> json) {
    return LaporanPresensiInfo(
      planId: json['id_rencana'].toString(),
      classId: json['id_kelas'] == null ? "-" : json['id_kelas'].toString(),
      className: json['nama_kelas'] ?? "-",
      studentClassId: json['id_kelas_siswa'] == null
          ? "-"
          : json['id_kelas_siswa'].toString(),
      flag: json['flag_kelas'] ?? "-",
      date: json['tanggal'] ?? "-",
      presenceTime: json['waktu_kehadiran'] ?? "-",
      teacherId: json['nik_pengajar'] ?? "-",
      teacherName: json['nama_pengajar'] ?? "-",
      scheduleStart: (json['jam_awal_kbm'] == null) ? null : json['jam_awal_kbm'],
      scheduleFinish: (json['jam_akhir_kbm'] == null) ? null : json['jam_akhir_kbm'],
      buildingName: json['nama_gedung'] ?? "-",
      session: json['sesi'] == null ? "-" : json['sesi'].toString(),
      lesson: json['nama_kelompok_ujian'] ?? "-",
      activity: json['nama_kegiatan'] ?? "Responsi",
      isFeedback: json['is_feedback'],
      feedbackPermission: json['ijin_feedback'],
    );
  }
}
