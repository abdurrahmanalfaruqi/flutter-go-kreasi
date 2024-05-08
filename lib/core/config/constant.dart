import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:base32/base32.dart';

import 'extensions.dart';
import '../../features/profile/data/model/about_model.dart';

class Constant {
  /// Base API Section
  /// [kKreasiBaseHost] merupakan host url dari API Go Expert.
  /// [kKreasiBasePath] merupakan base path dari API Go Expert V3.
  /// Adapun opsi key pada dot ENV sebagai berikut:
  /// 1) http://kreasi.ganeshaoperation.com/apigokreasiios/api/v3
  /// --- ['BASE_URL_KREASI'] = kreasi.ganeshaoperation.com
  /// --- ['BASE_PATH_V3'] = /apigokreasiios/api/v3
  ///
  /// 2) http://kreasi.ganeshaoperation.com/apigokreasiios/api/
  /// --- ['BASE_URL_KREASI'] = kreasi.ganeshaoperation.com
  /// --- ['BASE_PATH_21'] = /apigokreasiios/api
  ///
  /// 3) http://kreasi.ganeshaoperation.com:8081/apigokreasiios/api/
  /// --- ['BASE_URL_KREASI_8081'] = kreasi.ganeshaoperation.com:8081
  /// --- ['BASE_PATH_8081'] = /apigokreasiios/api/kreasi/v4
  /// Jika ingin mengubah sumber Host API tinggal ikuti list di atas.
  /// Jika ingin menambahkan opsi, tambahkan pada file .env project ini.
  static final String kKreasiBaseHost = dotenv.env['BASE_URL_KREASI_8081']!;
  static final String kKreasiBasePath = '${dotenv.env['BASE_PATH_8081']}';

  /// [kCarouselBaseHost] + [kCarouselBasePath] merupakan API untuk get Carousal Image Go Expert.
  /// http://go-learn.web.id/KreasiNew/slider/data.php
  /// [kCarouselBaseHost] = go-learn.web.id
  /// [kCarouselBasePath] = /KreasiNew/slider/data.php
  static final String kCarouselBaseHost = dotenv.env['CAROUSEL_BASE_URL']!;

  /// [kCarouselBasePath] = /KreasiNew/slider/data.php
  static final String kCarouselBasePath = dotenv.env['CAROUSEL_BASE_PATH']!;

  static final String kVideoCredential = dotenv.env['CREDENTIAL_AUTH']!;
  static final String kStreamTokenBaseHost =
      dotenv.env['STREAM_TOKEN_BASE_URL']!;
  static final String kStreamTokenBasePath =
      dotenv.env['STREAM_TOKEN_BASE_PATH']!;

  // Assets Path
  static const String baseUrl = 'https://wild-tan-pangolin-cap.cyclic.cloud';
  static const String kImageAssetsPath = 'assets/images';
  static const String kImageLocalAssetsPath = 'assets/img';

  // Routes Section
  static const String kRouteUpdateScreen = '/update';
  static const String kRouteMainScreen = '/main';
  static const String kRouteNotifikasi = '/notifikasi';
  static const String kRouteAuthScreen = '/auth';
  static const String kRouteOTPScreen = '/otp';
  static const String kRouteStoryBoardScreen = '/story-board';
  static const String kRouteProfileScreen = '/profile';
  static const String kRouteEditProfileScreen = '/profile/edit';
  static const String kRouteAboutScreen = '/about';
  static const String kRouteTataTertibScreen = '/tata-tertib';
  // static const String kRouteTermsandConditions = '/terms-conditions';
  // static const String kRoutePrivacyandPolicy = '/privacy-policy';

