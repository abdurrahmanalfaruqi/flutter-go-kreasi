// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/soal/module/bundel_soal/presentation/bloc/bundel_soal/bundel_soal_bloc.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../model/detail_hasil_model.dart';
import '../../domain/entity/bundel_soal.dart';
import '../../../../presentation/provider/solusi_provider.dart';
import '../../../../../leaderboard/model/capaian_detail_score.dart';
import '../../../../../leaderboard/presentation/widget/home/detail_capaian_chart.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/constant.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../../../core/shared/widget/image/custom_image_network.dart';
import '../../../../../../core/shared/widget/loading/shimmer_list_tiles.dart';
import '../../../../../../core/shared/widget/watermark/watermark_widget.dart';
import '../../../../../../core/shared/widget/expanded/custom_expanded_widget.dart';
import '../../../../../../core/shared/widget/refresher/custom_smart_refresher.dart';

/// [BundelSoalList] merupakan Widget List Bundel Soal.<br><br>
/// Digunakan pada produk-produk berikut:<br>
/// 1. Latihan Extra (id: 76).<br>
/// 2. Paket Intensif (id: 77).<br>
/// 3. Paket Soal Koding (id: 78).<br>
/// 4. Pendalaman Materi (id: 79).<br>
/// 5. Soal Referensi (id: 82).
class BundelSoalList extends StatefulWidget {
  final int idJenisProduk;
  final String namaJenisProduk;
  final bool isRencanaPicker;

  const BundelSoalList({
    Key? key,
    required this.idJenisProduk,
    required this.namaJenisProduk,
    this.isRencanaPicker = false,
  }) : super(key: key);

  @override
  State<BundelSoalList> createState() => _BundelSoalListState();
}

