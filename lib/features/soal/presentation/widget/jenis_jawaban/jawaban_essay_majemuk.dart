import 'package:flutter/material.dart';
import 'package:gokreasi_new/features/soal/presentation/provider/soal_provider.dart';

import 'text_field_essay.dart';
import '../../../../../core/config/enum.dart';
import '../../../../../core/config/global.dart';

class JawabanEssayMajemuk extends StatefulWidget {
  final List<Map<String, dynamic>> jsonSoalJawaban;
  final void Function(List<String> selected)? onSimpanJawaban;
  final SoalProvider soalProvider;
  final int nomorSoal;

  const JawabanEssayMajemuk({
    Key? key,
    required this.jsonSoalJawaban,
    this.onSimpanJawaban,
    required this.soalProvider,
    required this.nomorSoal,
  }) : super(key: key);

  @override
  State<JawabanEssayMajemuk> createState() => _JawabanEssayMajemukState();
}

class _JawabanEssayMajemukState extends State<JawabanEssayMajemuk> {
  late final List<FocusNode> _focusNodes =
      List.generate(widget.jsonSoalJawaban.length, (_) => FocusNode());
  late final List<TextEditingController> _textEditingControllers =
      List.generate(
          widget.jsonSoalJawaban.length, (_) => TextEditingController());
  List<String> _listJawaban = [];
  List<String> _listTempJawaban = [];
  List<String> _jawabanSebelumnya = [];

  @override
  void didUpdateWidget(covariant JawabanEssayMajemuk oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.nomorSoal != oldWidget.nomorSoal) {
      for (var controller in _textEditingControllers) {
        controller.clear();
      }
      _setJawabanSebelumnya();
    }
  }

  @override
  void initState() {
    super.initState();
    // Menunggu sambil menyiapkan mounted dan value dari _focusNode dan _textEditingController
    Future.delayed(const Duration(milliseconds: 300))
        .then((value) => _setJawabanSebelumnya());
  }

  @override
  void dispose() {
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    for (var controller in _textEditingControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) => mounted ? super.setState(() => fn()) : fn();

  @override
  Widget build(BuildContext context) {
    List<dynamic>? jawabanSiswa = widget.soalProvider.soal.jawabanSiswa;
    if (jawabanSiswa != null && jawabanSiswa.isNotEmpty) {
      _jawabanSebelumnya = jawabanSiswa.cast<String>();
    }

    // _setJawabanSebelumnya();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.jsonSoalJawaban.length,
      itemBuilder: (_, index) {
        final focusNode = _focusNodes[index];
        final controller = _textEditingControllers[index];

        return TextFieldEssay(
          soalText: widget.jsonSoalJawaban[index]['soal'],
          enable: widget.onSimpanJawaban != null,
          controller: controller,
          focusNode: focusNode,
          onSubmit: widget.onSimpanJawaban != null
              ? (isiJawaban) {
                  focusNode.unfocus();

                  if (widget.onSimpanJawaban == null) {
                    gShowTopFlash(
                      context,
                      'Kamu sudah mengumpulkan jawaban soal ini!',
                      dialogType: DialogType.error,
                    );
                    return;
                  }

                  if (isiJawaban.isEmpty) {
                    gShowBottomDialogInfo(
                      context,
                      message:
                          'Jika kamu ingin menyimpan jawaban soal ini mohon untuk mengisinya, jika tidak silakan lewati soal ini dan biarkan kosong',
                    );
                    return;
                  }

                  _listJawaban[index] = isiJawaban;

                  if (_checkJawaban(
                      index, _listJawaban[index], _listTempJawaban[index])) {
                    widget.onSimpanJawaban!(_listJawaban);
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
      },
    );
  }

  /// NOTE: kumpulan fungsi
  bool _checkJawaban(int index, String answer, String temp) {
    if (answer.toLowerCase() != temp.toLowerCase()) {
      _listTempJawaban[index] = answer;
      return true;
    }
    return false;
  }

  void _setJawabanSebelumnya() {
    _listJawaban = [];
    _listTempJawaban = [];

    if (_jawabanSebelumnya.isNotEmpty) {
      _textEditingControllers.asMap().forEach(
          (key, controller) => controller.text = _jawabanSebelumnya[key]);

      _jawabanSebelumnya.asMap().forEach((key, answer) {
        _listJawaban.insert(key, answer);
        _listTempJawaban.insert(key, answer);
      });
    } else {
      _textEditingControllers
          .asMap()
          .forEach((key, controller) => controller.text = '');

      widget.jsonSoalJawaban.asMap().forEach((key, value) {
        _listJawaban.insert(key, '');
        _listTempJawaban.insert(key, '');
      });
    }
  }
}
