import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/core/config/extensions.dart';
import 'package:gokreasi_new/core/shared/screen/basic_screen.dart';
import 'package:gokreasi_new/core/shared/widget/empty/basic_empty.dart';
import 'package:gokreasi_new/core/shared/widget/loading/shimmer_widget.dart';
import 'package:gokreasi_new/features/laporan/module/tobk/presentation/widget/laporan_jawaban.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/presentation/bloc/laporan_jawaban_tobk/laporan_jawaban_bloc.dart';

class LaporanDetailScreen extends StatefulWidget {
  final String namaTOB;
  final String noRegister;
  final String kodeTOB;
  final String tingkatKelas;
  final String jenisTOB;
  
  const LaporanDetailScreen({
    super.key,
    required this.namaTOB,
    required this.noRegister,
    required this.kodeTOB,
    required this.jenisTOB,
    required this.tingkatKelas,
  });

  @override
  // ignore: library_private_types_in_public_api
  _LaporanDetailScreenState createState() => _LaporanDetailScreenState();
}

class _LaporanDetailScreenState extends State<LaporanDetailScreen> {
  @override
  void initState() {
    // Mengirim event untuk memuat data dari Bloc saat widget diinisialisasi.
    context.read<LaporanJawabanBloc>().add(LoadLaporanJawaban(
          noRegistrasi: widget.noRegister,
          kodeTob: widget.kodeTOB,
          jenisTOB: widget.jenisTOB,
          tingkatKelas: widget.tingkatKelas,
        ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BasicScreen(
      title: "Laporan Jawaban",
      body: BlocBuilder<LaporanJawabanBloc, LaporanJawabanState>(
        builder: (context, state) {
          if (state is LaporanJawabanLoading) {
            return const ShimmerWidget(
                width: 200,
                height:
                    300); // Menampilkan loading spinner jika data masih dimuat.
          } else if (state is LaporanJawabanLoaded) {
            if (state.listLaporanJawaban.isEmpty) {
              return BasicEmpty(
                  imageUrl: 'ilustrasi_data_not_found.png'.illustration,
                  title: "Data Laporan Kosong",
                  subTitle: "Sobat Belum Mengerjakan UTBK ini",
                  emptyMessage: "Ayo Kerjakan UTBK ini Sekarang");
            } else {
              return Column(
                children: [
                  const SizedBox(height: 40),
                  Flexible(
                    child: LaporanTryoutJawaban(
                      state.listLaporanJawaban,
                      widget.namaTOB,
                    ),
                  )
                ],
              );
            }
            // Menampilkan data yang dimuat dari Bloc.
          }
          return BasicEmpty(
              imageUrl: 'ilustrasi_data_not_found.png'.illustration,
              title: "Data Laporan Kosong",
              subTitle: "Sobat Belum Mengerjakan UTBK ini",
              emptyMessage:
                  "Ayo Kerjakan UTBK ini Sekarang"); // Konten default jika tidak ada data atau kesalahan.
        },
      ),
    );
  }
}
