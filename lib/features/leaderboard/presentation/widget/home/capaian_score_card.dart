part of 'leaderboard_home_widget.dart';

class CapaianScoreCard extends StatefulWidget {
  const CapaianScoreCard({Key? key}) : super(key: key);

  @override
  State<CapaianScoreCard> createState() => _CapaianScoreCardState();
}

class _CapaianScoreCardState extends State<CapaianScoreCard> {
  UserModel? userdata;
  CapaianScore? capaianKamu;

  @override
  void initState() {
    super.initState();
    final authstate = context.read<AuthBloc>().state;
    if (authstate is LoadedUser) {
      userdata = authstate.user;
    }
  }

  _onRefresh({bool isRefresh = false}) {
    // Dispatch the LoadCapaian event
    context.read<CapaianBloc>().add(
          LoadCapaian(
            userData: userdata,
            isRefresh: isRefresh,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      logger.log('CAPAIAN_SCORE_CARD: isLogin >> ${userdata.isLogin} '
          '|| isTamu >> ${userdata.isTamu}');
    }

    if (!userdata.isLogin || userdata.isTamu) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<CapaianBloc, CapaianState>(
      builder: (context, state) {
        bool isLoading = state is CapaianLoading;

        if (state is CapaianError) {
          return _buildRefreshWidget(
            'Gagal mengambil data Capaian Score, Coba lagi!',
          );
        }

        if (state is CapaianDataLoaded) {
          capaianKamu = state.capaianScore;
        }

        return CustomCard(
          padding: EdgeInsets.zero,
          margin: EdgeInsets.only(bottom: min(16, context.dp(12))),
          borderRadius: BorderRadius.circular(
            (context.isMobile) ? max(12, context.dp(12)) : context.dp(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: min(14, context.dp(10)),
                  right: min(14, context.dp(10)),
                  left: min(24, context.dp(16)),
                ),
                child: Row(
                  children: [
                    (isLoading)
                        ? ShimmerWidget.rounded(
                            width: 96,
                            height: 20,
                            borderRadius: BorderRadius.circular(max(64, context.dp(64))),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text('Capaian Skor', style: context.text.titleSmall),
                          ),
                    const Expanded(child: Divider(thickness: 0.6, indent: 2)),
                    _buildTotalScore(isLoading, context, capaianKamu),
                    _buildButtonRefresh(isLoading),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPhotoProfile(isLoading, context),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: min(8, context.dp(4)),
                        left: min(18, context.dp(8)),
                        right: min(20, context.dp(10)),
                        bottom: min(20, context.dp(10)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          (isLoading)
                              ? ShimmerWidget.rounded(
                                  width: 76,
                                  height: 16,
                                  borderRadius: BorderRadius.circular(max(64, context.dp(64))),
                                )
                              : Text(
                                  'Ranking Kamu',
                                  style: context.text.labelSmall?.copyWith(
                                    color: context.hintColor,
                                    fontSize: (context.isMobile) ? 10 : 12,
                                  ),
                                ),
                          _buildRankingCapaian(isLoading, context, capaianKamu),
                          (isLoading)
                              ? ShimmerWidget.rounded(
                                  width: 84,
                                  height: 16,
                                  borderRadius: BorderRadius.circular(max(64, context.dp(64))),
                                )
                              : Text(
                                  'Pengerjaan Soal',
                                  style: context.text.labelSmall?.copyWith(
                                    color: context.hintColor,
                                    fontSize: (context.isMobile) ? 10 : 12,
                                  ),
                                ),
                          ..._buildPengerjaanSoal(isLoading, context, capaianKamu),
                          const SizedBox(height: 10),
                          _buildButtonDetail(isLoading),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRefreshWidget(String message) {
    return AspectRatio(
      aspectRatio: 3,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        margin: EdgeInsets.only(
          bottom: min(20, context.dp(16)),
        ),
        decoration: BoxDecoration(
          color: context.background.withOpacity(0.34),
          borderRadius: BorderRadius.circular(
            (context.isMobile) ? max(12, context.dp(12)) : context.dp(10),
          ),
        ),
        child: RefreshExceptionWidget(
          message: message,
          onTap: () => _onRefresh(isRefresh: true),
        ),
      ),
    );
  }

  List<Widget> _buildPengerjaanSoal(
    bool isLoading,
    BuildContext context,
    CapaianScore? capaianKamu,
  ) {
    return [
      _buildTotalPengerjaanBar(isLoading, capaianKamu, context),
      const SizedBox(height: 4),
      _buildBenarSalahBar(isLoading, capaianKamu, context),
    ];
  }

  Widget _buildBenarSalahBar(
    bool isLoading,
    CapaianScore? capaianKamu,
    BuildContext context,
  ) {
    int totalBenar = (capaianKamu != null) ? capaianKamu.totalSoalBenar : 0;
    int totalSalah = (capaianKamu != null) ? capaianKamu.totalSoalSalah : 0;
    // totalSalah = 14;

    return (isLoading)
        ? Padding(
            padding: EdgeInsets.only(top: max(4, context.dp(4))),
            child: ShimmerWidget.rounded(
              width: context.dw - context.dp(187),
              height: 14,
              borderRadius: BorderRadius.circular(max(64, context.dp(64))),
            ),
          )
        : ComparisonBar(
            size: (context.isMobile) ? 14 : 20,
            labelSpacing: (context.isMobile) ? 4 : 12,
            prefixValue: totalBenar.toDouble(),
            suffixValue: totalSalah.toDouble(),
            prefixLabel: RichText(
              textScaler: TextScaler.linear(context.textScale12),
              text: TextSpan(
                  text: 'Benar\n',
                  style: context.text.bodySmall?.copyWith(fontSize: (context.isMobile) ? 8 : 12, color: context.hintColor),
                  children: [
                    TextSpan(
                      text: '$totalBenar',
                      style: context.text.labelSmall?.copyWith(fontSize: (context.isMobile) ? 10 : 16),
                    )
                  ]),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            suffixLabel: RichText(
              textScaler: TextScaler.linear(context.textScale12),
              text: TextSpan(
                  text: 'Salah\n',
                  style: context.text.bodySmall?.copyWith(fontSize: (context.isMobile) ? 8 : 12, color: context.hintColor),
                  children: [
                    TextSpan(
                      text: '$totalSalah',
                      style: context.text.labelSmall?.copyWith(fontSize: (context.isMobile) ? 10 : 16),
                    )
                  ]),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          );
  }

  Widget _buildTotalPengerjaanBar(
    bool isLoading,
    CapaianScore? capaianKamu,
    BuildContext context,
  ) {
    double targetSoal = (capaianKamu?.targetJumlahSoal ?? 0).toDouble();
    double totalSoalDikerjakan = (capaianKamu?.totalSoal ?? 0).toDouble();
    // targetSoal = 10000;
    // totalSoalDikerjakan = 0;
    bool isZero = totalSoalDikerjakan.toInt() <= 0;

    return (isLoading)
        ? Padding(
            padding: EdgeInsets.only(top: max(4, context.dp(4))),
            child: ShimmerWidget.rounded(
              width: context.dw - context.dp(187),
              height: (context.isMobile) ? 14 : 20,
              borderRadius: BorderRadius.circular(max(64, context.dp(64))),
            ),
          )
        : Row(
            children: [
              Expanded(
                child: CustomProgressBar(
                  currentValue: totalSoalDikerjakan,
                  maxValue: (capaianKamu == null)
                      ? 100.0
                      : (targetSoal > totalSoalDikerjakan)
                          ? targetSoal
                          : totalSoalDikerjakan,
                  size: (context.isMobile) ? 14 : 20,
                  backgroundColor: (isZero) ? Colors.grey.shade300 : context.primaryContainer,
                  progressColor: (isZero) ? Colors.grey.shade300 : context.primaryColor,
                  border: (isZero) ? Border.all(color: Colors.grey, width: 1.0) : null,
                  borderRadius: BorderRadius.circular(64),
                  formatValueFixed: 0,
                  displayText: (totalSoalDikerjakan <= (0.25 * targetSoal)) ? null : '  ',
                  displayTextStyle: TextStyle(
                    color: (totalSoalDikerjakan <= (0.25 * targetSoal)) ? context.onBackground : context.onPrimary.withOpacity(0.9),
                    fontSize: (context.isMobile) ? 9 : 11,
                  ),
                  // formatValue: ,
                ),
              ),
              SizedBox(width: (context.isMobile) ? 4 : 12),
              RichText(
                textScaler: TextScaler.linear(context.textScale12),
                text: TextSpan(
                    text: 'Target\n',
                    style: context.text.bodySmall?.copyWith(fontSize: (context.isMobile) ? 8 : 12, color: context.hintColor),
                    children: [
                      TextSpan(
                        text: '${targetSoal.toInt()}',
                        style: context.text.labelSmall?.copyWith(fontSize: (context.isMobile) ? 10 : 16),
                      )
                    ]),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          );
  }

  Widget _buildRankingCapaian(bool isLoading, BuildContext context, CapaianScore? capaianKamu) {
    Widget rankingCapaianText = Text(
      'Nasional: ${capaianKamu?.rankingNasional ?? '-'} | '
      'Kota: ${capaianKamu?.rankingKota ?? '-'} | '
      'Gedung: ${capaianKamu?.rankingGedung ?? '-'}',
      style: context.text.bodySmall?.copyWith(
        fontSize: (context.isMobile) ? 12 : 14,
        color: context.onBackground,
      ),
    );

    return (isLoading)
        ? Padding(
            padding: EdgeInsets.only(top: max(4, context.dp(4))),
            child: ShimmerWidget.rounded(
              width: context.dw - context.dp(187),
              height: 16,
              borderRadius: BorderRadius.circular(max(64, context.dp(64))),
            ),
          )
        : Container(
            width: context.dw - context.dp(187),
            padding: EdgeInsets.only(bottom: (context.isMobile) ? max(8, context.dp(6)) : 12),
            child: (context.isMobile || context.dw < 1100) ? FittedBox(child: rankingCapaianText) : rankingCapaianText,
          );
  }

  StatelessWidget _buildTotalScore(
    bool isLoading,
    BuildContext context,
    CapaianScore? capaianKamu,
  ) {
    return (isLoading)
        ? ShimmerWidget.rounded(
            width: 72,
            height: 32,
            borderRadius: BorderRadius.circular(
              (context.isMobile) ? max(12, context.dp(12)) : 22,
            ),
          )
        : Container(
            width: (context.isMobile) ? context.dp(82) : context.dp(44),
            height: (context.isMobile) ? max(context.dp(32), 32) : context.dp(18),
            padding: EdgeInsets.symmetric(
              horizontal: min(44, context.dp(14)),
              vertical: min(6, context.dp(4)),
            ),
            decoration: BoxDecoration(
              color: context.primaryColor,
              borderRadius: BorderRadius.circular(
                (context.isMobile) ? max(12, context.dp(12)) : 22,
              ),
            ),
            child: FittedBox(
              child: Text(
                '${capaianKamu?.totalScore ?? 0}',
                maxLines: 1,
                overflow: TextOverflow.fade,
                style: context.text.titleMedium?.copyWith(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
  }

  Widget _buildButtonDetail(bool isLoading) => (isLoading)
      ? ShimmerWidget.rounded(
          width: double.infinity,
          height: 32,
          borderRadius: BorderRadius.circular(
            (context.isMobile) ? max(12, context.dp(12)) : 22,
          ),
        )
      : GestureDetector(
          onTap: (isLoading)
              ? null
              : () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    constraints: BoxConstraints(maxWidth: min(650, context.dw)),
                    builder: (context) => const DetailCapaian(),
                  );
                },
          child: Container(
            width: double.infinity,
            height: (context.isMobile) ? max(context.dp(28), 12) : context.dp(12),
            padding: EdgeInsets.symmetric(
              horizontal: min(44, context.dp(14)),
              vertical: min(6, context.dp(4)),
            ),
            decoration: BoxDecoration(
              color: context.secondaryColor,
              borderRadius: BorderRadius.circular(
                (context.isMobile) ? max(12, context.dp(12)) : 22,
              ),
            ),
            child: FittedBox(
              child: Text(
                'Detail',
                maxLines: 1,
                overflow: TextOverflow.fade,
                style: context.text.titleMedium?.copyWith(
                  fontSize: 18,
                  color: context.onSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );

  Widget _buildButtonRefresh(bool isLoading) => (isLoading)
      ? const ShimmerWidget.circle(width: 30, height: 30)
      : GestureDetector(
          onTap: (isLoading)
              ? null
              : () {
                  context.read<CapaianBloc>().add(LoadCapaian(
                        userData: userdata,
                        isRefresh: true,
                      ));
                },
          child: Container(
            margin: const EdgeInsets.only(left: 7),
            width: (context.isMobile) ? 30 : 50,
            height: (context.isMobile) ? 30 : 50,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber,
                border: Border.all(
                  color: Colors.black,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ]),
            child: const Icon(Icons.refresh_rounded),
          ),
        );

  Widget _buildPhotoProfile(bool isLoading, BuildContext context) {
    double imageWidth = (context.isMobile) ? context.dp(130) : min(182, context.dp(60));
    double imageHeight = (context.isMobile) ? context.dp(165) : min(260, context.dp(110));

    return (isLoading)
        ? ShimmerWidget.rounded(
            width: imageWidth,
            height: imageHeight,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(
                (context.isMobile) ? max(28, context.dp(24)) : context.dp(14),
              ),
              bottomLeft: Radius.circular(
                (context.isMobile) ? max(12, context.dp(12)) : context.dp(10),
              ),
            ),
          )
        : IntrinsicHeight(
            child: ProfilePictureWidget.rounded(
              key: ValueKey('PHOTO_PROFILE_ROUNDED-${userdata?.noRegistrasi}-${userdata?.namaLengkap ?? 'GOmin'}'),
              noRegistrasi: userdata?.noRegistrasi ?? '',
              // userType: userData?.siapa ?? auth.userType,
              name: userdata?.namaLengkap ?? 'GOmin',
              photoUrl: (userdata == null) ? 'CaptainGO'.avatar : null,
              width: imageWidth,
              height: imageHeight,
              alignment: Alignment.bottomCenter,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(
                  (context.isMobile) ? max(28, context.dp(24)) : context.dp(14),
                ),
                bottomLeft: Radius.circular(
                  (context.isMobile) ? max(12, context.dp(12)) : context.dp(10),
                ),
              ),
              padding: EdgeInsets.only(top: context.dp(8), right: context.dp(4), left: context.dp(4)),
            ),
          );
  }
}
