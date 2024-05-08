import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as logger show log;
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/core/config/constant.dart';
import 'package:gokreasi_new/core/config/enum.dart';
import 'package:gokreasi_new/core/config/extensions.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/helper/hive_helper.dart';
import 'package:gokreasi_new/core/helper/kreasi_shared_pref.dart';
import 'package:gokreasi_new/core/util/app_exceptions.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import 'package:gokreasi_new/features/auth/data/model/bundling_model.dart';
import 'package:gokreasi_new/features/auth/data/model/produk_dibeli_model.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/domain/usecase/auth_usecase.dart';
import 'package:gokreasi_new/features/bookmark/domain/entity/bookmark.dart';
import 'package:gokreasi_new/features/profile/domain/entity/kelompok_ujian.dart';
import 'package:gokreasi_new/features/soal/module/bundel_soal/presentation/bloc/bundel_soal/bundel_soal_bloc.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/presentation/bloc/tobk/tobk_bloc.dart';
import 'package:otp/otp.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthEvent>((event, emit) async {
      const String errorNomorHp = 'Mohon masukkan nomor registrasi Anda';
      String? nomorHp;

      UserModel? userModelTemp;

      if (event is AuthGenerateOTP) {
        try {
          final generatedOTP = OTP.generateTOTPCodeString(
            Constant.secretOTP,
            DateTime.now().serverTimeFromOffset.millisecondsSinceEpoch,
            length: 6,
            interval: 10,
          );

          if (kDebugMode) {
            logger.log(
                'AUTH_OTP_PROVIDER-GenerateOTP: OTP Generated >> $generatedOTP');
          }
          emit(LoadedOTP(generatedOTP));
        } on DataException catch (e) {
          if (kDebugMode) {
            logger.log('DataException-GenerateOTP: $e');
          }
          var rng = Random();
          int formattedOTP = rng.nextInt(900000) + 100000;
          emit(LoadedOTP(formattedOTP.toString()));
        } catch (e) {
          if (kDebugMode) {
            logger.log('FatalException-GenerateOTP: $e');
          }
          var rng = Random();
          int formattedOTP = rng.nextInt(900000) + 100000;
          emit(LoadedOTP(formattedOTP.toString()));
        }
      }

      if (event is AuthLogin) {
        if (event.noRegistrasiRefresh == null) {
          emit(AuthLoading());
        }

        if (event.nomorReg.isEmpty) {
          emit(const AuthError(errorNomorHp));
          return;
        }

        try {
          nomorHp = event.nomorReg.trim();
          String? imei = (gAkunTesterSiswa.contains(nomorHp))
              ? gTesterImeiSiswa
              : await gGetIdDevice();

          if (kDebugMode) {
            logger.log('AUTH_OTP_PROVIDER-Login: imei >> $imei');
          }

          if (imei == null) {
            emit(AuthError(gPesanErrorImeiPermission));
            return;
          }

          Map<String, dynamic> params = {}
            ..['id_dev'] = imei
            ..['meta'] = {
              "merk": await gMerkHp(),
              "os": await gVersiOS(),
            };

          switch (event.userTypeRefresh.toLowerCase()) {
            case 'siswa':
              params['noreg'] = nomorHp;
              break;
            case 'ortu':
              params['noHP'] = nomorHp;
              break;
            default:
          }

          final responseLogin =
              await locator<LoginSiswaUseCase>().call(params: params);

          if (responseLogin['meta']["code"] == 200) {
            gTokenJwt = responseLogin['data']['DataSiswa']['tokenJWT'];

            final Map<String, dynamic> detailParams = {}
              ..['noreg'] = event.nomorReg
              ..['token'] = gTokenJwt;

            final res = await locator<GetDetailSiswa>().call(
              params: detailParams,
            );

            gTokenJwt = res['data']['tokenJWT'];

            DioOptionHelper().setDioOption = gTokenJwt;

            String? refreshAccessToken = res['data']['refreshToken'];
            if (refreshAccessToken != null) {
              await KreasiSharedPref().setRefreshToken(refreshAccessToken);
            }

            final user = responseLoginToUserModel(res);

            final Map<String, dynamic> dataSekolahParams = {
              'id_sekolah': user.idSekolah,
              'id_sekolah_kelas': user.idSekolahKelas,
              'token': gTokenJwt,
            };
            final resDataSekolah = await locator<GetDataSekolahSiswa>().call(
              params: dataSekolahParams,
            );

            DataSekolahSiswa dataSekolahSiswa = DataSekolahSiswa.fromJson(
              resDataSekolah,
            );

            final newData = user.copyWith(
              namaSekolah: dataSekolahSiswa.namaSekolah,
              tingkat: dataSekolahSiswa.tingkatKelas,
              tingkatKelas: dataSekolahSiswa.tingkatKelas,
              namaSekolahKelas: dataSekolahSiswa.namaSekolahKelas,
              isBolehPTN: dataSekolahSiswa.isBolehPTN,
            );

            gUser = newData;

            await KreasiSharedPref().simpanDataLokal();
            await KreasiSharedPref().setNomorReg(event.nomorReg);
            await KreasiSharedPref().setSiapa('SISWA');

            locator<SetTargetCapaian>().call(
              params: {
                "no_register": newData.noRegistrasi,
                "tahun_ajaran": newData.tahunAjaran,
                "id_sekolah_kelas": int.parse(newData.idSekolahKelas ?? '0'),
                "id_bundling": newData.idBundlingAktif
              },
            );

            gNoRegistrasi = gUser!.noRegistrasi ?? '';

            emit(LoadedUser(user: newData, rawUser: responseLogin));

            if (event.noRegistrasiRefresh == null) {
              await gShowTopFlash(
                gNavigatorKey.currentContext!,
                'Selamat Datang ${newData.namaLengkap}',
                dialogType: DialogType.success,
              );
            }
          } else {
            throw DataException(message: 'Gagal login');
          }
        } on NoConnectionException catch (e) {
          if (event.noRegistrasiRefresh == null) {
            emit(AuthError(e.toString()));
          }
        } on DataException catch (e) {
          if (event.noRegistrasiRefresh == null) {
            String? imei = await gGetIdDevice() ?? '';
            emit(AuthErrorLogin(err: e.toString(), deviceId: imei));
          }
        } catch (e) {
          if (event.noRegistrasiRefresh == null) {
            emit(AuthError(e.toString()));
          }
        }
      }

      if (event is AuthGetCurrentUser) {
        try {
          // Get ServerTime Offset setiap membuka aplikasi
          await gSetServerTimeOffset();

          UserModel? currentUser = await KreasiSharedPref().getUser();
          String? nomorReg = KreasiSharedPref().getNomorReg();
          String? noregOrtu = KreasiSharedPref().getNoregOrtu() ?? '';

          if (currentUser?.namaLengkap == null || nomorReg?.isEmpty == true) {
            emit(AuthCurrentUserError());
            return;
          }

          String? siapa = KreasiSharedPref().getSiapa();

          // final String? responseImei = await apiService.fetchImei(
          //   noRegistrasi: currentUser.noRegistrasi,
          //   siapa: currentUser.siapa,
          // );

          // String? localImei = await gGetIdDevice();

          // if (localImei != null && responseImei != localImei) {
          //   await KreasiSharedPref().logout();
          //   currentUser = null;
          //   emit(AuthCurrentUserError());
          //   return;
          // }

          gUser = currentUser;

          String token = KreasiSharedPref().getTokenJWT() ?? '';
          DioOptionHelper().setDioOption = token;

          if ((event.isSplashScreen == true || event.isRefresh == true) &&
              siapa == 'ORTU') {
            String noregAnak = KreasiSharedPref().getNoregAnak() ?? '';
            int idBundlingAktif = KreasiSharedPref().getIdBundlingAktif() ?? 0;
            String? deviceId = await gGetIdDevice() ?? '';
            List<Map<String, dynamic>> daftarBundling =
                KreasiSharedPref().getDaftarBundling() ?? [];
            List<Map<String, dynamic>> daftarAnak =
                KreasiSharedPref().getDaftarAnak() ?? [];
            List<int> listIdProduk = KreasiSharedPref().getListIdProduk() ?? [];
            List<Map<String, dynamic>> daftarProduk =
                KreasiSharedPref().getDaftarProduk() ?? [];
            String nomorHpOrtu = KreasiSharedPref().getNomorHpOrtu() ?? '';
            add(
              AuthLoginOrtu(
                noregOrtu: noregOrtu,
                noregAnak: noregAnak,
                idBundlingAktif: idBundlingAktif,
                deviceId: deviceId,
                daftarBundling: daftarBundling,
                daftarAnak: daftarAnak,
                listIdProduk: listIdProduk,
                daftarProduk: daftarProduk,
                nomorHpOrtu: nomorHpOrtu,
                // listAnak: listAnak,
              ),
            );
          } else {
            await Future.delayed(const Duration(milliseconds: 500));

            emit(LoadedUser(user: currentUser));
          }
        } on NoConnectionException catch (e) {
          if (kDebugMode) {
            logger.log('NoConnectionException-CheckIsLogin: $e');
          }
          emit(AuthError(e.toString()));
        } on DataException catch (e) {
          if (kDebugMode) {
            logger.log('Exception-CheckIsLogin: $e');
          }
          emit(AuthError(e.toString()));
        } catch (e) {
          if (kDebugMode) {
            logger.log('FatalException-CheckIsLogin: $e');
          }
          emit(AuthError(e.toString()));
        }
      }

      if (event is AuthLogout) {
        UserModel? currentUser = await KreasiSharedPref().getUser();
        try {
          String role = KreasiSharedPref().getSiapa() ?? '';
          bool isSuccessLogout = false;

          if (role.toLowerCase() == 'siswa') {
            String noregSiswa = KreasiSharedPref().getNomorReg() ?? '';
            final params = {"noreg": noregSiswa};
            isSuccessLogout = await locator<LogoutSiswaUseCase>().call(
              params: params,
            );
            //  await apiService.logout(noregSiswa);
          } else {
            String noregOrtu = KreasiSharedPref().getNoregOrtu() ?? '';
            final params = {"id_ortu": noregOrtu};
            isSuccessLogout =
                await locator<LogoutOrtuUseCase>().call(params: params);
            // isSuccessLogout = await apiService.logoutOrtu(noregOrtu);
          }

          if (!isSuccessLogout) {
            throw 'Gagal logout, Terjadi kesalahan. '
                'Coba lagi nanti';
          }

          KreasiSharedPref().logout();
          gUser = null;
          gTokenJwt = '';

          if (!HiveHelper.isBoxOpen<BookmarkMapel>(
              boxName: HiveHelper.kBookmarkMapelBox)) {
            await HiveHelper.openBox<BookmarkMapel>(
                boxName: HiveHelper.kBookmarkMapelBox);
          }
          if (!HiveHelper.isBoxOpen<KelompokUjian>(
              boxName: HiveHelper.kKelompokUjianPilihanBox)) {
            await HiveHelper.openBox<KelompokUjian>(
                boxName: HiveHelper.kKelompokUjianPilihanBox);
          }
          // if (!HiveHelper.isBoxOpen<KampusImpian>(
          //     boxName: HiveHelper.kKampusImpianBox)) {
          //   await HiveHelper.openBox<KampusImpian>(
          //       boxName: HiveHelper.kKampusImpianBox);
          // }
          // if (!HiveHelper.isBoxOpen<KampusImpian>(
          //     boxName: HiveHelper.kRiwayatKampusImpianBox)) {
          //   await HiveHelper.openBox<KampusImpian>(
          //       boxName: HiveHelper.kRiwayatKampusImpianBox);
          // }
          // await HiveHelper.clearKampusImpianBox();
          // await HiveHelper.clearRiwayatKampusImpian();
          await HiveHelper.clearBookmarkBox();
          await HiveHelper.clearKelompokUjianPilihanBox();
          // await HiveHelper.closeBox<BookmarkMapel>(
          //     boxName: HiveHelper.kBookmarkMapelBox);

          final bundleSoalBloc = BundelSoalBloc();
          bundleSoalBloc.clearBundleSoalState = isSuccessLogout;

          final tobkBloc = TOBKBloc();
          tobkBloc.clearTOBKState = isSuccessLogout;

          emit(const LoadedUser(user: null));
        } on NoConnectionException catch (_) {
          emit(LoadedUser(user: currentUser, isFailedLogout: true));
        } on DataException catch (_) {
          emit(LoadedUser(user: currentUser, isFailedLogout: true));
        } catch (e) {
          emit(LoadedUser(user: currentUser, isFailedLogout: true));
        }
      }

      if (event is AuthSetIdSekolahKelas) {
        emit(LoadedIdSekolahKelas(event.idSekolahKelas));
      }

      if (event is AuthSwitchBundle) {
        try {
          emit(AuthLoading());
          final params = {
            "noreg": event.noRegistrasi,
            "id_bundling": event.idBundling,
            "daftar_bundling":
                event.daftarBundle.map((bundle) => bundle.toJson()).toList(),
          };

          final res = await locator<ChangeBundlingUseCase>().call(
            params: params,
          );

          if (res['meta']["code"] == 200) {
            userModelTemp = responseLoginToUserModel(res);

            gTokenJwt = res['data']['tokenJWT'];

            DioOptionHelper().setDioOption = gTokenJwt;
            await KreasiSharedPref().setTokenJWT(gTokenJwt);

            String? refreshAccessToken = res['data']['refreshToken'];
            if (refreshAccessToken != null) {
              await KreasiSharedPref().setRefreshToken(refreshAccessToken);
            }

            final Map<String, dynamic> dataSekolahParams = {
              'id_sekolah': userModelTemp.idSekolah,
              'id_sekolah_kelas': userModelTemp.idSekolahKelas,
              'token': gTokenJwt,
            };
            final resDataSekolah = await locator<GetDataSekolahSiswa>().call(
              params: dataSekolahParams,
            );

            DataSekolahSiswa dataSekolahSiswa = DataSekolahSiswa.fromJson(
              resDataSekolah,
            );

            final siapa = KreasiSharedPref().getSiapa();

            final newData = userModelTemp.copyWith(
              namaSekolah: dataSekolahSiswa.namaSekolah,
              tingkat: dataSekolahSiswa.tingkatKelas,
              tingkatKelas: dataSekolahSiswa.tingkatKelas,
              namaSekolahKelas: dataSekolahSiswa.namaSekolahKelas,
              isBolehPTN: dataSekolahSiswa.isBolehPTN,
              siapa: siapa,
            );

            gUser = newData;
            await KreasiSharedPref().simpanDataLokal();

            locator<SetTargetCapaian>().call(
              params: {
                "no_register": newData.noRegistrasi,
                "tahun_ajaran": newData.tahunAjaran,
                "id_sekolah_kelas": int.parse(newData.idSekolahKelas ?? '0'),
                "id_bundling": newData.idBundlingAktif
              },
            );

            emit(LoadedUser(
              user: newData,
              isSuccessUpdate: true,
              updatedBundle: event.selectedBundle,
            ));
          }
        } catch (e) {
          emit(LoadedUser(user: await KreasiSharedPref().getUser()));
          gShowTopFlash(
            gNavigatorKey.currentContext!,
            'Terjadi kesalahan saat ganti bundling',
            dialogType: DialogType.error,
          );
        }
      }

      if (event is AuthLoginOrtu) {
        try {
          if (event.noRegistrasiRefresh == null) {
            emit(AuthLoading());
          }

          String? imei = (gAkunTesterOrtu.contains(event.nomorHpOrtu))
              ? gTesterImeiOrtu
              : await gGetIdDevice();
          String merekHp, versiOS;

          try {
            final deviceInfoPlugin = DeviceInfoPlugin();

            if (Platform.isIOS) {
              final iosDeviceInfo = await deviceInfoPlugin.iosInfo;

              merekHp =
                  '${iosDeviceInfo.model} ${iosDeviceInfo.utsname.machine}';
              versiOS = 'iOS ${iosDeviceInfo.systemVersion}';
            } else {
              final androidDeviceInfo = await deviceInfoPlugin.androidInfo;

              merekHp =
                  '${androidDeviceInfo.manufacturer} ${androidDeviceInfo.brand} ${androidDeviceInfo.model}';
              versiOS =
                  'Android ${androidDeviceInfo.version.release} SDK ${androidDeviceInfo.version.sdkInt}';
            }
          } catch (_) {
            merekHp = '-';
            versiOS = '-';
          }

          Map<String, dynamic> params = {
            "id_ortu": event.noregOrtu,
            "noreg": event.noregAnak,
            "id_bundling_aktif": event.idBundlingAktif,
            "id_dev": imei,
            "daftar_bundling": event.daftarBundling,
            "daftar_anak": event.daftarAnak,
            "list_id_produk": event.listIdProduk,
            "daftar_produk": event.daftarProduk,
            "merkHp": merekHp,
            "versiOS": versiOS,
          };

          final resLogin = await locator<LoginOrtuUseCase>().call(
            params: params,
          );

          if (resLogin['meta']['code'] == 200) {
            userModelTemp = responseLoginToUserModel(resLogin);
            String? idSekolahKelas;
            if (state is LoadedIdSekolahKelas) {
              idSekolahKelas = (state as LoadedIdSekolahKelas).idSekolahKelas;
            }
            final newData =
                userModelTemp.copyWith(idSekolahKelas: idSekolahKelas);

            gUser = newData;

            locator<SetTargetCapaian>().call(
              params: {
                "no_register": newData.noRegistrasi,
                "tahun_ajaran": newData.tahunAjaran,
                "id_sekolah_kelas": int.parse(newData.idSekolahKelas ?? '0'),
                "id_bundling": newData.idBundlingAktif
              },
            );

            gNoRegistrasi = gUser!.noRegistrasi ?? '';
            gTokenJwt = resLogin['data']['tokenJWT'];

            DioOptionHelper().setDioOption = gTokenJwt;
            await KreasiSharedPref().setTokenJWT(gTokenJwt);

            String? refreshAccessToken = resLogin['data']['refreshToken'];
            if (refreshAccessToken != null) {
              await KreasiSharedPref().setRefreshToken(refreshAccessToken);
            }

            await KreasiSharedPref().simpanDataLokal();
            await KreasiSharedPref().setNomorHpOrtu(event.nomorHpOrtu);
            await KreasiSharedPref().setNoregOrtu(event.noregOrtu);
            await KreasiSharedPref().setSiapa('ORTU');
            await KreasiSharedPref().setNoregAnak(event.noregAnak);
            await KreasiSharedPref().setIdBundlingAktif(event.idBundlingAktif);
            await KreasiSharedPref().setDaftarBundling(event.daftarBundling);
            await KreasiSharedPref().setDaftarAnak(event.daftarAnak);
            await KreasiSharedPref().setListIdProduk(event.listIdProduk);
            await KreasiSharedPref().setDaftarProduk(event.daftarProduk);

            emit(LoadedUser(user: newData, rawUser: resLogin));

            if (event.noRegistrasiRefresh == null) {
              await gShowTopFlash(
                gNavigatorKey.currentContext!,
                'Selamat Datang ${newData.namaLengkap}',
                dialogType: DialogType.success,
              );
            }
          }
        } on NoConnectionException catch (e) {
          if (event.noRegistrasiRefresh == null) {
            emit(AuthError(e.toString()));
          }
        } on DataException catch (e) {
          if (event.noRegistrasiRefresh == null) {
            String? imei = await gGetIdDevice() ?? '';
            emit(AuthErrorLogin(err: e.toString(), deviceId: imei));
          } else {
            await gShowTopFlash(
              gNavigatorKey.currentContext!,
              e.toString(),
              dialogType: DialogType.error,
            );
          }
        } catch (e) {
          if (event.noRegistrasiRefresh == null) {
            emit(AuthError(e.toString()));
          }
        }
      }

      if (event is AuthGetGedungKomarSiswa) {
        try {
          if (state is! LoadedUser) {
            throw DataException(
                message: 'Gagal mendapatkan Gedung Komar Siswa');
          }

          emit(AuthLoading());

          final res = await locator<GetGedungKomarSiswa>().call(
            params: {
              'id_gedung': event.userData?.idGedung,
              'id_komar': event.userData?.idKomar,
              'id_kota': event.userData?.idKota,
            },
          );

          if (res['meta']["code"] == 200) {
            DataGedungKomarSiswa dataGedungKomarSiswa =
                DataGedungKomarSiswa.fromJson(res);

            final resNamaKelas = await locator<GetNamaKelasSiswa>().call(
              params: {
                'id_kelas': event.userData?.idKelas,
              },
            );

            String? namaKelas;

            List<NamaKelasSiswa> listNamaKelasSiswa = resNamaKelas
                .map((kelas) => NamaKelasSiswa.fromJson(kelas))
                .toList();

            int selectedIndexKelas = listNamaKelasSiswa.indexWhere(
                (kelas) => kelas.idKelas == event.userData?.idKelas);

            if (selectedIndexKelas < 0) {
              namaKelas = event.userData?.namaSekolahKelas;
            } else {
              namaKelas = listNamaKelasSiswa[selectedIndexKelas].namaKelas;
            }

            final user = event.userData?.copyWith(
              namaKelas: namaKelas,
              namaGedung: dataGedungKomarSiswa.namaGedung,
              namaKota: dataGedungKomarSiswa.namaKota,
            );

            gUser = user;

            await KreasiSharedPref().simpanDataLokal();

            emit(LoadedUser(user: user));
          } else {
            throw DataException(
                message: 'Gagal mendapatkan Gedung Komar Siswa');
          }
        } on DataException catch (e) {
          if (!event.isRefresh) {
            emit(AuthError(e.toString()));
          }
        } catch (e) {
          if (!event.isRefresh) {
            emit(AuthError(gPesanError));
          }
        }
      }

      /// [AuthRefreshProfileSiswa] untuk refresh produk aktif siswa
      if (event is AuthRefreshProfileSiswa) {
        try {
          await gSetServerTimeOffset();

          emit(AuthLoading());

          String? nomorReg = KreasiSharedPref().getNomorReg();
          final Map<String, dynamic> detailParams = {}
            ..['noreg'] = nomorReg
            ..['token'] = gTokenJwt;

          final res = await locator<GetDetailSiswa>().call(
            params: detailParams,
          );

          if (res['meta']['code'] != 200) throw 'Gagal refresh produk';

          int idBundlingAktif = res['data']['id_bundling_aktif'];

          List<Map<String, dynamic>> resDaftarProduk =
              res['data']['daftar_produk'].cast<Map<String, dynamic>>();

          List<Map<String, dynamic>> resDaftarBundling =
              res['data']['daftar_bundling'].cast<Map<String, dynamic>>();

          List<ProdukDibeli> daftarProdukDibeli = resDaftarProduk
              .map<ProdukDibeli>(
                  (produkJson) => ProdukDibeli.fromJson(produkJson))
              .toList();

          List<Bundling> daftarBundling = resDaftarBundling
              .map<Bundling>((bundle) => Bundling.fromJson(bundle))
              .toList();

          int indexBundleAktif = daftarBundling
              .indexWhere((element) => element.idBundling == idBundlingAktif);

          String? namaBundlingAktif = (indexBundleAktif != -1)
              ? daftarBundling[indexBundleAktif].namaBundling
              : 'N/a';

          daftarProdukDibeli
              .sort((a, b) => a.idJenisProduk.compareTo(b.idJenisProduk));

          daftarProdukDibeli.removeWhere((element) {
            final now = DateTime.now().serverTimeFromOffset;
            return now.isAfter(element.tanggalKedaluwarsa ?? now);
          });

          List<int> listIdProduk = daftarProdukDibeli
              .map((produk) => int.parse(produk.idKomponenProduk))
              .toList();

          final currentDataUser = await KreasiSharedPref().getUser();
          final user = currentDataUser?.copyWith(
            listIdProduk: listIdProduk,
            namaBundlingAktif: namaBundlingAktif,
            daftarBundling: daftarBundling,
          );

          gUser = user;
          gTokenJwt = res['data']['tokenJWT'];

          String? refreshAccessToken = res['data']['refreshToken'];
          if (refreshAccessToken != null) {
            await KreasiSharedPref().setRefreshToken(refreshAccessToken);
          }
          await KreasiSharedPref().simpanDataLokal();

          emit(LoadedUser(user: user));
        } catch (e) {
          UserModel? user = await KreasiSharedPref().getUser();
          emit(LoadedUser(user: user));
        }
      }
    });
  }
}
