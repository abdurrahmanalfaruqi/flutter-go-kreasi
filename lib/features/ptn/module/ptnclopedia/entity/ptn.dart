import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class PTN extends Equatable {
  final int? idPTN;
  String? namaPTN;
  final String? aliasPTN;
  final String? jenisPTN;

  PTN({
    this.idPTN,
    this.namaPTN,
    this.aliasPTN,
    this.jenisPTN,
  });

  @override
  List<Object> get props => [idPTN ?? 0, namaPTN ?? '', jenisPTN ?? '', aliasPTN ?? ''];
}
