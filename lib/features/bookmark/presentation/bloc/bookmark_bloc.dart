import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/core/helper/hive_helper.dart';
import 'package:gokreasi_new/core/util/data_formatter.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import 'package:gokreasi_new/features/bookmark/domain/entity/bookmark.dart';
import 'package:gokreasi_new/features/bookmark/domain/usecase/bookmark_usecase.dart';
import 'package:gokreasi_new/features/bookmark/service/api/bookmark_service_api.dart';
import 'package:gokreasi_new/features/soal/entity/soal.dart';

part 'bookmark_event.dart';
part 'bookmark_state.dart';

enum Filternilai { harian, mingguan, bulanan }

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  final BookmarkServiceAPI apiService;
  List<BookmarkMapel> listBookmark = [];
  BookmarkBloc(this.apiService) : super(BookmarkState()) {
    on<LoadBookmark>((event, emit) async {
      try {
        emit(BookmarkLoading());

        if (event.isSiswa) {
          if (event.isrefresh || listBookmark.isEmpty) {
            if (!HiveHelper.isBoxOpen<BookmarkMapel>(
                boxName: HiveHelper.kBookmarkMapelBox)) {
              await HiveHelper.openBox<BookmarkMapel>(
                  boxName: HiveHelper.kBookmarkMapelBox);
            }

            await HiveHelper.clearBookmarkBox();
            final params = {'noRegistrasi': event.noRegistrasi};
            final responseData = await locator<FetchBookMarkUseCase>().call(
              params: params,
            );
            if (responseData.isNotEmpty) {
              for (Map<String, dynamic> bookmark in responseData) {
                if (!bookmark.containsKey('iconMapel')) {
                  final iconMapel = bookmark['iconMapel'];

                  bookmark.putIfAbsent('iconMapel',
                      () => (iconMapel.isEmpty) ? null : iconMapel[0].key);
                }

                BookmarkMapel bookmarkMapel = BookmarkMapel.fromJson(bookmark);

                await HiveHelper.saveBookmarkMapel(
                    keyBookmarkMapel: bookmarkMapel.idKelompokUjian,
                    dataBookmark: bookmarkMapel);
              }
            }
            listBookmark = await HiveHelper.getDaftarBookmarkMapel();
          }

          emit(BookmarkDataLoaded(listBookmark: listBookmark));
        } else {
          emit(BookmarkDataLoaded(listBookmark: const []));
        }
      } catch (e) {
        emit(BookmarkError(e.toString()));
      }
    });

    on<ReloadBookmarkFromHive>((event, emit) async {
      emit(BookmarkLoading());
      if (!HiveHelper.isBoxOpen<BookmarkMapel>(
          boxName: HiveHelper.kBookmarkMapelBox)) {
        await HiveHelper.openBox<BookmarkMapel>(
            boxName: HiveHelper.kBookmarkMapelBox);
      }
      listBookmark = await HiveHelper.getDaftarBookmarkMapel();
      emit(BookmarkDataLoaded(listBookmark: listBookmark));
    });

    on<RemoveBookmarkMapel>((event, emit) async {
      try {
        if (event.role) {
          final params = {
            "no_register": event.noRegistrasi,
            "id_kelompok_ujian": int.parse(event.idKelompokUjian),
          };
          final response = await locator<DeleteBookMarkMapelUseCase>().call(
            params: params,
          );
          if (response) {
            bool isBerhasilHapus = await HiveHelper.removeBookmarkMapel(
                keyBookmarkMapel: event.idKelompokUjian);
            if (isBerhasilHapus) {
              listBookmark = await HiveHelper.getDaftarBookmarkMapel();
              add(LoadBookmark(
                  isrefresh: true,
                  noRegistrasi: event.noRegistrasi,
                  isSiswa: event.role));
            }
          }
        }
      } catch (e) {
        emit(BookmarkError(e.toString()));
      }
    });

    on<DeleteBookmark>((event, emit) async {
      try {
        emit(BookmarkLoading());
        if (event.isBoleh) {
          final params = {
            "no_register": event.noRegister,
            "id_kelompok_ujian": int.parse(event.idKelompokUjian),
            "id_soal": int.parse(event.bookmarkSoal.idSoal),
            "nomor_soal": event.bookmarkSoal.nomorSoal,
            "kode_bab": event.bookmarkSoal.kodeBab ?? '',
            "kode_paket": event.bookmarkSoal.kodePaket,
            "nomor_soal_siswa": event.bookmarkSoal.nomorSoalSiswa,
          };

          bool response = await locator<DeleteBookMarkUseCase>().call(
            params: params,
          );

          if (response) {
            bool isBerhasilHapus = await HiveHelper.removeBookmarkSoal(
                keyBookmarkMapel: event.bookmarkSoal.toString(),
                bookmarkSoal: event.bookmarkSoal);
            if (isBerhasilHapus) {
              BookmarkMapel? bookmarkMapelHive =
                  await HiveHelper.getBookmarkMapel(
                      keyBookmarkMapel: event.idKelompokUjian);

              // Jika pada bookmark mapel tidak terdapat bookmark soal, maka hapus mapel tersebut.
              if (bookmarkMapelHive != null &&
                  bookmarkMapelHive.listBookmark.isEmpty) {
                await HiveHelper.removeBookmarkMapel(
                    keyBookmarkMapel: event.idKelompokUjian);
              }
            }
            listBookmark = await HiveHelper.getDaftarBookmarkMapel();
            add(LoadBookmark(
                isrefresh: true,
                noRegistrasi: event.noRegister,
                isSiswa: event.isBoleh));
          } else {
            emit(BookmarkError("gagal"));
          }
        }
      } catch (e) {
        emit(BookmarkError("gagal"));
      }
    });

    on<AddBookmark>((event, emit) async {
      try {
        emit(BookmarkLoading());
        if (event.role) {
          final params = {
            "no_register": event.noRegistrasi,
            "id_kelompok_ujian": int.parse(event.soal.idKelompokUjian),
            "id_soal": int.parse(event.soal.idSoal),
            "nomor_soal": event.soal.nomorSoal,
            "kode_bab": event.kodeBab == '' ? null : event.kodeBab,
            "nama_bab": event.namaBab,
            "kode_tob": int.parse(event.kodeTob),
            "id_bundel": int.parse(event.soal.idBundle ?? '0'),
            "kode_paket": event.kodePaket,
            "id_jenis_produk": event.idJenisProduk,
            "nama_jenis_produk": event.namaJenisProduk,
            "nomor_soal_siswa": event.soal.nomorSoalSiswa,
            "last_update": DataFormatter.formatLastUpdate(),
            "tanggal_kedaluwarsa": event.tanggalKedaluwarsa == ''
                ? null
                : event.tanggalKedaluwarsa,
          };
          bool response = await locator<AddBookMarkUseCase>().call(
            params: params,
          );

          if (response) {
            String keyBookmarkMapel = event.soal.idKelompokUjian;
            BookmarkSoal bookmarkSoal = BookmarkSoal(
              idSoal: event.soal.idSoal,
              nomorSoal: event.soal.nomorSoal,
              nomorSoalSiswa: event.soal.nomorSoalSiswa,
              kodeTOB: event.kodeTob,
              kodePaket: event.kodePaket,
              idBundel: event.idBundel,
              kodeBab: event.kodeBab,
              namaBab: event.namaBab,
              idJenisProduk: event.idJenisProduk,
              namaJenisProduk: event.namaJenisProduk,
              tanggalKedaluwarsa: event.tanggalKedaluwarsa,
              isPaket: event.isPaket,
              isSimpan: event.isSimpan,
              lastUpdate: DataFormatter.formatLastUpdate(),
            );
            BookmarkMapel? bookmarkMapel = await HiveHelper.getBookmarkMapel(
                keyBookmarkMapel: keyBookmarkMapel);

            if (bookmarkMapel == null) {
              // Jika bookmark mapel null, maka cek terlebih dahulu apakah
              // list bookmark mapel masih belum melebihi batas?
              List<BookmarkMapel> daftarBookmarkMapel =
                  await HiveHelper.getDaftarBookmarkMapel();

              // Jika daftar mapel sudah mencapai 30,
              // maka tidak boleh menambahkan mapel lainnya.
              if (daftarBookmarkMapel.isNotEmpty &&
                  daftarBookmarkMapel.length > 29) {
                // ignore: use_build_context_synchronously
                gShowBottomDialogInfo(gNavigatorKey.currentState!.context,
                    title: 'Mata Pelajaran yang disimpan sudah mencapai batas',
                    message:
                        'Hai Sobat, kamu hanya boleh menyimpan bookmark sebanyak 30 jenis mata pelajaran. Bookmark kamu sudah diisi dengan ${daftarBookmarkMapel.length} mata pelajaran Sobat. Hapus salah satunya jika kamu mau menambahkan yang baru!');
              }

              BookmarkMapel bookmarkMapel = BookmarkMapel(
                  idKelompokUjian: event.soal.idKelompokUjian,
                  namaKelompokUjian: event.soal.namaKelompokUjian,
                  listBookmark: [bookmarkSoal],
                  initial: event.soal.initial);
              await HiveHelper.saveBookmarkMapel(
                  keyBookmarkMapel: keyBookmarkMapel,
                  dataBookmark: bookmarkMapel);
            } else {
              if (bookmarkMapel.listBookmark.length > 24) {
                // ignore: use_build_context_synchronously
                gShowBottomDialogInfo(gNavigatorKey.currentState!.context,
                    title:
                        'Soal pada ${bookmarkMapel.namaKelompokUjian} yang disimpan sudah mencapai batas',
                    message:
                        'Hai Sobat, kamu hanya boleh menyimpan bookmark sebanyak 25 soal di setiap mata pelajaran. Bookmark kamu sudah diisi dengan ${bookmarkMapel.listBookmark.length} soal Sobat. Hapus salah satunya jika kamu mau menambahkan yang baru!');
              } else {
                bookmarkMapel.listBookmark.add(bookmarkSoal);
                bookmarkMapel.listBookmark.sort((a, b) => a.compareTo(b));
              }
              HiveHelper.listenableBookmarkMapel();

              await HiveHelper.saveBookmarkMapel(
                  keyBookmarkMapel: keyBookmarkMapel,
                  dataBookmark: bookmarkMapel);
            }
            listBookmark = await HiveHelper.getDaftarBookmarkMapel();
            add(LoadBookmark(
                isrefresh: true,
                noRegistrasi: event.noRegistrasi,
                isSiswa: event.role));
          } else {
            emit(BookmarkError("gagal"));
          }
        }
      } catch (e) {
        emit(BookmarkError("gagal"));
      }
    });
  }
}
