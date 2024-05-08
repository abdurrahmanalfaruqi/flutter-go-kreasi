import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../entity/menu.dart';

/// Kumpulan menu dan id jenis produk Go Expert.<br><br>
/// Untuk Permission saat ini tidak digunakan sama sekali,
/// karena pengecekan permission sudah dari produk yang dibeli.
/// Bisa di hapus nanti jika memang tidak di perlukan.
class MenuProvider {
  static const Menu menuTOBK = Menu(
      idJenis: 25,
      label: 'TryOut Berbasis Komputer',
      namaJenisProduk: 'e-TOBK');

  static final _baseUrlImage = dotenv.env["BASE_URL_IMAGE"] ?? '';

  /// [listMenuBelajar] merupakan List of assets menu belajar icon.
  static List<Menu> listMenuBelajar = [
    Menu(
        idJenis: 0,
        label: 'Profiling',
        namaJenisProduk: 'profiling',
        iconPath: '$_baseUrlImage/arsip-mobile/icon/ic_profiling.webp'),
    Menu(
        idJenis: 0,
        label: 'Teori',
        namaJenisProduk: 'teori',
        iconPath: '$_baseUrlImage/arsip-mobile/icon/ic_buku_teori.webp'),
    Menu(
        idJenis: 0,
        label: 'Jadwal',
        namaJenisProduk: 'jadwal',
        iconPath: '$_baseUrlImage/arsip-mobile/icon/ic_jadwal_video.webp'),
    Menu(
        idJenis: 0,
        label: 'Rencana',
        namaJenisProduk: 'rencana',
        iconPath: '$_baseUrlImage/arsip-mobile/icon/ic_rencana_belajar.webp'),
  ];

  /// [listMenuBerlatih] merupakan List of assets menu berlatih icon.
  static List<Menu> listMenuBerlatih = [
    Menu(
        idJenis: 0,
        label: 'Soal',
        namaJenisProduk: 'soal',
        iconPath: '$_baseUrlImage/arsip-mobile/icon/ic_buku_soal.webp'),
    Menu(
        idJenis: 0,
        label: 'Laporan',
        namaJenisProduk: 'laporan',
        iconPath: '$_baseUrlImage/arsip-mobile/icon/ic_laporan.webp'),
  ];

  /// [listMenuBertanding] merupakan List of assets menu bertanding icon.
  static List<Menu> listMenuBertanding = [
    Menu(
        idJenis: 25,
        label: 'TOBK',
        namaJenisProduk: 'e-TOBK',
        iconPath: '$_baseUrlImage/arsip-mobile/icon/ic_tobk.webp'),
    Menu(
        idJenis: 0,
        label: 'SNBT',
        namaJenisProduk: 'Seleksi Nasional Berbasis Tes',
        iconPath: '$_baseUrlImage/arsip-mobile/icon/ic_snbt.png'),
  ];

  // Jenis Produk Buku Rumus - Singkat
  // Ringkas & Lengkap masuk di dalam menu Teori.
  // Jenis Produk Buku Teori - Lengkap
  // Jenis Produk Teori Intensif - Ringkas
  static const List<Menu> listMenuBukuTeori = [
    Menu(idJenis: 59, label: 'Teori', namaJenisProduk: 'e-Teori'),
    Menu(idJenis: 46, label: 'Rumus', namaJenisProduk: 'e-Rumus'),
    // Menu(idJenis: 70, label: 'Penghubung',namaJenisProduk: 'e-Buku Penghubung', permission: ["SISWA", "TAMU"]),
  ];

  static const Menu emptyMenuBukuSoal = Menu(
    idJenis: -1,
    label: 'Tidak Ada',
    namaJenisProduk: 'empty',
  );

  static const List<Menu> listMenuBukuSoal = [
    Menu(idJenis: 0, label: 'Buku Sakti', namaJenisProduk: 'sakti'),
    Menu(
        idJenis: 77,
        label: 'Paket Intensif',
        namaJenisProduk: 'e-Paket Intensif'),
    Menu(
        idJenis: 78,
        label: 'Soal Koding',
        namaJenisProduk: 'e-Paket Soal Koding'),
    Menu(
        idJenis: 79,
        label: 'Pend. Materi',
        namaJenisProduk: 'e-Pendalaman Materi'),
    Menu(idJenis: 82, label: 'Soal Referensi', namaJenisProduk: 'e-SoRef'),
    Menu(idJenis: 80, label: 'Racing Soal', namaJenisProduk: 'e-Racing'),
    Menu(idJenis: 16, label: 'Kuis', namaJenisProduk: 'e-Kuis'),
  ];

