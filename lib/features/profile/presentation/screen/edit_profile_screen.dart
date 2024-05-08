import 'dart:async';
import 'dart:math';

import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/core/shared/builder/responsive_builder.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../auth/data/model/user_model.dart';
import '../../../home/presentation/provider/profile_picture_provider.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/config/theme.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/image/profile_picture_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final ProfilePictureProvider _profileProvider =
      context.read<ProfilePictureProvider>();
  UserModel? userData;
  var completer = Completer();

  /// URL
  late final ValueNotifier<String?> _profilePicture = ValueNotifier(
    _profileProvider.getPictureByNoReg(
      noRegistrasi: userData?.noRegistrasi ?? '',
    ),
  );

  /// Just Indexing
  late final ValueNotifier<String?> _selectedAvatars = ValueNotifier(
    _profileProvider.getSelectedAvatar(
        noRegistrasi: userData?.noRegistrasi ?? ''),
  );

  late final double _size = (context.isMobile) ? 96 : 64;
  late final double _radius = (_size / 2).floorToDouble();
  final Duration _animDuration = const Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (context.isMobile) ? _buildAppBar(context) : null,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is LoadedUser) {
            userData = state.user;
          }

          return ResponsiveBuilder(
            mobile: _buildBody(context),
            tablet: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildAppBar(context),
                      Padding(
                        padding: EdgeInsets.only(
                          top: context.dp(12),
                          bottom: context.dp(24),
                        ),
                        child: _buildAvatarWidget(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.all(context.dp(12)),
                      child: _buildBody(context),
                    ))
              ],
            ),
          );
        },
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Future<void> _simpanPerubahan(BuildContext context) async {
    if (_profilePicture.value == null) {
      gShowTopFlash(context, 'Pilih avatar kamu dulu ya Sobat');
    } else {
      bool konfirmasiSimpan = await gShowBottomDialog(
        context,
        title: 'Konfirmasi Simpan',
        message: 'Apakah Sobat yakin untuk menyimpan pilihan avatar kamu?',
        dialogType: DialogType.warning,
        actions: (controller) => [
          TextButton(
            onPressed: () => controller.dismiss(false),
            style: TextButton.styleFrom(
              foregroundColor: context.onBackground,
            ),
            child: const Text('Nanti saja'),
          ),
          TextButton(
            onPressed: () => controller.dismiss(true),
            child: const Text('Simpan avatar'),
          ),
        ],
      );
      if (konfirmasiSimpan) {
        await _profileProvider.saveProfilePicture(
          noRegistrasi: userData?.noRegistrasi ?? '',
          photoUrl: _profilePicture.value ?? '',
        );
      }
    }
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      surfaceTintColor: context.primaryColor,
      title: const Text('Ubah Profil'),
      titleTextStyle: context.text.titleMedium?.copyWith(fontSize: 18),
      centerTitle: true,
      leading: IconButton(
        onPressed: () {
          _profileProvider.clearNoregPicture(userData?.noRegistrasi ?? '');
          Navigator.pop(context);
        },
        color: context.primaryColor,
        icon: const Icon(Icons.close_rounded),
      ),
      actions: [
        ValueListenableBuilder<String?>(
          valueListenable: _profilePicture,
          builder: (context, selectedAvatar, _) => IconButton(
            onPressed: (selectedAvatar == null)
                ? null
                : () async => await _simpanPerubahan(context),
            disabledColor: context.disableColor,
            color: Palette.kSuccessSwatch,
            icon: const Icon(Icons.check_rounded),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  CustomScrollView _buildBody(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (context.isMobile)
          SliverPadding(
            padding: EdgeInsets.only(
              top: context.dp(12),
              bottom: context.dp(24),
            ),
            sliver: SliverToBoxAdapter(
              child: _buildAvatarWidget(context),
            ),
          ),
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: context.dp(24),
            vertical: context.dp(8),
          ),
          sliver: SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!context.isMobile)
                  const Expanded(child: Divider(indent: 4)),
                Text(
                  'Pilih avatar kamu',
                  style: context.text.bodyLarge?.copyWith(
                    color: context.onBackground.withOpacity(0.8),
                  ),
                ),
                const Expanded(child: Divider(indent: 4)),
              ],
            ),
          ),
        ),
        _buildSliverGridAvatar(context, true),
        _buildSliverGridAvatar(context, false),
      ],
    );
  }

  Hero _buildAvatarWidget(BuildContext context) {
    return Hero(
      key: const Key('UserAvatarHero'),
      tag: 'UserAvatarHero',
      transitionOnUserGestures: true,
      child: _buildCircleAvatar(context),
    );
  }

  SliverPadding _buildSliverGridAvatar(BuildContext context, bool isBoy) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        vertical: (isBoy) ? min(12, context.dp(12)) : 0,
        horizontal: context.dp(24),
      ),
      sliver: SliverGrid.count(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: min(18, context.dp(12)), // Spacing horizontal
        mainAxisSpacing: min(18, context.dp(12)), // Spacing vertical
        children: List.generate(
          8,
          (index) => _buildAvatarOptionItem(index, isBoy),
        ),
      ),
    );
  }

  ValueListenableBuilder<String?> _buildAvatarOptionItem(
      int index, bool isBoy) {
    String avatarIndex = (isBoy) ? 'b-$index' : 'g-$index';

    return ValueListenableBuilder<String?>(
      valueListenable: _selectedAvatars,
      builder: (context, selected, _) => InkWell(
        onTap: () {
          _selectedAvatars.value = avatarIndex;
          _profilePicture.value = avatarIndex.avatar;
          _profileProvider.setPictureByNoreg(
            noRegistrasi: userData?.noRegistrasi ?? '',
            photoUrl: avatarIndex.avatar,
          );
        },
        borderRadius: (selected == avatarIndex)
            ? BorderRadius.circular(min(38, context.dp(24)))
            : BorderRadius.circular(min(24, context.dp(14))),
        child: AnimatedContainer(
          duration: _animDuration,
          curve: Curves.easeInCubic,
          decoration: BoxDecoration(
            color:
                (selected == avatarIndex) ? context.secondaryContainer : null,
            borderRadius: (selected == avatarIndex)
                ? BorderRadius.circular(min(38, context.dp(24)))
                : BorderRadius.circular(min(24, context.dp(14))),
            border: Border.all(
                color: (selected == avatarIndex)
                    ? context.secondaryColor
                    : (isBoy)
                        ? context.tertiaryColor
                        : context.primaryContainer),
            image: DecorationImage(
              image: NetworkImage(avatarIndex.avatar),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleAvatar(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: _profilePicture,
      builder: (context, selectedAvatar, _) {
        return AnimatedSwitcher(
          key: const ValueKey('CircleAvatarUbahProfile'),
          duration: const Duration(milliseconds: 600),
          switchInCurve: Curves.easeInBack,
          switchOutCurve: Curves.easeInBack.flipped,
          transitionBuilder: (child, animation) {
            final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: AnimatedBuilder(
                animation: rotateAnim,
                child: child,
                builder: (context, child2) {
                  return Transform(
                    transform: Matrix4.rotationY(rotateAnim.value),
                    alignment: Alignment.center,
                    child: child2,
                  );
                },
              ),
            );
          },
          child: CircleAvatar(
            key: ValueKey('Circle $selectedAvatar'),
            radius: context.dp(_radius),
            backgroundColor: context.secondaryColor,
            child: ProfilePictureWidget.circle(
              name: userData?.namaLengkap ?? 'GOmin',
              width: context.dp(_size) - min(12, context.dp(4)),
              noRegistrasi: userData?.noRegistrasi ?? '-',
              isUserLogin: userData != null,
              photoUrl: selectedAvatar,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: _showPickImageOption,
      child: Container(
        width: (context.isMobile) ? context.dp(50) : context.dp(15),
        height: (context.isMobile) ? context.dp(50) : context.dp(15),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.secondaryColor,
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showPickImageOption() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.camera,
    ].request();

    if (!statuses[Permission.storage]!.isGranted &&
        !statuses[Permission.camera]!.isGranted) return;

    if (!context.mounted) return;

    await showModalBottomSheet(
      isScrollControlled: true,
      scrollControlDisabledMaxHeightRatio: context.dh * 0.2,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          top: context.dp(24),
          bottom: context.dp(20),
          left: context.dp(18),
          right: context.dp(18),
        ),
        child: SizedBox(
          width: context.dw,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildImagePickerItem(
                icon: Image.asset(
                  'assets/icon/ic_camera.png',
                  width: context.dp(20),
                ),
                title: 'Camera',
                onTap: () async {
                  Navigator.pop(context);
                  context.showBlockDialog(dismissCompleter: completer);

                  await _profileProvider.pickImageFromCamera().then((_) {
                    _profilePicture.value = _profileProvider.getPictureByNoReg(
                      noRegistrasi: userData?.noRegistrasi ?? '',
                    );

                    if (!completer.isCompleted) {
                      completer.complete();
                    }
                  });
                },
              ),
              _buildImagePickerItem(
                icon: Image.asset(
                  'assets/icon/ic_gallery.png',
                  width: context.dp(20),
                ),
                title: 'Gallery',
                onTap: () async {
                  Navigator.pop(context);

                  context.showBlockDialog(dismissCompleter: completer);

                  await _profileProvider.pickImageFromGallery().then((_) {
                    _profilePicture.value = _profileProvider.getPictureByNoReg(
                      noRegistrasi: userData?.noRegistrasi ?? '',
                    );

                    if (!completer.isCompleted) {
                      completer.complete();
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerItem({
    required Widget icon,
    required String title,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: context.dp(80),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              icon,
              const SizedBox(height: 10),
              Text(
                title,
                style: context.text.labelSmall,
              ),
            ],
          ),
        ),
      );
}
