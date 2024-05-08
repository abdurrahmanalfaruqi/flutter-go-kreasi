import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/core/shared/widget/expanded/custom_expanded_widget.dart';
import 'package:gokreasi_new/core/shared/widget/separator/dash_divider.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/buku/domain/entity/buku.dart';
import 'package:gokreasi_new/features/video/presentation/bloc/jadwal_video_teori/jadwal_video_teori_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../../../core/config/global.dart';
import '../../../../../core/config/constant.dart';
import '../../../../../core/config/extensions.dart';
import '../../../../../core/shared/widget/empty/no_data_found.dart';
import '../../../../../core/shared/widget/image/custom_image_network.dart';
import '../../../../../core/shared/widget/loading/shimmer_list_tiles.dart';
import '../../../../../core/shared/widget/watermark/watermark_widget.dart';
import '../../../../../core/shared/widget/refresher/custom_smart_refresher.dart';

/// [VideoMapelList] merupakan list Mapel sesuai BAH yang
/// mempunyai e-Video Teori atau e-Video Ekstra.<br><br>
///
/// Jenis Produk Video yang digunakan:<br>
/// 1) e-Video Ekstra (id: 57).<br>
/// 2) e-Video Teori (id: 88).<br>
class VideoMapelList extends StatefulWidget {
  final bool isRencanaPicker;

  const VideoMapelList({
    Key? key,
    this.isRencanaPicker = false,
  }) : super(key: key);

  @override
  State<VideoMapelList> createState() => _VideoMapelListState();
}