  static const String kRouteBantuanScreen = '/pusat-bantuan';
  static const String kRouteBantuanWebViewScreen = '/bantuan-web-view';
  static const String kRouteGoNews = '/go-news';
  static const String kRouteDetailGoNews = '/go-news/detail';
  static const String kRouteJuaraBukuSaktiScreen = '/juara/buku-sakti';
  static const String kRouteBookmark = '/bookmark';
  static const String kRouteBukuSoalScreen = '/buku-soal';
  static const String kRouteBabBukuSoalScreen = '/buku-soal/bab';
  static const String kRouteProfilingScreen = '/profiling';
  static const String kRouteTobkScreen = '/tobk';
  static const String kRouteSoalBasicScreen = '/soal-screen/basic';
  static const String kRouteSoalTimerScreen = '/soal-screen/timer';
  static const String kRouteVideoSolusi = '/video/solusi';
  static const String kRoutePaketTOScreen = '/paket-to';
  static const String kRouteBukuTeoriScreen = '/buku-teori';
  static const String kRouteBabTeoriScreen = '/buku-teori/bab';
  static const String kRouteBukuTeoriContent = '/buku-teori/content';
  static const String kRouteRencanaBelajar = '/rencana/calendar';
  static const String kRouteRencanaEditor = '/rencana/editor';
  static const String kRouteRencanaPicker = '/rencana/picker';
  static const String kRouteImpian = '/impian';
  static const String kRouteImpianPicker = '/impian/picker';
  static const String kRouteReportProblem = '/report-problem';

  /// SNBT (Seleksi Nasional Berbasis Tes), pengganti SBMPTN.
  static const String kRouteSNBT = '/snbt';
  static const String kRouteSimulasi = '/simulasi';
  static const String kRouteSimulasiNilai = '/simulasi/nilai';
  static const String kRouteSimulasiSimulasi = '/simulasi/simulasi';
  static const String kRouteSimulasiPilihan = '/simulasi/pilihan';
  static const String kRouteSimulasiPilihanForm = '/simulasi/pilihan/form';
  static const String kRouteJadwal = '/jadwal';
  static const String kRouteVideoPlayer = '/video-player';
  static const String kRouteVideoJadwalBab = '/video-jadwal/bab';
  static const String kRouteFeedback = '/feedback';
  static const String kRouteLaporan = '/laporan';
  static const String kRouteLaporanJawaban = '/laporan/jawaban';
  static const String kRouteLaporanVak = '/laporan/vak';
  static const String kRouteLaporanQuiz = '/laporan/quiz';
  static const String kRouteLaporanPresensi = '/laporan/presensi';
  static const String kRouteLaporanAktivitas = '/laporan/aktivitas';
  static const String kRouteLaporanTryOut = '/laporan/tryout';
  static const String kRouteLaporanTryOutNilai = '/laporan/tryout/nilai';
  static const String kRouteLaporanTryOutViewer = '/laporan/tryout/viewer';
  static const String kRouteLaporanTryOutShare = '/laporan/tryout/share';
  static const String kRouteFeedComment = '/feed-comment';
  static const String kRouteLeaderBoardRacing = '/leaderboard-racing';
  static const String kRouteFriendsProfile = '/friends/profile';
  static const String kRouteSosial = '/sosial';

  static final String secretOTP =
      base32.encodeHexString(dotenv.env['SECRET_OTP']!);

