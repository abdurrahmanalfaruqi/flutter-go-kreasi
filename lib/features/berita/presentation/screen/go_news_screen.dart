import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/berita/presentation/bloc/news_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/appbar/custom_app_bar.dart';
import '../../../../core/shared/widget/refresher/custom_smart_refresher.dart';
import '../../../auth/data/model/user_model.dart';
import '../widget/go_news/go_news_item.dart';

class GoNewsScreen extends StatefulWidget {
  const GoNewsScreen({Key? key}) : super(key: key);

  @override
  State<GoNewsScreen> createState() => _GoNewsScreenState();
}

class _GoNewsScreenState extends State<GoNewsScreen> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Future<void> _onRefresh(
    BuildContext context, {
    UserModel? userData,
    bool refresh = false,
  }) async {
    // monitor network fetch
    context.read<NewsBloc>().add(LoadNews(
          userType: userData?.siapa ?? 'UMUM',
          isRefresh: refresh,
        ));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  @override
  void reassemble() {
    _refreshController.dispose();
    super.reassemble();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseUrlImage = dotenv.env["BASE_URL_IMAGE"] ?? '';
    return Scaffold(
      backgroundColor: context.primaryColor,
      appBar: CustomAppBar(
        context,
        centerTitle: true,
        implyLeadingDark: false,
        title: CachedNetworkImage(
          imageUrl: '$baseUrlImage/arsip-mobile/img/txt_go_news.png',
          height: context.dp(32),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                context.primaryColor,
                context.secondaryColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.3, 1]),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  context.primaryColor,
                  context.secondaryColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.3, 1]),
          ),
          child: Builder(builder: (context) {
            return BlocSelector<AuthBloc, AuthState, UserModel?>(
              selector: (state) => (state is LoadedUser) ? state.user : null,
              builder: (context, userData) {
                return BlocBuilder<NewsBloc, NewsState>(
                  builder: (context, state) {
                    if (state is NewsDataLoaded) {
                      if (state.allNews == null) return Container();
                      return CustomSmartRefresher(
                        isDark: true,
                        controller: _refreshController,
                        onRefresh: () async => await _onRefresh(
                          context,
                          userData: userData,
                          refresh: true,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                            top: context.dp(8),
                            bottom: context.dp(18),
                          ),
                          itemCount: state.allNews?.length,
                          itemBuilder: (_, index) =>
                              GoNewsItem(berita: state.allNews![index]),
                        ),
                      );
                    }

                    return Container();
                  },
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
