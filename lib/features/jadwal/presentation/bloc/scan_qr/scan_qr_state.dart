part of 'scan_qr_bloc.dart';

class ScanQrState extends Equatable {
  const ScanQrState();

  @override
  List<Object> get props => [];
}

class ScanQrInitial extends ScanQrState {}

class ScanQRLoading extends ScanQrState {}

class ScanQRError extends ScanQrState {
  final String err;
  const ScanQRError(this.err);

  @override
  List<Object> get props => [err];
}

class ScanQRSuccess extends ScanQrState {
  final String message;
  const ScanQRSuccess(this.message);

  @override
  List<Object> get props => [message];
}
