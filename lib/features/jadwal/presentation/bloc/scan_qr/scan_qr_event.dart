part of 'scan_qr_bloc.dart';

class ScanQrEvent extends Equatable {
  const ScanQrEvent();

  @override
  List<Object> get props => [];
}

class ScanQRKBM extends ScanQrEvent {
  final Map<String, dynamic> params;
  const ScanQRKBM(this.params);

  @override
  List<Object> get props => [params];
}

class ScanQRTST extends ScanQrEvent {
  final Map<String, dynamic> params;
  const ScanQRTST(this.params);

  @override
  List<Object> get props => [params];
}
