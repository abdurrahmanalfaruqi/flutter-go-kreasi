part of 'leaderboard_home_widget.dart';

class JuaraBukuSaktiWidget extends StatefulWidget {
  final bool isLogin;
  final bool isNotTamu;
  final UserModel? userData;
  final String? idSekolahKelas;
  final String tahunAjaran;

  const JuaraBukuSaktiWidget({
    Key? key,
    required this.isLogin,
    required this.isNotTamu,
    this.userData,
    this.idSekolahKelas,
    required this.tahunAjaran,
  }) : super(key: key);

  @override
  State<JuaraBukuSaktiWidget> createState() => _JuaraBukuSaktiWidgetState();
}

class _JuaraBukuSaktiWidgetState extends State<JuaraBukuSaktiWidget> {
  bool isCapaianBarError = false;
  bool isCapaianScoreError = false;

  @override
  Widget build(BuildContext context) {
    final double padding = (context.isMobile) ? context.dp(12) : context.dp(8);
    return BlocBuilder<CapaianBloc, CapaianState>(
      builder: (context, capaianState) {
        if (capaianState is CapaianError) {
          isCapaianScoreError = true;
        }

        if (capaianState is CapaianDataLoaded) {
          isCapaianScoreError = false;
        }

        return BlocBuilder<CapaianBarBloc, CapaianBarState>(
          builder: (context, state) {
            if (state is CapaianBarError) {
              isCapaianBarError = true;
            }

            if (state is CapaianBarDataLoaded) {
              isCapaianBarError = false;
            }

            return Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                // bottom: padding,
                left: padding,
                right: padding,
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    (context.isMobile)
                        ? max(24, context.dp(24))
                        : context.dp(18),
                  ),
                  border: Border.all(
                      color: context.secondaryColor.withOpacity(0.87),
                      width: 2)),
              child: Transform.translate(
                offset: Offset(0, padding * -1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 12),
                      // transform: vector.Matrix4.translation(vector.Vector3(0, padding * -1, 0)),
                      margin: EdgeInsets.only(
                        top: (!context.isMobile) ? context.dp(4) : 0,
                        bottom: min(14, context.dp(6)),
                      ),
                      decoration: BoxDecoration(
                          color: context.secondaryColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8))),
                      child: Text(
                        'Leaderboard',
                        style: context.text.labelSmall,
                      ),
                    ),
                    CustomImageNetwork(
                      'top_skor_header.png'.imgUrl,
                      height:
                          (context.isMobile) ? context.dp(54) : context.dp(32),
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                    _buildJuaraSatuBukuSakti(context),
                    if (!widget.isLogin ||
                        !widget.isNotTamu ||
                        (isCapaianBarError && isCapaianScoreError))
                      const BelumMengerjakanSoalCard(),
                    // TODO: Jika User login, maka tampilkan capaian score dia (jika ada).
                    if (widget.isLogin &&
                        widget.isNotTamu &&
                        !isCapaianScoreError)
                      const CapaianScoreCard(),
                    if (widget.isLogin &&
                        widget.isNotTamu &&
                        !isCapaianBarError)
                      const GrafikHasilLatihanCard(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Padding _buildJuaraSatuBukuSakti(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: (context.isMobile) ? context.dp(14) : context.dp(8),
      ),
      child: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, state) {
          return FutureBuilder<void>(
            future: state is LeaderboardDataLoaded
                ? Future.value(state.listRankingSatuBukuSakti)
                : null,
            builder: (context, snapshot) {
              bool isLoading =
                  snapshot.connectionState == ConnectionState.waiting ||
                      state is LeaderboardLoading;
              List<RankingSatuModel> listJuara = [];
              if (state is LeaderboardDataLoaded) {
                listJuara = state.listRankingSatuBukuSakti;
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: (listJuara.isEmpty || isLoading)
                    ? List<ItemJuaraBukuSakti>.generate(
                        3,
                        (index) => ItemJuaraBukuSakti(
                              isLoading: isLoading,
                              noRegistrasi: '-',
                              name: '......',
                              score: '...',
                              juaraType: index == 0
                                  ? 'Nasional'
                                  : index == 1
                                      ? 'Kota'
                                      : 'Gedung',
                            ))
                    : listJuara
                        .map<Widget>(
                          (list) => ItemJuaraBukuSakti(
                            noRegistrasi: list.noRegistrasi,
                            name: list.namaLengkap,
                            score: list.score,
                            photoUrl: list.photoUrl,
                            juaraType: list.tipe,
                          ),
                        )
                        .toList(),
              );
            },
          );
        },
      ),
    );
  }
}
