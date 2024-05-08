import 'package:flutter/material.dart';
import 'package:gokreasi_new/core/config/extensions.dart';

/// [LoadingOverlay] digunakan untuk merubah state menjadi loading ketika siswa
/// memilih jawaban
class LoadingOverlay extends StatelessWidget {
  /// [isLoadingSimpanJawaban] digunakan untuk menunjukkan loading simpan jawaban
  final bool isLoadingSimpanJawaban;

  /// [isLoadingSoal] digunakan untuk menunjukkan loading get jawaban
  final bool isLoadingJawaban;

  /// [loadingKoneksi] menunjukkan narasi bad connection ketika loading simpan
  /// jawaban lebih dari 3 detik
  final String? loadingKoneksi;

  const LoadingOverlay({
    super.key,
    required this.isLoadingSimpanJawaban,
    required this.isLoadingJawaban,
    required this.loadingKoneksi,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingSimpanJawaban || isLoadingJawaban) {
      return Stack(
        children: [
          const Opacity(
            opacity: 0.6,
            child: ModalBarrier(dismissible: false, color: Colors.black),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoadingSimpanJawaban) ...[
                  _buildTextLoadingSimpanJawaban(context)
                ] else if (isLoadingJawaban) ...[
                  _buildTextLoadingSoal(context)
                ],
                const SizedBox(height: 15),
                CircularProgressIndicator(
                  color: context.primaryColor,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildTextLoadingSimpanJawaban(BuildContext context) => RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: context.text.bodyMedium?.copyWith(
            color: Colors.white,
          ),
          children: [
            const TextSpan(text: 'Sedang menyimpan jawaban kamu... \n'),
            if (loadingKoneksi != null) ...[
              TextSpan(text: loadingKoneksi),
            ]
          ],
        ),
      );

  Widget _buildTextLoadingSoal(BuildContext context) => RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: context.text.bodyMedium?.copyWith(
            color: Colors.white,
          ),
          children: const [
            TextSpan(text: 'Sedang menyiapkan soal... \n'),
            TextSpan(text: 'Tunggu sebentar ya sobat'),
          ],
        ),
      );
}
