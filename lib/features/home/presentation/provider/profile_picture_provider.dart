import 'dart:async';
import 'dart:developer' as logger show log;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:gokreasi_new/core/config/extensions.dart';
import 'package:gokreasi_new/core/helper/kreasi_shared_pref.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import 'package:gokreasi_new/features/home/domain/entity/uploaded_photo_profile.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/config/constant.dart';
import '../../service/profile_picture_service_api.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/config/global.dart';
import '../../../../core/util/app_exceptions.dart';

// import 'package:http/http.dart' as http;
class ProfilePictureProvider with ChangeNotifier {
  final _apiService = ProfilePictureServiceApi();

  final Map<String, bool> _isPhotoProfileExist = {};
  final Map<String, String> _profileUrl = {};

  bool isPhotoProfileExist({required String noRegistrasi}) {
    if (noRegistrasi.isEmpty || noRegistrasi == '-') return false;
    return _isPhotoProfileExist[noRegistrasi] ?? false;
  }

  String? getPictureByNoReg({required String noRegistrasi}) {
    if (noRegistrasi.isEmpty || noRegistrasi == '-') return null;
    return _profileUrl[noRegistrasi];
  }

  String? getSelectedAvatar({required String noRegistrasi}) {
    if (noRegistrasi.isEmpty || noRegistrasi == '-') return null;
    if (!(_isPhotoProfileExist[noRegistrasi] ?? false) ||
        _profileUrl[noRegistrasi] == null) {
      return null;
    }
    return null;
  }

  void setPictureByNoreg({
    required String noRegistrasi,
    required String photoUrl,
  }) {
    _profileUrl[noRegistrasi] = photoUrl;
    notifyListeners();
  }

  void clearNoregPicture(String noreg) {
    String savedPhotoProfile = KreasiSharedPref().getProfilePhoto() ?? '';
    _profileUrl[noreg] = savedPhotoProfile;
    notifyListeners();
  }

  /// [getProfilePicture] parameter isMainUser digunakan untuk mengecek apakah
  /// get foto profile user utama, bukan dari teman leaderboard
  Future<String?> getProfilePicture({
    required String namaLengkap,
    required String noRegistrasi,
    required bool isMainUser,
    bool isLogin = false,
  }) async {
    if (_profileUrl.containsKey(noRegistrasi)) {
      return _profileUrl[noRegistrasi];
    }

    if (!isLogin) return null;
    if (_isPhotoProfileExist[noRegistrasi] != null) {
      if ((_isPhotoProfileExist[noRegistrasi] ?? false) &&
          _profileUrl[noRegistrasi] != null) {
        return _profileUrl[noRegistrasi]!;
      }
      return null;
    }
    try {
      if (isLogin) {
        final responseData = await _apiService.fetchProfilePicture(
          namaLengkap: namaLengkap,
          noRegistrasi: noRegistrasi,
        );

        _isPhotoProfileExist.update(
          noRegistrasi,
          (value) => responseData != null,
          ifAbsent: () => responseData != null,
        );

        _profileUrl.update(
          noRegistrasi,
          (value) => responseData ?? '',
          ifAbsent: () => responseData ?? '',
        );

        //  else if (noRegistrasi == gUser?.noRegistrasi) {
        // _showMessageFiturBaru();
        // }

        if (isMainUser && responseData != null) {
          await KreasiSharedPref().setProfilePhoto(responseData);
        }
      }
      return _profileUrl[noRegistrasi];
    } on NotFoundException {
      _isPhotoProfileExist.update(
        noRegistrasi,
        (value) => false,
        ifAbsent: () => false,
      );
      return null;
    } catch (e) {
      _isPhotoProfileExist.update(
        noRegistrasi,
        (value) => false,
        ifAbsent: () => false,
      );
      return null;
    }
  }

