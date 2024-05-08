// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_constructors_in_immutables, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/feedback/presentation/bloc/feedback_bloc.dart';
import 'package:intl/intl.dart';

import 'feedback_question/feedback_question_bool_widget.dart';
import 'feedback_question/feedback_question_text_widget.dart';
import '../../data/model/feedback_question.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/dialog/custom_dialog.dart';
import '../../../../core/shared/widget/loading/loading_widget.dart';
import '../../../../core/shared/widget/exception/exception_widget.dart';

class FeedbackWidget extends StatefulWidget {
  final String idRencana;
  final String namaPengajar;
  final String kelas;
  final String tanggal;
  final String flag;
  final String mapel;
  final bool done;

  FeedbackWidget({
    Key? key,
    required this.idRencana,
    required this.namaPengajar,
    required this.kelas,
    required this.tanggal,
    required this.flag,
    required this.mapel,
    required this.done,
  }) : super(key: key);

  @override
  _FeedbackWidgetState createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget> {
  String? _userId;
  late final bool _done = widget.done;
  late FocusNode textFocusNode;
  UserModel? userData;

  Widget _buildInformationItem(String label, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "$label : ",
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: context.text.bodyMedium?.copyWith(
                color: context.hintColor,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is LoadedUser) {
      userData = authState.user;
    }
    if (userData != null) {
      _userId = userData?.noRegistrasi;
      context.read<FeedbackBloc>().add(LoadFeedback(
            noRegistrasi: _userId ?? "",
            idRencana: widget.idRencana,
          ));
      textFocusNode = FocusNode();
    }
  }

  @override
  void dispose() {
    textFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeedbackBloc, FeedbackState>(
      listener: (context, state) {
        if (state is SaveFeedbackSucces) {
          Navigator.pop(context);

          gShowTopFlash(context, 'Feedback berhasil disimpan',
              dialogType: DialogType.success);
        }
        if (state is SaveFeedbackError) {
          Navigator.pop(context);
          CustomDialog.fatalExceptionDialog(context, message: state.message);
        }
      },
      builder: (context, state) {
        if (state is FeedbackLoading) {
          return LoadingWidget();
        } else if (state is FeedbackLoaded) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                right: 16,
                left: 16,
                top: 16,
                bottom: 10,
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: context.background,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 7,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIcon(context, "Informasi Kelas"),
                        _buildInformationItem('Kelas', widget.kelas),
                        _buildInformationItem('Kelompok Ujian', widget.mapel),
                        _buildInformationItem('Pengajar', widget.namaPengajar),
                        _buildInformationItem(
                          'Tanggal',
                          DateFormat.yMMMMd('ID').format(
                            DateTime.parse(
                              widget.tanggal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5.0),
                  SizedBox(height: 5.0),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    decoration: BoxDecoration(
                      color: context.background,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 7,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildIcon(context, "Pertanyaan"),
                        Text(
                          'Berikut ini pertanyaan untuk feedback pengajar yang masuk sesuai dengan infomasi yang tercantum di atas.',
                          style: context.text.labelLarge
                              ?.copyWith(color: context.hintColor),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: state.listPertanyaan.length,
                          itemBuilder: (ctx, index) {
                            FocusNode focusNodeIndexed = FocusNode();
                            return index == state.listPertanyaan.length - 1
                                ? FeedbackQuestionTextWidget(
                                    isDone: _done,
                                    feedbackQuestion:
                                        state.listPertanyaan[index],
                                    textFocusNode: focusNodeIndexed,
                                    questionNumber: index,
                                    onChanged: (val) {
                                      context
                                          .read<FeedbackBloc>()
                                          .add(AnswerFeedback(
                                            no: index,
                                            answer: val,
                                          ));
                                    },
                                  )
                                : Container(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: FeedbackQuestionBoolWidget(
                                      _done,
                                      state.listPertanyaan[index],
                                      index,
                                      onSelected: (val) {
                                        context
                                            .read<FeedbackBloc>()
                                            .add(AnswerFeedback(
                                              no: index,
                                              answer: val,
                                            ));
                                      },
                                    ),
                                  );
                          },
                        ),
                      ],
                    ),
                  ),
                  if (!_done)
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          List<FeedbackQuestion> listAnswer =
                              state.listPertanyaan;
                          int checkAnswer = 0;
                          for (int i = 0; i < listAnswer.length; i++) {
                            if (listAnswer[i].answer == "na" ||
                                listAnswer[i].answer == "") {
                              checkAnswer++;
                            }
                          }
                          if (checkAnswer == 0) {
                            context.read<FeedbackBloc>().add(SaveFeedback(
                                userId: _userId ?? '',
                                rencanaId: widget.idRencana));
                          } else {
                            textFocusNode.requestFocus();
                            gShowBottomDialogInfo(context,
                                message:
                                    "Sobat belum menjawab seluruh pertanyaan!");
                          }
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: context.secondaryColor,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: context.secondaryColor.withOpacity(0.5),
                                blurRadius: 7,
                                offset: const Offset(
                                    0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Text(
                            "Simpan",
                            style: context.text.bodyMedium,
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ),
          );
        }

        return ExceptionWidget(
          'Belum ada data untuk saat ini',
          exceptionMessage: 'Belum ada data untuk saat ini',
        );
      },
    );
  }

  _buildIcon(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              margin: EdgeInsets.only(right: context.dp(12)),
              decoration: BoxDecoration(
                  color: context.tertiaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        offset: const Offset(-1, -1),
                        blurRadius: 4,
                        spreadRadius: 1,
                        color: context.tertiaryColor.withOpacity(0.42)),
                    BoxShadow(
                        offset: const Offset(1, 1),
                        blurRadius: 4,
                        spreadRadius: 1,
                        color: context.tertiaryColor.withOpacity(0.42))
                  ]),
              child: Icon(
                (title == "Informasi Kelas")
                    ? Icons.info_outlined
                    : Icons.question_mark,
                size: context.dp(22),
                color: context.onTertiary,
              ),
            ),
            Text(
              title,
              style: context.text.labelLarge,
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 2),
          child: Divider(),
        )
      ],
    );
  }
}