  // Story Board
  static final Map<String, Map<String, dynamic>> kStoryBoard = {
    'Profiling': {
      'imgUrl': 'ilustrasi_profiling.png'.illustration,
      'title': 'Profiling',
      'subTitle':
          'GOA (GO Assessment) dan\nVAK (Visual, Auditori, dan Kinestetik)',
      'storyText':
          'Dengan profiling, Sobat bisa tau kelemahan kamu ada di mata pelajaran mana. Sobat juga bisa tau gaya belajar seperti apasih yang cocok untuk Sobat. Jadi proses belajar Sobat bisa lebih maksimal lagi.',
    },
    'Jadwal': {
      'imgUrl': 'ilustrasi_jadwal_belajar.png'.illustration,
      'title': 'Jadwal Belajar',
      'subTitle':
          'Daftar jadwal KBM dan TST Sobat ada di sini, jangan sampai terlewat ya!',
      'storyText':
          'Dengan TST, kamu bisa janjian dengan pengajar favorit kamu untuk mendalami materi yang belum dipahami Sobat! Oyaa, jangan lupa berikan masukan melalui Feedback Pengajaran supaya pelayanan yang SobatGO terima jadi semakin memuaskan!',
    },
    'Rencana': {
      'imgUrl': 'ilustrasi_rencana_belajar.png'.illustration,
      'title': 'Rencana Belajar',
      'subTitle':
          'Rencana belajar Sobat untuk persiapan maksimal saat bertanding!',
      'storyText':
          'SobatGO bisa membuat jadwal rencana belajar mulai dari waktu belajar hingga materi apa yang akan SobatGO pelajari, nanti GO Expert akan bantu ingatkan waktu-waktu belajar SobatGO.',
    },
    'Laporan': {
      'imgUrl': 'ilustrasi_laporan_aktivitas.png'.illustration,
      'title': 'Laporan',
      'subTitle': 'Semua hasil belajar kamu bisa dilihat disini Sobat!',
      'storyText':
          'Segala jenis laporan akan ditampilkan dengan sederhana dan mudah dipahami. '
              'Kamu bisa cek mulai dari Laporan Presensi, Juara Racing, Pembayaran, hingga Log Aktivitas kamu loh Sobat.',
    },
    'SNBT': {
      'imgUrl': 'ilustrasi_sbmptn.png'.illustration,
      'title': 'SNBT',
      'subTitle': 'Seleksi Nasional Berbasis Tes',
      'storyText':
          'Di sini kamu bisa memilih jurusan-PTN yang kamu idamkan dan cek seberapa besar '
              'kemungkinan kamu lulus ke sana. Jadi kampus impian kamu bisa lebih terukur Sobat.',
    },
    'Impian': {
      'imgUrl': 'ilustrasi_kampus_impian.png'.illustration,
      'title': 'Kampus Impian',
      'subTitle': 'Yuk atur target kampus impian kamu!',
      'storyText':
          'Sobat bisa mengatur target kampus yang Sobat mau. Dan dengan PTN-Clopedia, Sobat bisa tau akan seperti apasih jurusan yang Sobat impikan itu? Jadi Sobat tidak perlu takut salah jurusan.',
    },
    'Bookmark': {
      'imgUrl': 'ilustrasi_bookmark.png'.illustration,
      'title': 'My Bookmark',
      'subTitle': 'Sobat pernah kesulitan saat ingin\nmenanyakan soal latihan?',
      'storyText':
          'Dengan fitur ini, Sobat bisa menyimpan soal yang sulit loh. Jadi Sobat tidak perlu khawatir akan lupa saat ada kesempatan bertanya kepada Pengajar.',
    },
    'Nilaimu': {
      'imgUrl': 'ilustrasi_nilaimu.png'.illustration,
      'title': 'Capaian dan Grafik',
      'subTitle': 'Yuk penuhi target dan lihat progres latihan kamu Sobat!',
      'storyText':
          'Sobat bisa melihat progres pengerjaan soal tiap bidang studi. Progress pengerjaan soal dihitung dari menu Buku Sakti yaitu Empati Wajib, Empati Mandiri, dan Latihan Ekstra.',
    },
    'Juara Buku Sakti': {
      'imgUrl': 'ilustrasi_leaderboard.png'.illustration,
      'title': 'Juara Buku Sakti',
      'subTitle': 'Kamu peringkat berapa sobat?',
      'storyText':
          'Sobat bisa melihat Ranking di tingkat Gedung, Kota, dan Nasional untuk lebih memotivasi kamu dalam belajar.',
    },
    'TOBK': {
      'imgUrl': 'ilustrasi_rencana_belajar.png'.illustration,
      'title': 'TOBK',
      'subTitle': 'Try Out Berbasis Komputer',
      'storyText': 'Yuk, ikuti Try Out Berbasis Komputer.',
    },
    'Teori': {
      'imgUrl': 'ilustrasi_rencana_belajar.png'.illustration,
      'title': 'Teori',
      'subTitle': 'Teaser Buku Teori',
      'storyText': 'Beli produk Buku Teori yuk sobat.',
    },
    'Soal': {
      'imgUrl': 'ilustrasi_laporan_aktivitas.png'.illustration,
      'title': 'Soal',
      'subTitle': 'Kumpulan Soal',
      'storyText': 'Coba soal di Ganesha Operation yuk sobat.',
    }
  };

