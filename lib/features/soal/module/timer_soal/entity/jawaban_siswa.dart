import 'package:equatable/equatable.dart';

class JawabanSiswa extends Equatable {
  final String idSoal;
  final dynamic jawabanSiswa;
  final bool isRagu;
  final String tipeSoal;

  const JawabanSiswa({
    required this.idSoal,
    required this.jawabanSiswa,
    required this.isRagu,
    required this.tipeSoal,
  });

  @override
  List<Object?> get props => [idSoal, jawabanSiswa, isRagu, tipeSoal];
}