  Future<void> _showMessageFiturBaru() async {
    const duration = Duration(seconds: 1);

    await Future.delayed(duration).then(
      (value) => gShowBottomDialogInfo(
        gNavigatorKey.currentContext!,
        title: 'Fitur Baru!!',
        message: 'Hai Sobat! Go Expert punya fitur baru lohh. '
            'Sekarang kamu bisa pilih avatar sesuka kamu. '
            'Yuk cobain fiturnya sekarang!',
        dialogType: DialogType.info,
        actions: (controller) => [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(
                gNavigatorKey.currentContext!,
                Constant.kRouteEditProfileScreen,
              );
              controller.dismiss(true);
            },
            child: const Text('Pilih Avatar'),
          ),
        ],
      ),
    );
  }

  Future<void> saveProfilePicture({
    required String noRegistrasi,
    required String photoUrl,
    bool isAvatar = true,
  }) async {
    String pesanGagal = 'Yaah, foto kamu gagal disimpan Sobat, coba lagi yaa!';

    if (noRegistrasi.isEmpty || photoUrl.isEmpty) return;
    if (noRegistrasi == '-' || photoUrl == '-') return;

    final completer = Completer();
    gNavigatorKey.currentContext!.showBlockDialog(dismissCompleter: completer);
    try {
      final response = await _apiService.setProfilePicture(
        noRegistrasi: noRegistrasi,
        photoUrl: photoUrl,
        isAvatar: isAvatar,
      );

      if (!completer.isCompleted) {
        completer.complete();
      }

      if (!response) {
        gShowTopFlash(
          gNavigatorKey.currentContext!,
          pesanGagal,
          dialogType: DialogType.error,
        );
        return;
      }

      _profileUrl.update(noRegistrasi, (value) => photoUrl,
          ifAbsent: () => photoUrl);

      _isPhotoProfileExist.update(noRegistrasi, (value) => true,
          ifAbsent: () => true);

      // save photo agar ketika back tanpa simpan
      // get dari local storage
      await KreasiSharedPref().setProfilePhoto(photoUrl);

      await gShowTopFlash(
        gNavigatorKey.currentContext!,
        'Berhasil ganti foto profil',
        dialogType: DialogType.success,
      ).then((value) {
        notifyListeners();
        Future.delayed(gDelayedNavigation).then(
          (value) => Navigator.pop(gNavigatorKey.currentContext!),
        );
      });
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('PROFILE_PICTURE-SaveExection: Error >> $e');
      }
      if (!completer.isCompleted) {
        completer.complete();
      }
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        '$e',
        dialogType: DialogType.success,
      );
    } catch (e) {
      if (kDebugMode) {
        logger.log('PROFILE_PICTURE-SaveFatalException: Error >> $e');
      }
      if (!completer.isCompleted) {
        completer.complete();
      }
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        pesanGagal,
        dialogType: DialogType.error,
      );
    } finally {
      notifyListeners();
    }
  }

  /// [_croppedImage] digunakan untuk crop gambar menjadi bulat
  Future<File?> _croppedImage(File pickedImage) async {
    final croppedFile = await ImageCropper().cropImage(
        cropStyle: CropStyle.circle,
        sourcePath: pickedImage.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: "Sesuaikan fotomu ya sobat",
              toolbarColor: gNavigatorKey.currentContext!.primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: "Sesuaikan fotomu ya sobat",
          )
        ]);
    if (croppedFile == null) return null;

    return File(croppedFile.path);
  }

  /// [pickImageFromGallery] digunakan untuk mengambil gambar dari gallery
  /// dan langsung post ke S3
  Future<void> pickImageFromGallery() async {
    try {
      final imagePicker = locator<ImagePicker>();

      XFile? pickedImage = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // <- Reduce Image quality
      );

      if (pickedImage == null) return;

      bool isImageValid = await _validateFileSize(
        pickedImage: pickedImage,
        maxImageSize: 2 * 1048576,
      );

      if (!isImageValid) return;

      final selectedImage = await _croppedImage(File(pickedImage.path));

      if (selectedImage == null) return;

      await _uploadToAWS(selectedImage);

      notifyListeners();
    } catch (e) {
      return;
    }
  }

  /// [pickImageFromCamera] digunakan untuk mengambil gambar dari camera
  /// dan langsung post ke S3
  Future<void> pickImageFromCamera() async {
    try {
      final imagePicker = locator<ImagePicker>();

      XFile? pickedImage = await imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50, // <- Reduce Image quality
      );

      if (pickedImage == null) return;

      bool isImageValid = await _validateFileSize(
        pickedImage: pickedImage,
        maxImageSize: 2 * 1048576,
      );

      if (!isImageValid) return;

      final selectedImage = await _croppedImage(File(pickedImage.path));

      if (selectedImage == null) return;

      await _uploadToAWS(selectedImage);

      notifyListeners();
    } catch (e) {
      return;
    }
  }

  Future<bool> _validateFileSize({
    required XFile pickedImage,
    required int maxImageSize,
  }) async {
    var imagePath = await pickedImage.readAsBytes();

    var fileSize = imagePath.length; // Get the file size in bytes

    if (fileSize > maxImageSize) {
      await gShowBottomDialogInfo(
        gNavigatorKey.currentContext!,
        message: 'Ukuran foto tidak boleh lebih dari 2MB, sobat',
        dialogType: DialogType.info,
      );
      return false;
    }

    return true;
  }

  /// [_uploadToAWS] digunakan untuk upload file ke AWS
  Future<void> _uploadToAWS(File imageFile) async {
    try {
      final noreg = KreasiSharedPref().getNomorReg() ?? '';

      final res = await _apiService.uploadToAWS(
        imageFile: imageFile,
        noRegistrasi: noreg,
      );

      final uploadedPhotoProfile = UploadedPhotoProfile.fromJson(res);

      if (uploadedPhotoProfile.link == null) return;

      if (!_profileUrl.containsKey(noreg)) {
        _profileUrl[noreg] = '';
      }

      _profileUrl[noreg] = uploadedPhotoProfile.link!;

      notifyListeners();
    } catch (e) {
      return;
    }
  }
}