  static const List<Map<String, String>> kDataSekolahKelas = [
    {'id': '1', 'kelas': '1 SD DASAR', 'tingkat': 'SD', 'tingkatKelas': '1'},
    {'id': '2', 'kelas': '2 SD DASAR', 'tingkat': 'SD', 'tingkatKelas': '2'},
    {'id': '3', 'kelas': '3 SD DASAR', 'tingkat': 'SD', 'tingkatKelas': '3'},
    {'id': '4', 'kelas': '4 SD DASAR', 'tingkat': 'SD', 'tingkatKelas': '4'},
    {'id': '5', 'kelas': '5 SD DASAR', 'tingkat': 'SD', 'tingkatKelas': '5'},
    {'id': '6', 'kelas': '6 SD DASAR', 'tingkat': 'SD', 'tingkatKelas': '6'},
    {'id': '7', 'kelas': '7 SMP UMUM', 'tingkat': 'SMP', 'tingkatKelas': '7'},
    {'id': '8', 'kelas': '8 SMP UMUM', 'tingkat': 'SMP', 'tingkatKelas': '8'},
    {'id': '9', 'kelas': '9 SMP UMUM', 'tingkat': 'SMP', 'tingkatKelas': '9'},
    {'id': '10', 'kelas': '10 SMA MIA', 'tingkat': 'SMA', 'tingkatKelas': '10'},
    {'id': '34', 'kelas': '11 SMA MIA', 'tingkat': 'SMA', 'tingkatKelas': '11'},
    {'id': '35', 'kelas': '12 SMA MIA', 'tingkat': 'SMA', 'tingkatKelas': '12'},
    {'id': '12', 'kelas': '11 SMA IPA', 'tingkat': 'SMA', 'tingkatKelas': '11'},
    {'id': '14', 'kelas': '12 SMA IPA', 'tingkat': 'SMA', 'tingkatKelas': '12'},
    {'id': '13', 'kelas': '11 SMA IPS', 'tingkat': 'SMA', 'tingkatKelas': '11'},
    {'id': '15', 'kelas': '12 SMA IPS', 'tingkat': 'SMA', 'tingkatKelas': '12'},
    {'id': '11', 'kelas': '10 SMA IIS', 'tingkat': 'SMA', 'tingkatKelas': '10'},
    {'id': '36', 'kelas': '11 SMA IIS', 'tingkat': 'SMA', 'tingkatKelas': '11'},
    {'id': '37', 'kelas': '12 SMA IIS', 'tingkat': 'SMA', 'tingkatKelas': '12'},
    {'id': '39', 'kelas': '12 SMA IPC', 'tingkat': 'SMA', 'tingkatKelas': '12'},
    {
      'id': '18',
      'kelas': '10 SMK AKUNTANSI',
      'tingkat': 'SMA',
      'tingkatKelas': '10'
    },
    {
      'id': '38',
      'kelas': '11 SMK AKUNTANSI',
      'tingkat': 'SMA',
      'tingkatKelas': '11'
    },
    {
      'id': '32',
      'kelas': '12 SMK AKUNTANSI',
      'tingkat': 'SMA',
      'tingkatKelas': '12'
    },
    {
      'id': '16',
      'kelas': '10 SMK TEKNOLOGI',
      'tingkat': 'SMA',
      'tingkatKelas': '10'
    },
    {
      'id': '19',
      'kelas': '11 SMK TEKNOLOGI',
      'tingkat': 'SMA',
      'tingkatKelas': '11'
    },
    {
      'id': '22',
      'kelas': '12 SMK TEKNOLOGI',
      'tingkat': 'SMA',
      'tingkatKelas': '12'
    },
    {
      'id': '17',
      'kelas': '10 SMK PARIWISATA',
      'tingkat': 'SMA',
      'tingkatKelas': '10'
    },
    {
      'id': '20',
      'kelas': '11 SMK PARIWISATA',
      'tingkat': 'SMA',
      'tingkatKelas': '11'
    },
    {
      'id': '23',
      'kelas': '12 SMK PARIWISATA',
      'tingkat': 'SMA',
      'tingkatKelas': '12'
    },
    {
      'id': '25',
      'kelas': '10 SMA UMUM',
      'tingkat': 'SMA',
      'tingkatKelas': '10'
    },
    {
      'id': '41',
      'kelas': '12 SMA UMUM',
      'tingkat': 'SMA',
      'tingkatKelas': '12'
    },
    {
      'id': '26',
      'kelas': '11 UMUM UMUM',
      'tingkat': 'SMA',
      'tingkatKelas': '11'
    },
    {
      'id': '27',
      'kelas': '12 UMUM UMUM',
      'tingkat': 'SMA',
      'tingkatKelas': '12'
    },
    {
      'id': '28',
      'kelas': '13 ALUMNI IPA',
      'tingkat': 'ALUMNI',
      'tingkatKelas': '13'
    },
    {
      'id': '29',
      'kelas': '13 ALUMNI IPS',
      'tingkat': 'ALUMNI',
      'tingkatKelas': '13'
    },
    {
      'id': '30',
      'kelas': '13 UMUM UMUM',
      'tingkat': 'Other',
      'tingkatKelas': '13'
    },
    {
      'id': '31',
      'kelas': '0 UMUM UMUM',
      'tingkat': 'Other',
      'tingkatKelas': '0'
    },
  ];

