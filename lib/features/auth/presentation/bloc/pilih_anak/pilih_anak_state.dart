part of 'pilih_anak_bloc.dart';

class PilihAnakState extends Equatable {
  const PilihAnakState();

  @override
  List<Object> get props => [];
}

class PilihAnakInitial extends PilihAnakState {}

class PilihAnakLoading extends PilihAnakState {}

class PilihAnakError extends PilihAnakState {
  final String err;
  final String deviceId;
  const PilihAnakError({
    required this.err,
    required this.deviceId,
  });

  @override
  List<Object> get props => [err, deviceId];
}

class PilihAnakErrResponse extends PilihAnakState {
  final String err;
  final String deviceId;
  const PilihAnakErrResponse({required this.err, required this.deviceId});

  @override
  List<Object> get props => [err, deviceId];
}

class LoadedListAnak extends PilihAnakState {
  final List<Anak> listAnak;

  const LoadedListAnak({
    required this.listAnak,
  });

  @override
  List<Object> get props => [
        listAnak,
      ];
}
