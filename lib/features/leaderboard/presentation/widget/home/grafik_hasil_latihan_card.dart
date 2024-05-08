part of 'leaderboard_home_widget.dart';

class GrafikHasilLatihanCard extends StatefulWidget {
  const GrafikHasilLatihanCard({Key? key}) : super(key: key);

  @override
  State<GrafikHasilLatihanCard> createState() => _GrafikHasilLatihanCardState();
}

class _GrafikHasilLatihanCardState extends State<GrafikHasilLatihanCard> {
  static const List<String> _filternilai = [
    'Hari ini',
    'Minggu ini',
    'Bulan ini'
  ];

  late String? _selectedFilter = _filternilai[0];
  UserModel? userdata;

  @override
  void initState() {
    super.initState();
    final authstate = context.read<AuthBloc>().state;
    if (authstate is LoadedUser) {
      userdata = authstate.user;
    }
  }

  _onRefresh({required bool isRefresh}) async {
    context.read<CapaianBarBloc>().add(LoadCapaianBar(
          userData: userdata,
          isRefresh: isRefresh,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CapaianBarBloc, CapaianBarState>(
      builder: (context, state) {
        if (state is CapaianLoading) {
          return ShimmerWidget(
            width: context.dw - context.dp(48),
            height: (context.isMobile) ? context.dp(180) : context.dp(120),
            borderRadius: BorderRadius.circular(
              (context.isMobile) ? max(12, context.dp(12)) : context.dp(10),
            ),
          );
        }

        if (state is CapaianBarError) {
          return _buildRefreshWidget(state.errorMessage);
        }

        if (state is CapaianBarDataLoaded) {
          if (state.listPengerjaanSoal.isEmpty) {
            return const BelumMengerjakanSoalCard();
          }
          return Container(
            width: context.dw - context.dp(48),
            padding: EdgeInsets.all(min(20, context.dp(12))),
            margin: EdgeInsets.only(top: min(10, context.dp(6))),
            decoration: BoxDecoration(
              color: context.background,
              borderRadius: BorderRadius.circular(
                (context.isMobile) ? max(12, context.dp(12)) : context.dp(10),
              ),
            ),
            child: _buildGrafikWidget(context),
          );
        }
        return ShimmerWidget(
          width: context.dw - context.dp(48),
          height: (context.isMobile) ? context.dp(180) : context.dp(120),
          borderRadius: BorderRadius.circular(
            (context.isMobile) ? max(12, context.dp(12)) : context.dp(10),
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

  /// Jika user login dan sudah mengerjakan buku sakti, maka tampilkan grafik
  Column _buildGrafikWidget(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<CapaianBarBloc, CapaianBarState>(
          builder: (context, state) {
            return Row(
              children: [
                SizedBox(
                  width: min(148, context.dp(103)),
                  child: DropdownButtonFormField<String>(
                    value: _selectedFilter,
                    borderRadius: BorderRadius.circular(max(8, context.dp(8))),
                    items: _filternilai
                        .map<DropdownMenuItem<String>>(
                            (filter) => DropdownMenuItem<String>(
                                  value: filter,
                                  child: Text(filter),
                                  onTap: () {},
                                ))
                        .toList(),
                    onChanged: (selectedFilter) {
                      switch (selectedFilter) {
                        case 'Minggu ini':
                          context.read<CapaianBarBloc>().add(SetFilternilai(
                              filternilai: Filternilai.mingguan));
                          break;
                        case 'Bulan ini':
                          context.read<CapaianBarBloc>().add(
                              SetFilternilai(filternilai: Filternilai.bulanan));
                          break;
                        default:
                          context.read<CapaianBarBloc>().add(
                              SetFilternilai(filternilai: Filternilai.harian));
                          break;
                      }
                      setState(() => _selectedFilter = selectedFilter!);
                    },
                    isDense: true,
                    alignment: Alignment.center,
                    iconSize: min(24, context.dp(20)),
                    icon: const Icon(Icons.expand_more_rounded),
                    style: context.text.bodySmall
                        ?.copyWith(color: context.onBackground),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        gapPadding: 0,
                        borderRadius:
                            BorderRadius.circular(max(6, context.dp(6))),
                        borderSide: BorderSide(color: context.onBackground),
                      ),
                      focusedBorder: OutlineInputBorder(
                        gapPadding: 0,
                        borderRadius:
                            BorderRadius.circular(max(6, context.dp(6))),
                        borderSide: BorderSide(color: context.onBackground),
                      ),
                      enabledBorder: OutlineInputBorder(
                        gapPadding: 0,
                        borderRadius:
                            BorderRadius.circular(max(6, context.dp(6))),
                        borderSide: BorderSide(color: context.onBackground),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: (context.isMobile) ? 4 : 10,
                        horizontal: (context.isMobile) ? 6 : 12,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                SizedBox(width: min(14, context.dp(6))),
                Expanded(
                  child: (context.isMobile || context.dw < 1100)
                      ? FittedBox(
                          child: Text(
                            'Sobat, Gimana hasil latihan kamu?',
                            style: context.text.bodySmall
                                ?.copyWith(color: context.hintColor),
                          ),
                        )
                      : Text(
                          'Sobat, Gimana hasil latihan kamu?',
                          style: context.text.bodySmall
                              ?.copyWith(color: context.hintColor),
                        ),
                ),
              ],
            );
          },
        ),
        SizedBox(height: min(20, context.dp(12))),
        const GrafikBarChart(),
      ],
    );
  }
}