  static const String defaultAturan =
      '<html><body><div class="main"><h3>PERATURAN DAN TATA TERTIB SISWA GANESHA OPERATION TP 2023/2024</h3><ol><li>Siswa Ganesha Operation (GO) wajib hadir Kegiatan Belajar Mengajar (KBM) dan kegiatan GO lainnya selambat-lambatnya 10 (sepuluh) menit sebelum kegiatan dimulai. Siswa GO yang terlambat, dilarang masuk kelas kecuali mendapatkan izin tertulis dari Kepala Unit/<i>Customer Service </i>sesuai dengan peraturan GO setempat.</li><li>Siswa GO diwajibkan melakukan presensi sebagai bukti kehadiran selama mengikuti pembelajaran di GO. Presensi dilakukan setiap sesi jam belajar sesuai hari belajar menggunakan scan <i>Quick Response</i>(QR) Code ke Pengajar.</li><li>Siswa GO tidak diperbolehkan pindah kelas (mutasi) kecuali jika mendapat persetujuan dari Kepala Unit/Kepala Sekretariat GO setempat dan harus sesuai aturan yang berlaku.</li><li>Selama berada di lingkungan GO, Siswa GO diwajibkan selalu:<ol type="a"><li>Berpakaian rapi, sopan, tidak memakai sandal jepit.</li><li>Tidak membawa senjata tajam, dan/atau membawa Narkoba jenis apapun.</li><li>Menggunakan masker selama berada di lingkungan GO.</li><li>Tidak saling meminjamkan alat tulis, HP, dll.</li></ol></li><li>Siswa GO dilarang merokok di lingkungan Ganesha Operation.</li><li>Siswa GO boleh membawa alat komunikasi (<i>handphone, tablet, dan gadget</i>) selama proses KBM GO, alat komunikasi wajib dalam keadaan <i>silent mode</i>.</li><li>Siswa wajib men-<i>download</i> Go Expert untuk sarana pembelajaran secara online.</li><li>Siswa GO wajib mengikuti dan menaati seluruh peraturan GO termasuk jadwal belajar, jadwal Try Out, SiagaPTS, Siaga PAS, dan Siaga PAT/US.</li><li>Ganesha Operation (GO) berhak mempublikasikan kelulusan dan/atau prestasi siswa.</li></ol></br></br></div></body></html>';

