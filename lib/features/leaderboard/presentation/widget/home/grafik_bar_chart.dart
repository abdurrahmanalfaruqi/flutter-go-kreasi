part of 'leaderboard_home_widget.dart';

class GrafikBarChart extends StatefulWidget {
  const GrafikBarChart({Key? key}) : super(key: key);

  @override
  State<GrafikBarChart> createState() => _GrafikBarChartState();
}

class _GrafikBarChartState extends State<GrafikBarChart> {
  late CapaianBarBloc capaianBloc;
  late final Color _barColor = context.primaryColor;
  final Color _touchedBarColor = Palette.kPrimarySwatch[700]!;
  late final Color _barBackgroundColor = context.primaryContainer;
  final Duration _animDuration = const Duration(milliseconds: 250);
  final ScrollController _scrollController = ScrollController();
  bool _isMinExtent = false;
  bool _isMaxExtent = false;
  bool? _isScrollable;
  late CapaianButtonBloc capaianButtonBloc;

  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    capaianBloc = BlocProvider.of<CapaianBarBloc>(context);
    capaianButtonBloc = context.read<CapaianButtonBloc>();

    _scrollController.addListener(_listenExtent);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // untuk cek apakah item overflow saat dibuild
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // isScrollable nullable supaya dijalankan 1 kali
      if (_isScrollable == null) {
        _isScrollable = _scrollController.position.extentAfter > 5;
        context
            .read<CapaianButtonBloc>()
            .add(InitialCapaianButton(_isScrollable!));
      }
    });
    return AspectRatio(
      aspectRatio: (context.isMobile) ? 12 / 8 : 16 / 9,
      child: BlocBuilder<CapaianBarBloc, CapaianBarState>(
        builder: (context, state) {
          if (state is CapaianBarDataLoaded) {
            return Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: max<double>(
                      context.dw -
                          ((context.isMobile)
                              ? context.dp(72)
                              : context.dp(182)),
                      state.listPengerjaanSoal.length *
                          ((context.isMobile)
                              ? context.dp(29)
                              : context.dp(15)),
                    ),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.center,
                        minY: 0,
                        titlesData: _buildTitlesData(context, state),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        barTouchData: _buildBarTouchData(context, state),
                        // TODO: Ganti dengan data yang telah diambil dari API.
                        barGroups: List<BarChartGroupData>.generate(
                          state.listPengerjaanSoal.length,
                          (indexMapelCapaian) {
                            PengerjaanSoal data =
                                state.listPengerjaanSoal[indexMapelCapaian];

                            double nilai =
                                (state.filterNilai == Filternilai.mingguan)
                                    ? data.pengerjaanMingguan.toDouble()
                                    : (state.filterNilai == Filternilai.bulanan)
                                        ? data.pengerjaanBulanan.toDouble()
                                        : data.pengerjaanHarian.toDouble();

                            double target =
                                (state.filterNilai == Filternilai.mingguan)
                                    ? data.targetMingguan.toDouble()
                                    : (state.filterNilai == Filternilai.bulanan)
                                        ? data.targetBulanan.toDouble()
                                        : data.targetHarian.toDouble();

                            return _makeGroupData(indexMapelCapaian, nilai,
                                toY: target,
                                isTouched: indexMapelCapaian == _touchedIndex);
                          },
                        ),
                      ),
                      swapAnimationDuration: _animDuration,
                      swapAnimationCurve: Curves.bounceOut,
                    ),
                  ),
                ),
                _buildChevronButton(
                  isRightPosition: false,
                  onTap: () {
                    double currentPosition = _scrollController.position.pixels;
                    double jumpTo = currentPosition - 30;
                    _scrollController.jumpTo(jumpTo);
                    context.read<CapaianButtonBloc>().add(SetExtentButton(
                          isMaxExtent: _scrollController.position.pixels <=
                              _scrollController.position.maxScrollExtent,
                          isMinExtent: _scrollController.position.pixels >= 0,
                        ));
                  },
                ),
                _buildChevronButton(
                  isRightPosition: true,
                  onTap: () {
                    double currentPosition = _scrollController.position.pixels;
                    double jumpTo = currentPosition + 30;
                    _scrollController.jumpTo(jumpTo);
                    context.read<CapaianButtonBloc>().add(SetExtentButton(
                          isMinExtent: _scrollController.position.pixels >= 0,
                          isMaxExtent: _scrollController.position.pixels <=
                              _scrollController.position.maxScrollExtent,
                        ));
                  },
                ),
              ],
            );
          }

          return const CircularProgressIndicator();
        },
      ),
    );
  }

  /// [_buildBarTouchData] merupakan function yang mengontrol apapun yang berkaitan dengan event saat Bar di tekan.
  BarTouchData _buildBarTouchData(
    BuildContext context,
    CapaianBarDataLoaded capaianBarDataLoaded,
  ) =>
      BarTouchData(
        enabled: true,

        /// [touchCallback] merupakan function callback ketika bar di tekan.
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              _touchedIndex = -1;
              return;
            }
            _touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },

        /// [BarTouchTooltipData] merupakan tooltip yang akan muncul saat Bar di tekan.
        touchTooltipData: BarTouchTooltipData(
          tooltipRoundedRadius: context.dp(6),
          tooltipBgColor: context.secondaryColor,
          maxContentWidth: (context.isMobile) ? 140 : 220,
          tooltipPadding: (context.isMobile)
              ? const EdgeInsets.all(6)
              : const EdgeInsets.all(12),
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipItem: (_, x, rodData, __) {
            PengerjaanSoal data = capaianBarDataLoaded.listPengerjaanSoal[x];

            double target =
                (capaianBarDataLoaded.filterNilai == Filternilai.mingguan)
                    ? data.targetMingguan.toDouble()
                    : (capaianBarDataLoaded.filterNilai == Filternilai.bulanan)
                        ? data.targetBulanan.toDouble()
                        : data.targetHarian.toDouble();

            double benar =
                (capaianBarDataLoaded.filterNilai == Filternilai.mingguan)
                    ? data.benarMingguan.toDouble()
                    : (capaianBarDataLoaded.filterNilai == Filternilai.bulanan)
                        ? data.benarBulanan.toDouble()
                        : data.benarHarian.toDouble();

            double salah =
                (capaianBarDataLoaded.filterNilai == Filternilai.mingguan)
                    ? data.salahMingguan.toDouble()
                    : (capaianBarDataLoaded.filterNilai == Filternilai.bulanan)
                        ? data.salahBulanan.toDouble()
                        : data.salahHarian.toDouble();

            return BarTooltipItem(
              data.nama,
              context.text.labelMedium!.copyWith(color: context.onSecondary),
              textAlign: TextAlign.start,
              children: [
                const TextSpan(
                  text: '\n\n',
                  style: TextStyle(fontSize: 2),
                ),
                TextSpan(
                  text: 'Target: ${target.floor()}\n',
                  style: context.text.bodySmall!.copyWith(
                    color: context.onSecondary,
                    fontSize: 11,
                  ),
                ),
                TextSpan(
                  text: 'Benar:${benar.floor()}  Salah:${salah.floor()}',
                  style: context.text.bodySmall!.copyWith(
                    color: context.onSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            );
          },
        ),
      );

  /// [_buildTitlesData] merupakan function untuk membuat label pada grafik.
  FlTitlesData _buildTitlesData(
    BuildContext context,
    CapaianBarDataLoaded capaianBarDataLoaded,
  ) =>
      FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            reservedSize: min(74, context.dp(56)),
            showTitles: true,
            // TODO: Gunakan singkatan mapel untuk menjadi label.
            getTitlesWidget: (x, meta) {
              int index = x.toInt();
              // kInitialKelompokUjian;
              String initialMapel = ' ???';
              String namaMapel = 'Unidentified';
              if (index < capaianBarDataLoaded.listPengerjaanSoal.length) {
                PengerjaanSoal data =
                    capaianBarDataLoaded.listPengerjaanSoal[x.toInt()];

                initialMapel = data.initial;
                namaMapel = data.nama;
                // if (Constant.kInitialKelompokUjian.containsKey(data.idMapel)) {
                //   initialMapel =
                //       ' ${Constant.kInitialKelompokUjian[data.idMapel]!['initial']}';
                //   namaMapel =
                //       Constant.kInitialKelompokUjian[data.idMapel]!['nama'] ??
                //           'Unidentified';
                // }
              }
              return Tooltip(
                message: namaMapel,
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Text(initialMapel,
                      style: context.text.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              );
            },
          ),
        ),
        // TODO: Jika ingin menambahkan Target score label, tambahkan pada topTitles
        // NOTE: Target soal rencananya akan ada per mapel.
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (x, meta) {
              List<PengerjaanSoal> pengerjaanSoal =
                  (capaianBloc.state as CapaianBarDataLoaded)
                      .listPengerjaanSoal;

              if (pengerjaanSoal.isEmpty ||
                  x.toInt() >= pengerjaanSoal.length) {
                return Text('0', style: context.text.bodySmall);
              }
              PengerjaanSoal data = pengerjaanSoal[x.toInt()];

              int dataPengerjaan = (capaianBarDataLoaded.filterNilai ==
                      Filternilai.mingguan)
                  ? data.targetMingguan
                  : (capaianBarDataLoaded.filterNilai == Filternilai.bulanan)
                      ? data.targetBulanan
                      : data.targetHarian;

              return Text('$dataPengerjaan', style: context.text.bodySmall);
            },
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  /// [_makeGroupData] merupakan Group of Bar Chart.<br><br>
  /// [x] merupakan index secara horizontal. Bisa menggunakan hitungan 0,1,2...n<br>
  /// [y] merupakan index secara vertical. Dalam grafik ini adalah score tiap mapel.<br>
  /// [toY] merupakan target jumlah soal dari masing-masing mapel.<br>
  /// [isTouched] merupakan status untuk merubah state Bar ketika ditekan (untuk menampilkan tooltips).<br>
  /// [showTooltips] merupakan array of bool. Gunakan jika ingin mengatur tooltips pada [x] mana yang akan di disable.
  BarChartGroupData _makeGroupData(
    int x,
    double y, {
    double? toY,
    bool isTouched = false,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barsSpace: min(16, context.dp(10)),
      barRods: [
        BarChartRodData(
          fromY: 0,
          width: min(22, context.dp(12)),
          borderRadius: BorderRadius.circular(30),
          toY: isTouched ? y + (y * 0.3) : y,
          color: isTouched ? _touchedBarColor : _barColor,
          backDrawRodData: BackgroundBarChartRodData(
            fromY: 0,
            toY: toY ?? y,
            color: _barBackgroundColor,
            show: true,
          ),
        )
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  void _listenExtent() {
    _isMinExtent = _scrollController.position.pixels == 0;
    _isMaxExtent = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent;

    // ketika item capaian tidak overflow/tidak melebihi containernya maka tidak
    // menjalankan event
    if (capaianButtonBloc.state is! CapaianButtonDisable) {
      context.read<CapaianButtonBloc>().add(SetExtentButton(
            isMinExtent: _isMinExtent,
            isMaxExtent: _isMaxExtent,
          ));
    }
  }

  Widget _buildChevronButton({
    required bool isRightPosition,
    required Function() onTap,
  }) {
    return BlocBuilder<CapaianButtonBloc, CapaianButtonState>(
      builder: (context, state) {
        bool isMinExtent = false;
        bool isMaxExtent = false;
        if (state is CapaianButtonDisable) {
          return Container();
        }

        if (state is LoadedInitCapaianButton) {
          isMinExtent = state.isScrollable;
        }

        if (state is LoadedExtentButton) {
          isMinExtent = state.isMinExtent;
          isMaxExtent = state.isMaxExtent;
        }

        return SizedBox(
          child: Column(
            children: [
              const Spacer(),
              Row(
                children: [
                  if (isRightPosition) const Spacer(),
                  Visibility(
                    visible: isRightPosition ? isMinExtent : isMaxExtent,
                    child: GestureDetector(
                      onTap: onTap,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 7,
                                offset: const Offset(
                                    0, 3), // changes position of shadow
                              ),
                            ]),
                        child: Icon(
                          isRightPosition
                              ? Icons.chevron_right
                              : Icons.chevron_left,
                        ),
                      ),
                    ),
                  ),
                  if (!isRightPosition) const Spacer(),
                ],
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}
