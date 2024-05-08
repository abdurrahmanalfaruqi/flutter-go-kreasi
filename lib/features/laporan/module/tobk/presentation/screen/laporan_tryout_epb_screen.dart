import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../../../core/config/extensions.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../../../core/shared/screen/basic_screen.dart';
import '../../../../../../core/shared/widget/empty/no_data_found.dart';
import '../../../../../../core/shared/widget/loading/loading_widget.dart';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class LaporanTryoutEPBScreen extends StatefulWidget {
  const LaporanTryoutEPBScreen({
    Key? key,
    required this.title,
    required this.link,
  }) : super(key: key);
  final String title;
  final String link;

  @override
  State<LaporanTryoutEPBScreen> createState() => _LaporanTryoutEPBScreenState();
}

class _LaporanTryoutEPBScreenState extends State<LaporanTryoutEPBScreen> {
  /// [_pdfViewerController] controller untuk penampil PDF.
  late PdfViewerController _pdfViewerController;

  /// [_pdfViewerStateKey] digunakan untuk mengakses keadaan penampil PDF.
  final GlobalKey<SfPdfViewerState> _pdfViewerStateKey = GlobalKey();

  /// [baseUrlPdfFile] base url untuk file pdf
  String baseUrlPdfFile = dotenv.env['BASE_URL_PDF_FILE']!;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  String get _linkPDF {
    return baseUrlPdfFile + widget.link;
  }

  Future<int> _checkPDFExist() async {
    final res = await http.get(Uri.parse(_linkPDF));
    return res.statusCode;
  }

  @override
  Widget build(BuildContext context) {
    return BasicScreen(
        title: widget.title,
        body: SafeArea(
          child: FutureBuilder(
            future: _checkPDFExist(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingWidget();
              }

              if (snapshot.data != 200) {
                return NoDataFoundWidget(
                  imageUrl:
                      '${dotenv.env["BASE_URL_IMAGE"]}/arsip-mobile/img/ilustrasi_data_not_found.png',
                  subTitle: "Data tidak ditemukan",
                  emptyMessage:
                      "Laporan EPB tidak ditemukan, silahkan hubungi Customer Service ya Sobat",
                );
              }

              return SfPdfViewer.network(
                _linkPDF,
                controller: _pdfViewerController,
                key: _pdfViewerStateKey,
                onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                  const LoadingWidget();
                },
                currentSearchTextHighlightColor: context.secondaryColor,
                onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                  NoDataFoundWidget(
                      imageUrl:
                          '${dotenv.env["BASE_URL_IMAGE"]}/arsip-mobile/img/ilustrasi_data_not_found.png',
                      subTitle: "Data tidak ditemukan",
                      emptyMessage: details.error);
                },
              );
            },
          ),
        ));
  }
}
