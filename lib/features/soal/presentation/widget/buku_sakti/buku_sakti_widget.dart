part of '../buku_soal_menu.dart';

class BukuSaktiWidget extends StatefulWidget {
  final int? idJenisProduk;
  final String? kodeTOB;
  final String? kodePaket;
  final String? diBukaDari;

  const BukuSaktiWidget({
    Key? key,
    this.idJenisProduk,
    this.kodeTOB,
    this.kodePaket,
    this.diBukaDari,
  }) : super(key: key);

  @override
  State<BukuSaktiWidget> createState() => _BukuSaktiWidgetState();
}

class _BukuSaktiWidgetState extends State<BukuSaktiWidget>
    with TickerProviderStateMixin {
  // Initial selected menu index
  late final _initialIndex = (widget.idJenisProduk == null)
      ? 0
      : MenuProvider.listMenuBukuSakti
          .indexWhere((menu) => menu.idJenis == widget.idJenisProduk);

  late TabController _tabController =
      TabController(length: 3, initialIndex: _initialIndex, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SoalBloc, SoalState, List<Menu>?>(
      selector: (state) => (state.soalStatus == SoalStatus.success &&
              state.bukuSoal?.listBukuSakti?.isNotEmpty == true)
          ? state.bukuSoal?.listBukuSakti
          : MenuProvider.listMenuBukuSakti,
      builder: (context, listMenuBukuSakti) {
        _tabController = TabController(
            length: listMenuBukuSakti?.length ?? 3,
            initialIndex: _initialIndex,
            vsync: this);

        List<Widget> listBukuSaktiWidget =
            listMenuBukuSakti?.map((menuBukuSakti) {
                  if (menuBukuSakti.idJenis == 76) {
                    // LATEKS
                    return BundelSoalList(
                      idJenisProduk: menuBukuSakti.idJenis,
                      namaJenisProduk: menuBukuSakti.namaJenisProduk,
                    );
                  } else {
                    // EMMA, EMWA
                    return PaketSoalList(
                      idJenisProduk: menuBukuSakti.idJenis,
                      namaJenisProduk: menuBukuSakti.namaJenisProduk,
                      diBukaDari:
                          widget.diBukaDari ?? Constant.kRouteBukuSoalScreen,
                    );
                  }
                }).toList() ??
                [];

        return Column(
          children: [
            if (!context.isMobile) SizedBox(height: context.dp(6)),
            TabBar(
              controller: _tabController,
              indicatorWeight: 2,
              indicatorSize: (listMenuBukuSakti?.length == 3)
                  ? TabBarIndicatorSize.label
                  : TabBarIndicatorSize.tab,
              labelColor: context.onBackground,
              indicatorColor: context.onBackground,
              labelStyle: context.text.bodyMedium,
              unselectedLabelStyle: context.text.bodyMedium,
              unselectedLabelColor: context.onBackground.withOpacity(0.54),
              padding: EdgeInsets.symmetric(horizontal: context.dp(24)),
              indicatorPadding: EdgeInsets.zero,
              labelPadding: EdgeInsets.zero,
              tabs: listMenuBukuSakti
                      ?.map((bukuSakti) => Tab(
                            text: bukuSakti.label,
                          ))
                      .toList() ??
                  [],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const ClampingScrollPhysics(),
                children: [...listBukuSaktiWidget],
              ),
            ),
          ],
        );
      },
    );
  }
}