  static const List<AboutModel> defaultAbout = [
    AboutModel(judul: 'Apa itu Aplikasi Go Expert?', deskripsi: [
      '   Aplikasi ini hanya dapat digunakan oleh siswa aktif Ganesha Operation di seluruh indonesia, tidak terbuka untuk pengguna di luar Ganesha Operation. Aplikasi yang bertujuan untuk membantu pengguna dalam mengontrol dan melaporkan prestasi siswa tersebut, salah satunya membantu untuk melihat jadwal kelas, video pembelajaran, buku soal, buku teori, hasil tryout, hasil quiz, hasil VAK, hasil presensi dan lain-lain. Aplikasi ini dibuat oleh Ganesha Operation (IT APP DEVELOPER) pada tahun 2018.'
    ], subData: []),
    AboutModel(judul: 'Sejarah singkat Ganesha Operation?', deskripsi: [
      '   Di tengah-tengah persaingan yang tajam dalam industri bimbingan belajar, pada tanggal 1 Mei 1984 Ganesha Operation didirikan di Kota Bandung. Seiring dengan perjalanan waktu, berkat keuletan dan konsistensinya dalam menjaga kualitas, kini Ganesha Operation telah tumbuh bagai remaja tambun dengan 728 outlet yang tersebar di 251 kota besar se Indonesia. Latar belakang pendirian lembaga ini adalah adanya mata rantai yang terputus dari link informasi Sekolah Menengah Atas (SMA) dengan dunia Perguruan Tinggi Negeri (PTN). Posisi inilah yang diisi oleh Ganesha Operation untuk berfungsi sebagai jembatan dunia SMA terhadap dunia PTN mengenai informasi jurusan PTN (prospek dan tingkat persaingannya), pemberian materi pelajaran yang sesuai dengan ruang lingkup bahan uji seleksi penerimaan mahasiswa baru dan pemberian metode-metode inovatif dan kreatif menyelesaikan soal-soal tes masuk PTN sehingga membantu para siswa lulusan SMA memenuhi keinginan mereka memasuki PTN.',
      '   Meskipun pada awalnya hingga tahun 1992 Ganesha Operation hanya ada di Bandung, pada tahun 1993 dibuka cabang pertama di Denpasar, dan pengembangan secara serius dilakukan mulai tahun 1995. Sejak itu pertumbuhan cabang-cabang Ganesha Operation benar-benar tidak terbendung. Image Ganesha Operation yang sangat kuat telah merambah ke seluruh Nusantara sehingga setiap cabang baru dibuka langsung diserbu oleh para siswa. Kalau pada saat pertama kali berdiri siswa Ganesha Operation masih sedikit dan hanya mencakup program kelas 3 SMA, kemudian dari tahun ke tahun jumlah siswanya terus bertambah. Sesuai dengan tuntutan masyarakat, saat ini Ganesha Operation tidak hanya membuka program di kelas 3 SMA saja tetapi dari kelas 3 SD hingga 12 SMA bahkan alumni. Saat ini untuk 1 (satu) tahun pelajaran jumlah seluruh siswa Ganesha Operation dapat mencapai ratusan ribu siswa, suatu jumlah yang sangat besar. Khusus untuk kelas 3 SMA, tahun 2022 ini Ganesha Operation berhasil meluluskan lebih dari 45.000 siswanya di berbagai PTN dan PT Kedinasan terkemuka di Indonesia. Bahkan Ganesha Operation mencatatkan 2 rekor MURI sekaligus, yaitu: Sebagai bimbel terbaik dengan meluluskan siswa terbanyak ke PTN dan PT Kedinasan dan sebagai bimbel terbesar dengan 692 gedung yang tersebar dari Aceh hingga Ambon yang dikelolah secara terpusat (no franchise), itulah mengapa reputasi Ganesha Operation begitu spektakuler.'
    ], subData: []),
    AboutModel(
      judul: 'Visi Dan Misi Ganesha Operation?',
      deskripsi: [],
      subData: [
        AboutModel(judul: 'Visi', deskripsi: [
          'Menjadi lembaga bimbingan belajar yang terbaik dan terbesar di-Indonesia.'
        ], subData: []),
        AboutModel(judul: 'Misi', deskripsi: [
          '1. Mendidik siswa agar berprestasi tingkat sekolah, kota/kabupaten, provinsi, nasional, dan internasional.',
          '2. Melakukan inovasi pembelajaran melalui terobosan revolusi belajar dan Teknologi informasi.',
          '3. Meningkatkan budaya belajar siswa.',
          '4. Meningkatkan mutu pendidikan.',
          '5. Mencerdaskan kehidupan bangsa.'
        ], subData: []),
      ],
    ),
  ];

  static const kBaseUrlSMBA = 'base-url-smba';

  // endpoint
  // simpan jawaban
  static const simpanLateks =
      '/buku-sakti/mobile/v1/buku-sakti-mobile/simpan-jawaban/lateks';
  static const simpanEMMA =
      '/buku-sakti/mobile/v1/buku-sakti-mobile/simpan-jawaban/emma';
  static const simpanEMWA =
      '/buku-sakti/mobile/v1/buku-sakti-mobile/simpan-jawaban/emwa';
  static const simpanPakins =
      '/buku-sakti/mobile/v1/buku-sakti-mobile/simpan-jawaban/paket-intensif';
  static const simpanSokod =
      '/buku-sakti/mobile/v1/buku-sakti-mobile/simpan-jawaban/soal-koding';
  static const simpanPenmat =
      '/buku-sakti/mobile/v1/buku-sakti-mobile/simpan-jawaban/pendalaman-materi';
  static const simpanSoref =
      '/buku-sakti/mobile/v1/buku-sakti-mobile/simpan-jawaban/soal-referensi';
  static const simpanVAK = '/goa-vak/mobile/v1/vak-mobile/simpan-jawaban';