  static const List<Menu> listMenuBukuSakti = [
    Menu(
        idJenis: 76,
        label: 'Latihan Extra',
        namaJenisProduk: 'e-Latihan Extra'),
    Menu(
        idJenis: 71,
        label: 'Empati Mandiri',
        namaJenisProduk: 'e-Empati Mandiri'),
    Menu(
      idJenis: 72,
      label: 'Empati Wajib',
      namaJenisProduk: 'e-Empati Wajib',
    ),
  ];

  static const List<Menu> listMenuProfiling = [
    Menu(idJenis: 12, label: 'GOA', namaJenisProduk: 'e-GOA'),
    Menu(idJenis: 65, label: 'VAK', namaJenisProduk: 'e-VAK'),
  ];

  static const List<Menu> listMenuVideo = [
    Menu(idJenis: 57, label: 'Ekstra', namaJenisProduk: 'e-Video Ekstra'),
    Menu(idJenis: 87, label: 'Soal', namaJenisProduk: 'e-Video Soal'),
    Menu(idJenis: 88, label: 'Teori', namaJenisProduk: 'e-Video Teori'),
  ];

  static const List<Menu> listMenuLaporan = [
    Menu(idJenis: 25, label: 'TOBK', namaJenisProduk: 'e-TOBK'),
    // Menu(idJenis: 12, label: 'GOA', namaJenisProduk: 'e-GOA'),
    Menu(idJenis: 65, label: 'VAK', namaJenisProduk: 'e-VAK'),
    Menu(idJenis: 16, label: 'Kuis', namaJenisProduk: 'e-Kuis'),
    Menu(idJenis: 0, label: 'Presensi', namaJenisProduk: 'presensi'),
    // Menu(idJenis: 0, label: 'Juara Sakti', namaJenisProduk: 'sakti'),
    // Menu(idJenis: 80, label: 'Juara Racing', namaJenisProduk: 'e-Racing'),
    // Menu(idJenis: 0, label: 'Pembayaran', namaJenisProduk: 'pembayaran'),
    Menu(idJenis: 0, label: 'Aktivitas', namaJenisProduk: 'aktivitas'),
  ];

  static const List<Menu> listMenuSNBT = [
    Menu(idJenis: 0, label: 'PTN-Clopedia', namaJenisProduk: ''),
    Menu(idJenis: 0, label: 'Simulasi', namaJenisProduk: ''),
  ];

  static const List<Menu> listMenuJadwal = [
    // di hide sementara menunggu di kembangkan
    Menu(idJenis: 0, label: 'Jadwal', namaJenisProduk: ''),
    Menu(idJenis: 88, label: 'Video', namaJenisProduk: 'e-Video Teori'),
    Menu(idJenis: 0, label: 'TST Super', namaJenisProduk: ''),
  ];

  static const List<Menu> listMenuJadwalOrtu = [
    Menu(idJenis: 0, label: 'Jadwal', namaJenisProduk: ''),
    Menu(idJenis: 0, label: 'TST Super', namaJenisProduk: '')
  ];

  static const List<Menu> listMenuLeaderboardRacing = [
    Menu(idJenis: 0, label: 'Nasional', namaJenisProduk: ''),
    Menu(idJenis: 0, label: 'Kota', namaJenisProduk: ''),
    Menu(idJenis: 0, label: 'Gedung', namaJenisProduk: ''),
  ];

  static const List<Menu> listMenuFriendsProfile = [
    Menu(idJenis: 0, label: 'Feeds', namaJenisProduk: ''),
    Menu(idJenis: 0, label: 'Friends', namaJenisProduk: ''),
  ];

  static const List<Menu> listMenuLeaderBoardRacing = [
    Menu(idJenis: 0, label: 'Gedung', namaJenisProduk: ''),
    Menu(idJenis: 0, label: 'Kota', namaJenisProduk: ''),
    Menu(idJenis: 0, label: 'Nasional', namaJenisProduk: ''),
  ];
}