class _BundelSoalListState extends State<BundelSoalList> {
  @override
  void didUpdateWidget(covariant BundelSoalList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the idJenisProduk has changed
    if (widget.idJenisProduk != oldWidget.idJenisProduk) {
      // Call the refresh function when idJenisProduk changes
      _onRefreshBundel(refresh: false, idJenisProduct: widget.idJenisProduk);
    }
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final RefreshController _emptyRefreshController =
      RefreshController(initialRefresh: false);

  UserModel? userData;
  List<List<BundelSoal>> listBundelSoal = [];
  List<String> listKelompokUjian = [];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is LoadedUser) {
      userData = authState.user;
    }
    _onRefreshBundel(refresh: false);
  }

  @override
  void dispose() {
    super.dispose();
    _refreshController.dispose();
    _emptyRefreshController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BundelSoalBloc, BundelSoalState>(
      builder: (context, state) {
        if (state is BundelSoalError) {
          listBundelSoal.clear();
          listKelompokUjian.clear();
        }

        if (state is BundelSoalLoading) {
          return const ShimmerListTiles(
              isWatermarked: true); // Loading state, return the original child.
        }

        if (state is BundelSoalLoaded) {
          listBundelSoal = state.listBundelSoal;
          listKelompokUjian = state.listKelompokUjian;
        }

        // to check if there is empty list
        bool isListEmpty = listBundelSoal.every((bundle) => bundle.isEmpty);

        var refreshWidget = CustomSmartRefresher(
          controller:
              (isListEmpty) ? _emptyRefreshController : _refreshController,
          isDark: true,
          onRefresh: _onRefreshBundel,
          child: (isListEmpty)
              ? _getIllustrationImage(widget.idJenisProduk)
              : _buildListBundelSoal(
                  listKelompokUjian: listKelompokUjian,
                  listBundleSoal: listBundelSoal),
        );

        return (isListEmpty)
            ? refreshWidget
            : WatermarkWidget(
                child: refreshWidget,
              );
      },
    );
  }

  // On Refresh Function
  Future<void> _onRefreshBundel({
    bool refresh = true,
    int? idJenisProduct,
  }) async {
    // Function load and refresh data
    List<int> listIdProduk =
        userData?.listIdProduk == null ? [] : (userData?.listIdProduk ?? []);

    context.read<BundelSoalBloc>().add(GetBundelSoalList(
          isRefresh: refresh,
          idSekolahKelas: userData?.idSekolahKelas ?? '14',
          idJenisProduk: widget.idJenisProduk,
          teaserRole: userData.teaserRole,
          listIdProduk: listIdProduk,
          noRegistrasi: userData?.noRegistrasi ?? '',
          idBundlingAktif: userData?.idBundlingAktif ?? 0,
        ));
  }

  void _onClickBundelUrutNomor({
    required BundelSoal bundelSoal,
  }) {
    // 'kodeTOB': bundelSoal.kodeTOB,
    // 'kodePaket': bundelSoal.kodePaket,
    // 'idBundel': bundelSoal.idBundel,
    // 'idJenisProduk': widget.idJenisProduk,
    // 'namaJenisProduk': widget.namaJenisProduk,
    // 'namaKelompokUjian': bundelSoal.namaKelompokUjian,
    // 'jumlahSoal': bundelSoal.jumlahSoal,
    // 'isRencanaPicker': widget.isRencanaPicker
    Map<String, dynamic> argument = {
      'idJenisProduk': widget.idJenisProduk,
      'namaJenisProduk': widget.namaJenisProduk,
      'diBukaDariRoute': Constant.kRouteBukuSoalScreen,
      'kodeTOB': bundelSoal.kodeTOB,
      'kodePaket': bundelSoal.kodePaket,
      'idBundel': bundelSoal.idBundel,
      'namaKelompokUjian': bundelSoal.namaKelompokUjian,
      'isPaket': false,
      'isSimpan': true,
      'isBisaBookmark': true,
      'userData': userData,
    };
    if (widget.isRencanaPicker) {
      argument.putIfAbsent(
        'keterangan',
        () => 'Mengerjakan ${widget.namaJenisProduk.replaceFirst('e-', '')} '
            '${bundelSoal.namaKelompokUjian}(${bundelSoal.kodePaket})',
      );
      argument.removeWhere((key, value) => key == 'userData');
      // Kirim data ke Rencana Belajar Editor
      Navigator.pop(context, argument);
    } else {
      argument.putIfAbsent('opsiUrut', () => OpsiUrut.nomor);
      Navigator.pushNamed(
        context,
        Constant.kRouteSoalBasicScreen,
        arguments: argument,
      ).then((value) => _onRefreshBundel());
    }
  }

  // Get Illustration Image Function
  Widget _getIllustrationImage(int idJenisProduk) {
    bool isProdukDibeli =
        userData.isProdukDibeliSiswa(idJenisProduk, ortuBolehAkses: true);
    // 76: Latex, 77: Paket Intensif, 78: Soal Koding, 79: Pend Materi, 82: SoRef
    String imageUrl = 'ilustrasi_soal_emwa.png'.illustration;
    String title = 'Buku Soal';

    switch (idJenisProduk) {
      case 76:
        imageUrl = 'ilustrasi_soal_latex.png'.illustration;
        title = 'Latihan Extra';
        break;
      case 77:
        imageUrl = 'ilustrasi_soal_paket_intensif.png'.illustration;
        title = 'Paket Intensif';
        break;
      case 78:
        title = 'Paket Soal Koding';
        break;
      case 79:
        title = 'Pendalaman Materi';
        break;
      case 82:
        imageUrl = 'ilustrasi_soal_referensi.png'.illustration;
        title = 'Soal Referensi';
        break;
      default:
        break;
    }

    Widget basicEmpty = BasicEmpty(
      shrink: (context.dh < 600) ? !context.isMobile : false,
      imageUrl: imageUrl,
      title: title,
      subTitle: gEmptyProductSubtitle(
          namaProduk: title,
          isProdukDibeli: isProdukDibeli,
          isOrtu: userData.isOrtu,
          isNotSiswa: !userData.isSiswa),
      emptyMessage: gEmptyProductText(
        namaProduk: title,
        isOrtu: userData.isOrtu,
        isProdukDibeli: isProdukDibeli,
      ),
    );

    return (context.isMobile || context.dh > 600)
        ? basicEmpty
        : SingleChildScrollView(
            child: basicEmpty,
          );
  }

  Widget _buildLeadingItem(
      {required BundelSoal bundelSoal, required bool isTeaser}) {
    var leadingWidget = Container(
      padding: EdgeInsets.symmetric(
        horizontal: min(12, context.dp(8)),
        vertical: min(14, context.dp(8)),
      ),
      constraints: BoxConstraints(minWidth: min(118, context.dp(72))),
      decoration: BoxDecoration(
        color: isTeaser ? context.tertiaryColor : context.background,
        border: isTeaser ? null : Border.all(color: context.tertiaryColor),
        borderRadius: BorderRadius.circular(min(18, context.dp(14))),
      ),
      child: Text(
        (context.isMobile)
            ? bundelSoal.kodePaket.replaceAll('-', '\n')
            : bundelSoal.kodePaket,
        maxLines: 2,
        textAlign: TextAlign.center,
        overflow: TextOverflow.fade,
        style: context.text.labelMedium?.copyWith(
          fontSize: (context.isMobile) ? 12 : 10,
          fontWeight: FontWeight.bold,
          color: isTeaser ? context.onTertiary : context.tertiaryColor,
        ),
      ),
    );

    return !isTeaser
        ? leadingWidget
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotatedBox(
                quarterTurns: 3,
                child: Text(
                  'TEASER',
                  style: context.text.labelSmall?.copyWith(
                    color: context.tertiaryColor,
                    fontSize: 8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              leadingWidget,
            ],
          );
  }

  // List Bundel Widgets
  // Widget _buildListBundelSoal(List<BundelSoal> listBundel) =>
  //     ListView.separated(
  //         controller: _scrollController,
  //         physics: const BouncingScrollPhysics(),
  //         padding: EdgeInsets.only(top: context.dp(8), bottom: context.dp(30)),
  //         itemBuilder: (_, index) => InkWell(
  //               onLongPress: () => _showDetailHasil(context, listBundel[index]),
  //               onTap: () => Navigator.pushNamed(
  //                 context,
  //                 Constant.kRouteBabBukuSoalScreen,
  //                 arguments: {
  //                   'kodeTOB': listBundel[index].kodeTOB,
  //                   'kodePaket': listBundel[index].kodePaket,
  //                   'idBundel': listBundel[index].idBundel,
  //                   'idJenisProduk': widget.idJenisProduk,
  //                   'namaJenisProduk': widget.namaJenisProduk,
  //                   'namaKelompokUjian': listBundel[index].namaKelompokUjian,
  //                   'jumlahSoal': listBundel[index].jumlahSoal,
  //                   'isRencanaPicker': widget.isRencanaPicker
  //                 },
  //               ),
  //               child: Container(
  //                 decoration:
  //                     BoxDecoration(borderRadius: BorderRadius.circular(18)),
  //                 child: ListTile(
  //                   dense: true,
  //                   leading: _buildLeadingItem(
  //                       bundelSoal: listBundel[index],
  //                       isTeaser: listBundel[index].isTeaser),
  //                   title: Text(
  //                     listBundel[index].namaKelompokUjian,
  //                     style: context.text.titleMedium,
  //                     maxLines: 1,
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                   subtitle: Text(listBundel[index].deskripsi),
  //                   trailing: RichText(
  //                     textAlign: TextAlign.center,
  //                     text: TextSpan(
  //                         text: '${listBundel[index].jumlahSoal}\n',
  //                         style: context.text.titleLarge,
  //                         children: [
  //                           TextSpan(
  //                               text: 'SOAL', style: context.text.labelSmall),
  //                         ]),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //         separatorBuilder: (_, index) => const Divider(),
  //         itemCount: listBundel.length);

  Widget? _buildImageKelompokUjian(
    String iconKelompokUjian,
  ) {
    final baseUrl = dotenv.env['BASE_URL_IMAGE'];
    return (iconKelompokUjian.isEmpty)
        ? CustomImageNetwork.rounded(
            "$baseUrl/mapel/tps_pemahaman_membaca_dan_menulis.webp",
            width: 36, // 24
            height: 36, // 24
            fit: BoxFit.fitHeight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          )
        : CustomImageNetwork.rounded(
            iconKelompokUjian,
            width: 36, // 24
            height: 36, // 24
            fit: BoxFit.fitHeight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          );
  }

  Widget _buildKelompokUjianHeader({
    Widget? imageKelompokUjian,
    required String namaKelompokUjian,
    required String initialKelompokUjian,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 14,
      ),
      child: Row(
        children: [
          imageKelompokUjian ?? const SizedBox.shrink(),
          if (imageKelompokUjian != null) const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaKelompokUjian,
                  style: context.text.labelLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  'Singkatan: $initialKelompokUjian',
                  style: context.text.labelSmall?.copyWith(
                    color: context.hintColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // List Bundle GroupBy Kelompok Ujian
  Widget _buildListBundelSoal({
    required List<String> listKelompokUjian,
    required List<List<BundelSoal>> listBundleSoal,
  }) {
    return ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(top: context.dp(8), bottom: context.dp(30)),
        itemBuilder: (_, index) {
          List<BundelSoal> subListBundel = listBundleSoal[index];
          if (subListBundel.isNotEmpty) {
            subListBundel.sort(
              (a, b) {
                int tingkatKelas = a.tingkatKelas.compareTo(b.tingkatKelas);
                if (tingkatKelas == 0) {
                  int sekolahKelas = a.sekolahKelas.compareTo(b.sekolahKelas);
                  if (sekolahKelas == 0) {
                    int deskripsi = a.deskripsi.compareTo(b.deskripsi);
                    if (deskripsi == 0) {
                      return a.kodePaket.compareTo(b.kodePaket) * -1;
                    }
                    return deskripsi;
                  }
                  return -sekolahKelas;
                }
                return -tingkatKelas;
              },
            );
          }

          // int idKelompokUjian = subListBundel.first.idKelompokUjian;
          // final iconKelompokUjian = Constant.kIconMataPelajaran.entries
          //     .where(
          //       (iconMapel) =>
          //           iconMapel.value['idKelompokUjian']
          //               ?.contains(idKelompokUjian) ??
          //           false,
          //     )
          //     .toList();
          final iconKelompokUjian = subListBundel.first.iconMapel;

          // final String initialKelompokUjian =
          //     Constant.kInitialKelompokUjian[idKelompokUjian]?['initial'] ??
          //         'N/a';

          final String initialKelompokUjian =
              subListBundel.first.initialKelompokUjian;
          final listBundleWidget = List.generate(
            subListBundel.length,
            (i) {
              final bundelSoal = subListBundel[i];
              return InkWell(
                onLongPress: () => _showDetailHasil(context, bundelSoal),
                onTap: () {
                  if (bundelSoal.opsiUrut == OpsiUrut.nomor) {
                    _onClickBundelUrutNomor(bundelSoal: bundelSoal);
                  } else {
                    Navigator.pushNamed(
                      context,
                      Constant.kRouteBabBukuSoalScreen,
                      arguments: {
                        'kodeTOB': bundelSoal.kodeTOB,
                        'kodePaket': bundelSoal.kodePaket,
                        'idBundel': bundelSoal.idBundel,
                        'idJenisProduk': widget.idJenisProduk,
                        'namaJenisProduk': widget.namaJenisProduk,
                        'namaKelompokUjian': bundelSoal.namaKelompokUjian,
                        'jumlahSoal': bundelSoal.jumlahSoal,
                        'isRencanaPicker': widget.isRencanaPicker
                      },
                    );
                  }
                },
                child: Padding(
                  padding:
                      const EdgeInsets.only(bottom: 8, left: 42, right: 20),
                  child: Row(
                    children: [
                      _buildLeadingItem(
                          bundelSoal: bundelSoal,
                          isTeaser: bundelSoal.isTeaser),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          textScaler: TextScaler.linear(context.textScale14),
                          text: TextSpan(
                            text: '~${bundelSoal.sekolahKelas}\n',
                            style: context.text.labelSmall
                                ?.copyWith(color: context.hintColor),
                            children: [
                              TextSpan(
                                text: bundelSoal.deskripsi,
                                style: context.text.bodySmall,
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      RichText(
                        textAlign: TextAlign.center,
                        textScaler: TextScaler.linear(context.textScale14),
                        text: TextSpan(
                            text: '${bundelSoal.jumlahSoal}\n',
                            style: context.text.titleLarge?.copyWith(
                              fontFamily: 'Montserrat',
                            ),
                            children: [
                              TextSpan(
                                  text: 'SOAL', style: context.text.labelSmall),
                            ]),
                      ),
                    ],
                  ),
                ),
              );
            },
          );

          return (subListBundel.length < 3)
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildKelompokUjianHeader(
                      imageKelompokUjian:
                          _buildImageKelompokUjian(iconKelompokUjian),
                      namaKelompokUjian: listKelompokUjian[index].toString(),
                      initialKelompokUjian: initialKelompokUjian,
                    ),
                    ...listBundleWidget,
                  ],
                )
              : CustomExpandedWidget(
                  shaderStart: 0.6,
                  leadingItem: _buildImageKelompokUjian(iconKelompokUjian),
                  title: listKelompokUjian[index].toString(),
                  subTitle: 'Singkatan: $initialKelompokUjian',
                  moreItemCount: subListBundel.length - 2,
                  collapsedVisibilityFactor: 2 / subListBundel.length,
                  headerPadding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: 14,
                  ),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: listBundleWidget),
                );
        },
        separatorBuilder: (_, __) => const Divider(),
        itemCount: listKelompokUjian.length);
  }

  _showDetailHasil(BuildContext context, BundelSoal bundelSoal) async {
    final getDetailHasil = context.read<SolusiProvider>().getDetailHasil(
          noRegistrasi: gNoRegistrasi,
          idSekolahKelas: userData?.idSekolahKelas ?? '14',
          kodePaket: bundelSoal.kodePaket,
          jumlahSoal: bundelSoal.jumlahSoal,
          tingkatkelas: int.parse(userData?.tingkatKelas ?? '0'),
          jenisHasil: 'bundel',
        );

    Widget? childWidget;

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: context.dh * 0.9),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        childWidget ??= Selector<SolusiProvider, List<DetailHasilModel>>(
            selector: (_, solusi) => solusi.listDetailHasil,
            builder: (context, listDetailHasil, _) {
              return FutureBuilder(
                future: getDetailHasil,
                builder: (context, snapshot) {
                  bool isLoading =
                      snapshot.connectionState == ConnectionState.waiting ||
                          context.select<SolusiProvider, bool>(
                              (solusi) => solusi.isloading);

                  if (isLoading) {
                    return const ShimmerListTiles(
                        shrinkWrap: true, jumlahItem: 2);
                  }

                  if (listDetailHasil.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: context.dp(18),
                        left: context.dp(18),
                        top: context.dp(24),
                        bottom: context.dp(24),
                      ),
                      child: Text(
                        "Belum ada soal ${bundelSoal.kodePaket} yang telah Sobat kerjakan, "
                        "yuk kerjain soal dulu Sobat.",
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: context.dp(18), horizontal: 16),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: listDetailHasil.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (index == 0)
                              Column(
                                children: [
                                  Center(
                                    child: Text(bundelSoal.kodePaket,
                                        style: context.text.titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  constraints:
                                      BoxConstraints(maxWidth: context.dw - 32),
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Text(
                                    listDetailHasil[index]
                                        .namaKelompokUjian
                                        .toString(),
                                    style: context.text.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            DetailCapaianChart(
                              capaianDetail: CapaianDetailScore(
                                label: listDetailHasil[index]
                                    .namaKelompokUjian
                                    .toString(),
                                benar: listDetailHasil[index].benar,
                                salah: listDetailHasil[index].salah,
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  );
                },
              );
            });

        return childWidget!;
      },
    );
  }
}
