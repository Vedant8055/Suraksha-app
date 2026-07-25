import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

/// Profile hero card (avatar + name/email + edit actions) extracted from
/// `ProfileScreen` (Phase 2 structure-only extraction). Identical UI to the
/// original `_buildProfileHero` private method.
class ProfileHero extends StatelessWidget {
  const ProfileHero({
    super.key,
    required this.displayName,
    required this.displayEmail,
    required this.profileImage,
    required this.profileText,
    required this.profileMuted,
    required this.isLight,
    this.onPreviewPhoto,
    this.onEditPhoto,
    this.onEditDetails,
  });

  final String displayName;
  final String displayEmail;
  final ImageProvider<Object>? profileImage;
  final Color profileText;
  final Color profileMuted;
  final bool isLight;

  /// Invoked when the avatar is tapped and a [profileImage] is available.
  final VoidCallback? onPreviewPhoto;
  final VoidCallback? onEditPhoto;
  final VoidCallback? onEditDetails;

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLight
                ? const [
                    Color(0xFFFFFFFF),
                    Color(0xFFF2F7FF),
                    Color(0xFFE7F1FF),
                  ]
                : const [
                    Color(0xFF121B2E),
                    Color(0xFF0E1727),
                    Color(0xFF08111D),
                  ],
          ),
          border: Border.all(
            color: isLight
                ? const Color(0xFFD9E6F8)
                : Colors.white.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isLight ? 0.06 : 0.24),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: profileImage == null ? null : onPreviewPhoto,
                        customBorder: const CircleBorder(),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: AppTheme.primaryColor.withValues(
                            alpha: 0.18,
                          ),
                          backgroundImage: profileImage,
                          child: profileImage == null
                              ? const Icon(
                                  Icons.person_rounded,
                                  size: 52,
                                  color: AppTheme.primaryColor,
                                )
                              : null,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: onEditPhoto,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          color: profileText,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayEmail,
                        style: TextStyle(color: profileMuted, fontSize: 13.5),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context).t('profileHeroCta'),
                        style: TextStyle(
                          color: profileMuted,
                          height: 1.35,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onEditDetails,
                icon: const Icon(Icons.edit_document),
                label: Text(
                  AppLocalizations.of(context).t('editProfileDetails'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