  // get jawaban
  static const getJawabanVAK =
      '/goa-vak/mobile/v1/vak-mobile/get-jawaban-paket';
  static const getJawabanEMWA =
      '/buku-sakti/mobile/v1/buku-sakti-mobile/get-jawaban-paket/emwa';
  static const getJawabanEMMA =
      '/buku-sakti/mobile/v1/buku-sakti-mobile/get-jawaban-paket/emma';
  static const getJawabanLateks =
      '/buku-sakti/mobile/v1/buku-sakti-mobile/get-jawaban-bab/lateks';
  static const getJawabanPakins =
      '/buku-sakti/mobile/v1/buku-sakti-mobile/get-jawaban-bab/paket-intensif';
  static const getJawabanSoKod =
      '/buku-sakti/mobile/v1/buku-sakti-mobile/get-jawaban-bab/soal-koding';
  static const getJawabanPenMat =
      '/buku-sakti/mobile/v1/buku-sakti-mobile/get-jawaban-bab/pendalaman-materi';
  static const getJawabanSoRef =
      '/buku-sakti/mobile/v1/buku-sakti-mobile/get-jawaban-bab/soal-referensi';

  // hasil jawaban
  static const hasilJawaban =
      '/buku-sakti/mobile/v1/buku-sakti-mobile/hasil-jawaban/';
  static const hasilKuis =
      '/buku-sakti/mobile/v1/buku-sakti-mobile/kuis/hasil-jawaban';
  static const hasilRacing = '/racing/mobile/v1/racing-mobile/hasil-jawaban';
  static const hasilVAK = '/goa-vak/mobile/v1/vak-mobile/hasil-jawaban';

  // get kisi-kisi
  static const kisiTOBK = '/tobk/mobile/v1/tobk/kisi-kisi/';
  static const kisiGOA = '/goa-vak/mobile/v1/goa-mobile/kisi-kisi/';
  static const kisiKuis =
      '/buku-sakti/mobile/v1/buku-sakti-mobile/kuis/kisi-kisi/';
  static const kisiRacing = '/racing/mobile/v1/racing-mobile/kisi-kisi/';

  // get list paket
  static const listRacing = '/racing/mobile/v1/racing-mobile/listpaket';
  static const listGOA = '/goa-vak/mobile/v1/goa-mobile/listpaket';
  static const listTOBK = '/tobk/v2/mobile/list-paket';

  // get detail waktu
  static const waktuTOBK = '/tobk/mobile/v1/tobk/detail-waktu/';
  static const waktuGOA = '/goa-vak/mobile/v1/goa-mobile/detail-waktu/';
  static const waktuKuis =
      '/buku-sakti/mobile/v1/buku-sakti-mobile/kuis/detail-waktu/';
  static const waktuRacing = '/racing/mobile/v1/racing-mobile/detail-waktu/';
  static const waktuPaket = '/buku-sakti/mobile/v2/detail-waktu/';

  // get soal
  static const soalKuis = '/buku-sakti/mobile/v1/buku-sakti-mobile/kuis/soal';
  static const soalGOA = '/goa-vak/mobile/v1/goa-mobile/soal';
  static const soalRacing = '/racing/mobile/v1/racing-mobile/soal';
  static const soalTOBK = '/tobk/mobile/v1/tobk/soal';

  // store jawaban
  static const storeTOBK = '/tobk/v2/mobile/simpan-jawaban-siswa';
  static const storeKuis = '/buku-sakti/mobile/v2/kuis/simpan-jawaban-siswa';
  static const storeRacing = '/racing/mobile/v2/simpan-jawaban-siswa';
  static const storeGOA = '/goa-vak/mobile/v2/goa/simpan-jawaban-siswa';
  static const storeEMMA = '/buku-sakti/mobile/v2/simpan-jawaban-paket/emma';
  static const storeEMWA = '/buku-sakti/mobile/v2/simpan-jawaban-paket/emwa';

  // mulai to
  static const startTOBK = '/tobk/mobile/v1/tobk/mulai-to';
  static const startKuis =
      '/buku-sakti/mobile/v1/buku-sakti-mobile/kuis/mulai-to';
  static const startGOA = '/goa-vak/mobile/v1/goa-mobile/mulai-to';
  static const startRacing = '/racing/mobile/v1/racing-mobile/mulai-to';
  static const startEMMA = '/buku-sakti/mobile/v2/mulai-to/emma';
  static const startEMWA = '/buku-sakti/mobile/v2/mulai-to/emwa';
  static const startVAK = '/goa-vak/mobile/v1/vak-mobile/mulai-to';

