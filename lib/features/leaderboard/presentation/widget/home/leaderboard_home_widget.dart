import 'dart:async';
import 'dart:math';
import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/leaderboard/presentation/bloc/capaian/capaian_bloc.dart';
import 'package:gokreasi_new/features/leaderboard/presentation/bloc/capaian_button/capaian_button_bloc.dart';
import 'package:gokreasi_new/features/leaderboard/presentation/bloc/capaianbar/capaianbar_bloc.dart';
import 'package:gokreasi_new/features/leaderboard/presentation/bloc/leaderboard/leaderboard_bloc.dart';
// import 'package:vector_math/vector_math_64.dart' as vector;


import '../../widget/home/detail_capaian.dart';
import '../../../model/capaian_score.dart';
import '../../../model/pengerjaan_soal.dart';
import '../../../model/ranking_satu_model.dart';
import '../../../../auth/data/model/user_model.dart';
import '../../../../../core/config/theme.dart';
import '../../../../../core/config/constant.dart';
import '../../../../../core/config/extensions.dart';
import '../../../../../core/shared/widget/card/custom_card.dart';
import '../../../../../core/shared/widget/chart/progress_bar.dart';
import '../../../../../core/shared/widget/chart/comparison_bar.dart';
import '../../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../../../../core/shared/widget/image/custom_image_network.dart';
import '../../../../../core/shared/widget/image/profile_picture_widget.dart';
import '../../../../../core/shared/widget/exception/refresh_exception_widget.dart';

part 'grafik_bar_chart.dart';
part 'capaian_score_card.dart';
part 'item_juara_buku_sakti.dart';
part 'juara_buku_sakti_widget.dart';
part 'grafik_hasil_latihan_card.dart';
part 'belum_mengerjakan_soal_card.dart';