class _VideoMapelListState extends State<VideoMapelList> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  final ScrollController _scrollController = ScrollController();

  UserModel? userData;

  List<Buku> listBuku = [];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is LoadedUser) {
      userData = authState.user;
    }
    _onRefreshVideoMapel();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JadwalVideoTeoriBloc, JadwalVideoTeoriState>(
        builder: (context, state) {
      if (state is JadwalVideoLoading) {
        return const ShimmerListTiles(isWatermarked: true);
      }

      if (state is JadwalVideoLoaded) {
        listBuku = state.listBukuVideo;
      }

      var refreshWidget = CustomSmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefreshVideoMapel,
        isDark: true,
        child: (listBuku.isEmpty)
            ? _getIllustrationImage()
            : _buildListBuku(listBuku),
      );

      return (listBuku.isEmpty)
          ? refreshWidget
          : WatermarkWidget(child: refreshWidget);
    });
  }

  bool _isProdukDibeli({bool ortuBolehAkses = false}) {
    bool isBeliVideoTeori =
        userData.isProdukDibeliSiswa(88, ortuBolehAkses: ortuBolehAkses);
    bool isBeliVideoEkstra =
        userData.isProdukDibeliSiswa(57, ortuBolehAkses: ortuBolehAkses);

    return isBeliVideoTeori || isBeliVideoEkstra;
  }

  // On Refresh Function
  Future<void> _onRefreshVideoMapel() async {
    // Function load and refresh data
    List<int> listIdProduk =
        userData?.listIdProduk == null ? [] : (userData?.listIdProduk ?? []);

    context
        .read<JadwalVideoTeoriBloc>()
        .add(LoadDaftarVideo(isRefresh: false, listIdProduk: listIdProduk));
  }

  // Get Illustration Image Function
  Widget _getIllustrationImage() {
    Widget noDataFound = NoDataFoundWidget(
      imageUrl:
          '${dotenv.env["BASE_URL_IMAGE"]}/arsip-mobile/img/ilustrasi_data_not_found.png',
      shrink: (context.dh < 600) ? !context.isMobile : false,
      subTitle: gEmptyProductSubtitle(
          namaProduk: 'Video Teori BAH',
          isProdukDibeli: _isProdukDibeli(ortuBolehAkses: true),
          isOrtu: userData.isOrtu,
          isNotSiswa: !userData.isSiswa),
      emptyMessage: gEmptyProductText(
        namaProduk: 'Video Teori BAH',
        isOrtu: userData.isOrtu,
        isProdukDibeli: _isProdukDibeli(ortuBolehAkses: true),
      ),
    );

    return (context.isMobile || context.dh > 600)
        ? noDataFound
        : SingleChildScrollView(
            child: noDataFound,
          );
  }

  List<Widget> _buildSubBukuItemList(
    int subJadwalVideoLength,
    List<List<Buku>> subListBuku,
    int index,
  ) {
    return (context.isMobile)
        ? List<Widget>.generate(
            subJadwalVideoLength,
            (subIndex) => _buildItemSubBuku(subListBuku[index][subIndex]),
          )
        : List<Widget>.generate(
            (subJadwalVideoLength.isEven)
                ? (subJadwalVideoLength / 2).floor()
                : (subJadwalVideoLength / 2).floor() + 1,
            (subIndex) => Padding(
              padding: const EdgeInsets.only(left: 48, right: 32, top: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildItemSubBuku(
                      subListBuku[index][subIndex * 2],
                      // height: 118,
                    ),
                  ),
                  const SizedBox(width: 20),
                  (((subIndex * 2) + 1) < subJadwalVideoLength)
                      ? Expanded(
                          child: _buildItemSubBuku(
                            subListBuku[index][(subIndex * 2) + 1],
                            // height: 118,
                          ),
                        )
                      : const Spacer(),
                ],
              ),
            ),
          );
  }

  Container _buildItemSubBuku(
    Buku buku, {
    double? height,
  }) {
    // buku.isTeaser;
    return Container(
      height: height,
      margin: EdgeInsets.only(
        top: 8,
        left: (context.isMobile) ? 48 : 0,
        right: (context.isMobile) ? 20 : 0,
      ),
      decoration: BoxDecoration(
          color: context.background,
          borderRadius: BorderRadius.circular((context.isMobile) ? 16 : 24),
          border: Border.all(color: context.outline)),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular((context.isMobile) ? 16 : 24),
        elevation: 0,
        child: InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            Constant.kRouteVideoJadwalBab,
            arguments: {
              'buku': buku,
              'idMataPelajaran': buku.idKelompokUjian.toString(),
              'namaMataPelajaran': buku.namaKelompokUjian,
              'tingkatSekolah': userData?.tingkatKelas,
              'isRencanaPicker': widget.isRencanaPicker
            },
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: (context.isMobile) ? 12 : 18,
              vertical: (context.isMobile) ? 10 : 14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  buku.namaBuku,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelMedium?.copyWith(
                    color: context.onBackground.withOpacity(0.86),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(context.textScale11),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Kelas:\n  ${buku.sekolahKelas}',
                          style: (context.isMobile)
                              ? context.text.bodySmall
                              : context.text.bodyMedium
                                  ?.copyWith(color: context.hintColor),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'Semester: ${buku.semester}\n',
                            style: (context.isMobile)
                                ? context.text.bodySmall
                                : context.text.bodyMedium
                                    ?.copyWith(color: context.hintColor),
                            children: [
                              TextSpan(
                                text: 'Level        : ${buku.levelTeori}',
                                style: (context.isMobile)
                                    ? context.text.bodySmall
                                    : context.text.bodyMedium
                                        ?.copyWith(color: context.hintColor),
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // List Bundel Widgets
  Widget _buildListBuku(List<Buku> listBuku) {
    final Map<String, List<Buku>> bukuGroupBy = listBuku.fold(
      {},
      (prev, buku) {
        prev
            .putIfAbsent('${buku.namaKelompokUjian}.${buku.isTeaser}', () => [])
            .add(buku);
        return prev;
      },
    );
    final List<String> label = bukuGroupBy.keys.toList();
    final List<List<Buku>> subListBuku = bukuGroupBy.values.toList();

    return ListView.separated(
      itemCount: bukuGroupBy.length,
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding:
          EdgeInsets.only(top: min(8, context.dp(4)), bottom: context.dp(30)),
      separatorBuilder: (_, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: DashedDivider(
          dashColor: context.outline,
          strokeWidth: 0.6,
          gap: 4,
          dash: 4,
          direction: Axis.horizontal,
        ),
      ),
      itemBuilder: (_, index) {
        final subJadwalVideoLength = subListBuku[index].length;
        final noExpandWidget = Container(
          padding: const EdgeInsets.only(top: 18, bottom: 18),
          child: IntrinsicHeight(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 14),
                    _buildLeadingItem(
                      buku: subListBuku[index].first,
                      isTeaser: subListBuku[index].first.isTeaser,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label[index].split('.')[0],
                            style: context.text.labelLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            'Singkatan: ${subListBuku[index].first.singkatan}',
                            style: context.text.labelSmall
                                ?.copyWith(color: context.hintColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                ),
                const SizedBox(height: 6),
                ..._buildSubBukuItemList(
                    subJadwalVideoLength, subListBuku, index),
              ],
            ),
          ),
        );

        return (subJadwalVideoLength < 3)
            ? noExpandWidget
            : CustomExpandedWidget(
                leadingItem: _buildLeadingItem(
                  buku: subListBuku[index].first,
                  isTeaser: subListBuku[index].first.isTeaser,
                ),
                title: label[index].split('.')[0],
                subTitle: 'Singkatan: ${subListBuku[index].first.singkatan}',
                moreItemCount: subJadwalVideoLength - 2,
                collapsedVisibilityFactor: 2 / subJadwalVideoLength,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildSubBukuItemList(
                        subJadwalVideoLength, subListBuku, index),
                  ),
                ),
              );
      },
    );
  }

  Widget _buildLeadingItem({required Buku buku, required bool isTeaser}) {
    var leadingWidget = (buku.imageUrl != null)
        ? CustomImageNetwork.rounded(
            buku.imageUrl!,
            width: 46,
            height: 46,
            fit: BoxFit.fitHeight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          )
        : ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.asset(
              'assets/img/default_buku.png',
              width: 46,
              height: 46,
              fit: BoxFit.fitHeight,
            ),
          );

    return !isTeaser
        ? leadingWidget
        : Container(
            padding: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                min(14, context.dp(14)),
              ),
              border: Border.all(color: context.tertiaryColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: context.tertiaryColor),
                  child: Text(
                    'TEASER',
                    style: context.text.labelSmall?.copyWith(
                      color: context.onTertiary,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                leadingWidget,
              ],
            ),
          );
  }
}