  // get jawaban by urutan
  static const getJawabanSortTOBK = '/tobk/v2/mobile/get-jawaban-siswa-urutan';
  static const getJawabanSortKuis =
      '/buku-sakti/mobile/v2/kuis/get-jawaban-siswa-urutan';
  static const getJawabanSortRacing =
      '/racing/mobile/v2/get-jawaban-siswa-urutan';
  static const getJawabanSortGOA =
      '/goa-vak/mobile/v2/goa/get-jawaban-siswa-urutan';
  static const getJawabanSortEMMA =
      '/buku-sakti/mobile/v2/get-jawaban-siswa-urutan/emma';
  static const getJawabanSortEMWA =
      '/buku-sakti/mobile/v2/get-jawaban-siswa-urutan/emwa';

  // get jawaban all
  static const getJawabanAllTOBK = '/tobk/v2/mobile/get-jawaban-siswa-all';
  static const getJawabanAllGOA =
      '/goa-vak/mobile/v2/goa/get-jawaban-siswa-all';
  static const getJawabanAllRacing = '/racing/mobile/v2/get-jawaban-siswa-all';
  static const getJawabanAllKuis =
      '/buku-sakti/mobile/v2/kuis/get-jawaban-siswa-all';

  // get jawaban paket
  static const kGetJawabanKuis =
      '/buku-sakti/mobile/v1/buku-sakti-mobile/kuis/get-jawaban-paket';
  static const kGetJawabanRacing =
      '/racing/mobile/v1/racing-mobile/get-jawaban-paket';
  static const kGetJawabanGOA =
      '/goa-vak/mobile/v1/goa-mobile/get-jawaban-paket';

  // selesai to
  static const endTOBK = '/tobk/v2/mobile/selesai-to-v2';
  static const endRacing = '/racing/mobile/v2/selesai-to-v2';
  static const endKuis = '/buku-sakti/mobile/v2/kuis/selesai-to-v2';
  static const endGOA = '/goa-vak/mobile/v2/goa/selesai-to';
  static const endEMMA = '/buku-sakti/mobile/v2/selesai-to-baru/emma';
  static const endEMWA = '/buku-sakti/mobile/v2/selesai-to-baru/emwa';
  static const endVAK = '/goa-vak/mobile/v1/vak-mobile/selesai-to';

  // olah data
  static const olahTOBK = '/tobk/v2/mobile/olah-data-jawaban';
  static const olahKuis = '/buku-sakti/mobile/v2/kuis/olah-data-jawaban';
  static const olahRacing = '/racing/mobile/v2/olah-data-jawaban';
  static const olahGOA = '/goa-vak/mobile/v2/goa/olah-data-jawaban';
  static const olahEMMA =
      '/buku-sakti/mobile/v2/olah-data-jawaban-bundel-baru/emma';
  static const olahEMWA =
      '/buku-sakti/mobile/v2/olah-data-jawaban-bundel-baru/emwa';
  static const olahLateks =
      '/buku-sakti/mobile/v2/olah-data-jawaban-bundel-baru/lateks';
  static const olahPakins =
      '/buku-sakti/mobile/v2/olah-data-jawaban-bundel-baru/paket-intensif';
  static const olahSokod =
      '/buku-sakti/mobile/v2/olah-data-jawaban-bundel-baru/soal-koding';
  static const olahPenmat =
      '/buku-sakti/mobile/v2/olah-data-jawaban-bundel-baru/pendalaman-materi';
  static const olahSoref =
      '/buku-sakti/mobile/v2/olah-data-jawaban-bundel-baru/soal-referensi';

  // get urutan aktif
  static const bUrutanAktifTOBK = '/tobk/v2/mobile/urutan-aktif-subtes';
  static const bUrutanAktifKuis =
      '/buku-sakti/mobile/v2/kuis/urutan-aktif-subtes';
  static const bUrutanAktifGOA = '/goa-vak/mobile/v2/goa/urutan-aktif-subtes';
  static const bUrutanAktifRacing = '/racing/mobile/v2/urutan-aktif-subtes';

  // profile
  static const getSekolahKelas = '/data/mobile/v1/mapel-pilihan/kelas';
  static const getOpsiMapelPilihan = '/data/mobile/v1/mapel-pilihan/opsi/';
  static const getCurrentMapelPilihan = '/data/mobile/v1/mapel-pilihan/get/';
  static const saveMapelPilihan = '/data/mobile/v1/mapel-pilihan/simpan';
}
