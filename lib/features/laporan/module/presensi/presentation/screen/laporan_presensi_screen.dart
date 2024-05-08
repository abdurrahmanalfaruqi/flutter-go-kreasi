import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import '../widget/laporan_presensi_widget.dart';

class LaporanPresensiScreen extends StatefulWidget {
  const LaporanPresensiScreen({Key? key}) : super(key: key);

  @override
  LaporanPresensiScreenState createState() => LaporanPresensiScreenState();
}

class LaporanPresensiScreenState extends State<LaporanPresensiScreen> {
  UserModel? userData;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is LoadedUser) {
          userData = state.user;
        }

        return SafeArea(
          child: LaporanPresensiWidget(userData: userData),
        );
      },
    );
  }
}
