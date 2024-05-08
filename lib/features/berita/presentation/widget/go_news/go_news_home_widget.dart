import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/features/berita/presentation/bloc/news_bloc.dart';
import '../../../../../core/config/global.dart';
import '../../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../../../auth/data/model/user_model.dart';

import 'go_news_item.dart';
import '../../../../../core/config/constant.dart';
import '../../../../../core/config/extensions.dart';
import '../../../../../core/shared/widget/image/custom_image_network.dart';

class GoNewsHomeWidget extends StatefulWidget {
  final UserModel? userData;

  const GoNewsHomeWidget({Key? key, this.userData}) : super(key: key);

  @override
  State<GoNewsHomeWidget> createState() => _GoNewsHomeWidgetState();
}

class _GoNewsHomeWidgetState extends State<GoNewsHomeWidget> {
  @override
  void initState() {
    super.initState();
    _onRefresh(isRefresh: false);
  }

  @override
  Widget build(BuildContext context) {
    CustomImageNetwork imageGoNews = CustomImageNetwork(
      'go_news.webp'.imgUrl,
      width: min(140, context.dp(100)),
      height: min(140, context.dp(100)),
      fit: BoxFit.contain,
    );

    return BlocBuilder<NewsBloc, NewsState>(
      builder: (context, state) {
        if (state is NewsError) {
          return _buildEmptyRefresh(context, imageGoNews);
        }

        if (state is NewsLoading) {
          return AspectRatio(
            aspectRatio: 16 / 7,
            child: ShimmerWidget.rounded(
              width: double.infinity,
              height: double.infinity,
              borderRadius: gDefaultShimmerBorderRadius,
            ),
          );
        }

        if (state is NewsDataLoaded) {
          return SizedBox(
            height: (context.isMobile) ? context.dp(179) : context.dp(82),
            child: (state.headlineNews?.isEmpty == true)
                ? _buildEmptyRefresh(context, imageGoNews)
                : ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: ((state.headlineNews?.length ?? 0) < 10 ||
                            (state.allNews?.length ?? 0) <= 10)
                        ? (state.headlineNews?.length ?? 0) + 1
                        : (state.headlineNews?.length ?? 0) + 2,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: context.dp(24)),
                    itemBuilder: (_, index) => (index > 0 &&
                            index <= (state.headlineNews?.length ?? 0))
                        ? GoNewsItem(
                            isHome: true,
                            berita: state.headlineNews![index - 1])
                        : (index == 0)
                            ? imageGoNews
                            : _buildButtonLainnya(context),
                  ),
          );
        }

        return _buildEmptyRefresh(context, imageGoNews);
      },
    );
  }

  Padding _buildEmptyRefresh(
      BuildContext context, CustomImageNetwork imageGoNews) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.dp(24)),
      child: LayoutBuilder(builder: (context, constraint) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            imageGoNews,
            SizedBox(width: min(24, context.dp(12))),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: constraint.maxWidth -
                        ((context.isMobile) ? context.dp(120) : context.dp(64)),
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(
                      (context.isMobile) ? context.dp(12) : context.dp(8),
                    ),
                    decoration: BoxDecoration(
                      color: context.background,
                      borderRadius: BorderRadius.circular(
                        (context.isMobile)
                            ? max(12, context.dp(12))
                            : context.dp(8),
                      ),
                    ),
                    child: Text(
                      'Tidak Ada Berita Untuk Saat Ini',
                      style: context.text.labelMedium,
                      overflow: TextOverflow.ellipsis,
                      maxLines: (context.isMobile) ? 1 : 3,
                    ),
                  ),
                  TextButton(
                    onPressed: () async => _onRefresh(),
                    style: TextButton.styleFrom(
                        textStyle: context.text.labelSmall),
                    child: const Text('Muat Ulang'),
                  )
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildButtonLainnya(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: context.dp(24), right: context.dp(14)),
      child: Center(
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, Constant.kRouteGoNews),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotatedBox(
                quarterTurns: 3,
                child: Icon(Icons.expand_circle_down_outlined,
                    size: 64, color: context.primaryColor),
              ),
              Text('Lainnya',
                  style: context.text.titleMedium?.copyWith(
                      color: context.primaryColor, fontWeight: FontWeight.w700))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onRefresh({bool isRefresh = true}) async {
    context.read<NewsBloc>().add(LoadNews(
          userType: widget.userData?.siapa ?? 'UMUM',
          isRefresh: isRefresh,
        ));
  }
}
