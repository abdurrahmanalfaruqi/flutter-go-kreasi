import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/features/menu/entity/menu.dart';

class BukuSoal extends Equatable {
  final List<Menu>? listBukuPaket;
  final List<Menu>? listBukuSakti;

  const BukuSoal({this.listBukuPaket, this.listBukuSakti});

  @override
  List<Object?> get props => [listBukuPaket, listBukuSakti];
}
