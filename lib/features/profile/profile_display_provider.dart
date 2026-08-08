import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suraksha_women_safety_app/features/profile/profile_session_cache.dart';
import 'package:suraksha_women_safety_app/models/user_model.dart';

class ProfileDisplayState {
  final String name;
  final String photoPath;

  const ProfileDisplayState({this.name = '', this.photoPath = ''});

  ProfileDisplayState copyWith({String? name, String? photoPath}) {
    return ProfileDisplayState(
      name: name ?? this.name,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}

final profileDisplayProvider =
    StateNotifierProvider<ProfileDisplayNotifier, ProfileDisplayState>(
      (ref) => ProfileDisplayNotifier()..load(),
    );

class ProfileDisplayNotifier extends StateNotifier<ProfileDisplayState> {
  ProfileDisplayNotifier() : super(const ProfileDisplayState());

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      name: await ProfileSessionCache.readDisplayName(),
      photoPath:
          prefs.getString(ProfileSessionCache.photoPathKey)?.trim() ?? '',
    );
  }

  Future<void> clear() async {
    await ProfileSessionCache.clearAll();
    state = const ProfileDisplayState();
  }

  Future<void> applyUser(UserModel user) async {
    await ProfileSessionCache.syncFromUser(user);
    state = ProfileDisplayState(name: user.name.trim());
  }

  Future<void> update({String? name, String? photoPath}) async {
    final prefs = await SharedPreferences.getInstance();

    if (name != null) {
      final normalizedName = name.trim();
      await ProfileSessionCache.writeDisplayName(normalizedName);
      state = state.copyWith(name: normalizedName);
    }

    if (photoPath != null) {
      final normalizedPhotoPath = photoPath.trim();
      if (normalizedPhotoPath.isEmpty) {
        await prefs.remove(ProfileSessionCache.photoPathKey);
      } else {
        await prefs.setString(
          ProfileSessionCache.photoPathKey,
          normalizedPhotoPath,
        );
      }
      state = state.copyWith(photoPath: normalizedPhotoPath);
    }
  }
}
