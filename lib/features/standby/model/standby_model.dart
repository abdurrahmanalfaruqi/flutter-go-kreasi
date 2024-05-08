import '../entity/standby.dart';

class StandbyModel extends Standby {
  const StandbyModel(
      {required String date, required List<StandbyTeacherModel> teachers})
      : super(
          date: date,
          teachers: teachers,
        );

  factory StandbyModel.fromJson(Map<String, dynamic> json) => StandbyModel(
        date: json['tanggal'],
        teachers: (json['pengajar'] as List)
            .map((teacher) => StandbyTeacherModel.fromJson(teacher))
            .toList(),
      );
}

class StandbyTeacherModel extends StandbyTeacher {
  const StandbyTeacherModel({
    required String name,
    required String lesson,
    required int idMataPelajaran,
    required List<StandbyScheduleModel> schedule,
  }) : super(
          name: name,
          lesson: lesson,
          idMataPelajaran: idMataPelajaran,
          schedule: schedule,
        );

  factory StandbyTeacherModel.fromJson(Map<String, dynamic> json) {
    String nikPengajar = json['nik_pengajar'];
    return StandbyTeacherModel(
      name: json['nama_pengajar'],
      lesson: json['nama_mata_pelajaran'],
      idMataPelajaran: json['id_mata_pelajaran'],
      schedule: (json['jadwal'] as List)
          .map((schedule) =>
              StandbyScheduleModel.fromJson(schedule, nikPengajar))
          .toList(),
    );
  }
}

class StandbyScheduleModel extends StandbySchedule {
  const StandbyScheduleModel(
      {required String planId,
      String? activity,
      String? teacherId,
      String? buildingName,
      required String start,
      required String finish,
      required bool isTST,
      required bool available,
      required String registered})
      : super(
          planId: planId,
          activity: activity,
          teacherId: teacherId,
          buildingName: buildingName,
          start: start,
          finish: finish,
          isTST: isTST,
          available: available,
          registered: registered,
        );

  factory StandbyScheduleModel.fromJson(
          Map<String, dynamic> json, String nikPengajar) =>
      StandbyScheduleModel(
        planId:
            (json['id_rencana'] == null) ? '-' : json['id_rencana'].toString(),
        activity: json['nama_kegiatan'],
        teacherId: nikPengajar,
        buildingName: json['nama_gedung'],
        start: json['jam_awal'],
        finish: json['jam_akhir'],
        isTST: json['is_tst'] ?? false,
        available: json['ketersediaan'] ?? false,
        registered: json['terdaftar'],
      );
}
