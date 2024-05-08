part of 'pilih_anak_bloc.dart';

class PilihAnakEvent extends Equatable {
  const PilihAnakEvent();

  @override
  List<Object> get props => [];
}

class GetAnakList extends PilihAnakEvent {
  final bool isRefresh;
  final String nomorHpOrtu;
  const GetAnakList({required this.nomorHpOrtu, this.isRefresh = false});

  @override
  List<Object> get props => [nomorHpOrtu, isRefresh];
}
