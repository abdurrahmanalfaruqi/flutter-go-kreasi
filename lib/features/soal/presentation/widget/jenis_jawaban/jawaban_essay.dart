import 'package:flutter/material.dart';
import 'package:gokreasi_new/features/soal/presentation/provider/soal_provider.dart';

import 'text_field_essay.dart';
import '../../../../../core/config/enum.dart';
import '../../../../../core/config/global.dart';

class JawabanEssay extends StatefulWidget {
  final void Function(String)? onSimpanJawaban;
  final SoalProvider soalProvider;
  final int nomorSoal;

  const JawabanEssay({
    Key? key,
    this.onSimpanJawaban,
    required this.soalProvider,
    required this.nomorSoal,
  }) : super(key: key);

  @override
  State<JawabanEssay> createState() => _JawabanEssayState();
}

class _JawabanEssayState extends State<JawabanEssay> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();
  // ignore: prefer_final_fields
  String _tempAnswer = '';

  bool checkAnswer(String answer) {
    if (_tempAnswer.toLowerCase() != answer.toLowerCase()) {
      _tempAnswer = answer;
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _setJawabanSebelumnya();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant JawabanEssay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.nomorSoal != oldWidget.nomorSoal) {
      _textEditingController.clear();
      _setJawabanSebelumnya();
    }
  }

  @override
  void setState(VoidCallback fn) => mounted ? super.setState(() => fn()) : fn();

  @override
  Widget build(BuildContext context) {
    return TextFieldEssay(
      enable: widget.onSimpanJawaban != null,
      focusNode: _focusNode,
      controller: _textEditingController,
      onSubmit: (widget.onSimpanJawaban != null)
          ? (isiJawaban) {
              _focusNode.unfocus();

              if (isiJawaban.isEmpty) {
                gShowBottomDialogInfo(
                  context,
                  message:
                      'Jika kamu ingin menyimpan jawaban soal ini mohon untuk mengisinya, jika tidak silakan lewati soal ini dan biarkan kosong',
                );
                return;
              }

              if (widget.onSimpanJawaban == null) {
                gShowTopFlash(
                  context,
                  'Kamu sudah mengumpulkan jawaban soal ini!',
                  dialogType: DialogType.error,
                );
                return;
              }

              if (checkAnswer(isiJawaban)) {
                widget.onSimpanJawaban!(isiJawaban);

                gShowTopFlash(
                  context,
                  'Jawaban essay untuk soal ini telah disimpan',
                  dialogType: DialogType.info,
                );
                return;
              }

              gShowTopFlash(
                context,
                'Jawaban sama dengan yang sebelumnya',
                dialogType: DialogType.warning,
              );
            }
          : null,
    );
  }

  void _setJawabanSebelumnya() {
    if (widget.soalProvider.soal.jawabanSiswa != null &&
        (widget.soalProvider.soal.jawabanSiswa as String).isNotEmpty) {
      _textEditingController.text = widget.soalProvider.soal.jawabanSiswa;
      _tempAnswer = widget.soalProvider.soal.jawabanSiswa;
    }
  }
}
