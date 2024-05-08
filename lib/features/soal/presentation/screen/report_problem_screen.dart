import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gokreasi_new/core/config/enum.dart';
import 'package:gokreasi_new/core/config/extensions.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/core/shared/screen/basic_screen.dart';
import 'package:gokreasi_new/features/soal/presentation/provider/soal_provider.dart';

class ReportProblemScreen extends StatefulWidget {
  final SoalProvider soalProvider;
  final String noRegistrasi;
  final int idJenisProduk;
  final String namaJenisProduk;
  final int idSoal;
  final int? idBundel;
  final String kodePaket;
  final String stackTrace;

  const ReportProblemScreen({
    super.key,
    required this.soalProvider,
    required this.noRegistrasi,
    required this.idJenisProduk,
    required this.namaJenisProduk,
    required this.idSoal,
    required this.idBundel,
    required this.kodePaket,
    required this.stackTrace,
  });

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final FocusNode _textFocusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasicScreen(
      title: 'Laporan Masalah',
      subTitle: '',
      jumlahBarisTitle: 2,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: min(24, context.dp(16))),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text('Jika sobat menemukan masalah pada soal GO Expert. '
                '\n\ncontoh: soal tidak muncul, soal tidak jelas. '
                '\n\nSilahkan jelaskan masalah tersebut disini ya.'),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: context.background,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextFormField(
                focusNode: _textFocusNode,
                controller: _textEditingController,
                minLines: 3,
                maxLines: 20,
                maxLength: 500,
                style: context.text.bodyMedium,
                textInputAction: TextInputAction.go,
                buildCounter: (
                  _, {
                  required currentLength,
                  maxLength,
                  required isFocused,
                }) =>
                    Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    "$currentLength/$maxLength",
                    style: context.text.labelSmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
                decoration: InputDecoration(
                  fillColor: context.background,
                  hintText: 'Ketikan masalah disini',
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  // counterText: "${_textEditingController.text.length}/500",
                  counterStyle: context.text.labelSmall
                      ?.copyWith(color: context.hintColor),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Material(
              color: context.primaryColor,
              borderRadius: BorderRadius.circular(300),
              child: InkWell(
                onTap: () async => _onSubmitReport(),
                borderRadius: BorderRadius.circular(300),
                child: Container(
                  width: context.dw,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(300),
                      boxShadow: [
                        BoxShadow(
                            offset: const Offset(-1, -1),
                            blurRadius: 4,
                            spreadRadius: 1,
                            color: context.primaryColor.withOpacity(0.1)),
                        BoxShadow(
                            offset: const Offset(1, 1),
                            blurRadius: 4,
                            spreadRadius: 1,
                            color: context.primaryColor.withOpacity(0.1))
                      ]),
                  child: Text(
                    'Submit',
                    textAlign: TextAlign.center,
                    style: context.text.labelLarge?.copyWith(
                      color: context.background,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _onSubmitReport() async {
    if (_textEditingController.text.isEmpty) return;

    final now = DateTime.now();

    final submitResult = await widget.soalProvider.postReportProblem(
      noRegistrasi: widget.noRegistrasi,
      idJenisProduk: widget.idJenisProduk,
      namaJenisProduk: widget.namaJenisProduk,
      idSoal: widget.idSoal,
      idBundel: widget.idBundel,
      kodePaket: widget.kodePaket,
      reason: _textEditingController.text,
      stackTrace: widget.stackTrace,
      timeStamp: now.serverTimeFromOffset.toString(),
      zonaWaktu: now.timeZoneName,
    );

    if (!submitResult && mounted) {
      gShowTopFlash(
        context,
        gPesanError,
        dialogType: DialogType.error,
      );
    } else if (mounted) {
      Navigator.of(context).pop();

      gShowTopFlash(
        context,
        'Berhasil submit laporan masalah',
        dialogType: DialogType.success,
      );
    }
  }
}
