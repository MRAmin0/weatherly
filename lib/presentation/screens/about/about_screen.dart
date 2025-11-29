import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  final String developerEmail = "aminmonajati9@gmail.com";
  final String githubProject = "https://github.com/MRAmin0/Weatherly";
  final String githubProfile = "https://github.com/MRAmin0";

  Future<String> _loadVersion(AppLocalizations l10n) async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return l10n.readingVersion;
    }
  }

  Future<void> _openUrl(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _sendEmail(String email) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
      query: "subject=Feedback on Weatherly",
    );
    await launchUrl(uri);
  }

  Future<void> _reportIssue(BuildContext context) async {
    final platform = Theme.of(context).platform;

    final package = await PackageInfo.fromPlatform();
    final appVersion = package.version;

    final deviceInfo = DeviceInfoPlugin();
    String deviceData = "Unknown";

    try {
      if (platform == TargetPlatform.android) {
        final android = await deviceInfo.androidInfo;
        deviceData =
            "Android (${android.model})\nVersion: ${android.version.release}\nSDK: ${android.version.sdkInt}";
      } else if (platform == TargetPlatform.iOS) {
        final ios = await deviceInfo.iosInfo;
        deviceData =
            "iOS (${ios.utsname.machine})\niOS Version: ${ios.systemVersion}";
      } else {
        deviceData = "Web / Desktop Platform";
      }
    } catch (_) {
      deviceData = "Error while reading device info";
    }

    final body =
        """
Please describe the issue:

--------------------------
DEVICE INFO
--------------------------
$deviceData

--------------------------
APP INFO
--------------------------
App Version: $appVersion

--------------------------
ISSUE DESCRIPTION
--------------------------

(Write the problem here)
""";

    final Uri uri = Uri(
      scheme: 'mailto',
      path: developerEmail,
      query: Uri.encodeFull("subject=Weatherly Issue Report&body=$body"),
    );

    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : theme.colorScheme.onSurface;
    final subTextColor = isDark
        ? Colors.white70
        : theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.aboutApp,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface.withOpacity(0.9),
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),

      body: Stack(
        children: [
          // 🔹 پس زمینه شیشه‌ای فقط در دارک مود
          if (isDark)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(color: Colors.black.withOpacity(0.28)),
              ),
            ),

          ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              const SizedBox(height: 16),

              // --- Logo Glass Circle ---
              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? Colors.white.withOpacity(0.12)
                        : theme.colorScheme.primary.withOpacity(0.1),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.25)
                          : theme.colorScheme.primary.withOpacity(0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.cloud_circle_rounded,
                    size: 60,
                    color: isDark ? Colors.white : theme.colorScheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- Description Card ---
              _glassCard(
                isDark: isDark,
                theme: theme,
                child: Text(
                  l10n.appDescription,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: textColor,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- Info Card ---
              _glassCard(
                isDark: isDark,
                theme: theme,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.info_outline,
                        color: isDark
                            ? Colors.white
                            : theme.colorScheme.primary,
                      ),
                      title: Text(
                        l10n.appVersion,
                        style: TextStyle(color: textColor),
                      ),
                      subtitle: FutureBuilder<String>(
                        future: _loadVersion(l10n),
                        builder: (context, snap) => Text(
                          snap.data ?? l10n.readingVersion,
                          style: TextStyle(color: subTextColor),
                        ),
                      ),
                    ),
                    _divider(isDark, theme),
                    ListTile(
                      leading: Icon(
                        Icons.history_outlined,
                        color: isDark
                            ? Colors.white
                            : theme.colorScheme.primary,
                      ),
                      title: Text(
                        l10n.changelog,
                        style: TextStyle(color: textColor),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: subTextColor,
                      ),
                      onTap: () =>
                          _showChangelogDialog(context, l10n, isDark, theme),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- Dev Card ---
              _glassCard(
                isDark: isDark,
                theme: theme,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.person_outline,
                        color: isDark
                            ? Colors.white
                            : theme.colorScheme.primary,
                      ),
                      title: Text(
                        l10n.developer,
                        style: TextStyle(color: textColor),
                      ),
                      subtitle: Text(
                        l10n.developerName,
                        style: TextStyle(color: subTextColor),
                      ),
                      onTap: () => _openUrl(githubProfile),
                    ),
                    _divider(isDark, theme),
                    ListTile(
                      leading: Icon(
                        Icons.email_outlined,
                        color: isDark
                            ? Colors.white
                            : theme.colorScheme.primary,
                      ),
                      title: Text(
                        l10n.contactViaEmail,
                        style: TextStyle(color: textColor),
                      ),
                      onTap: () => _sendEmail(developerEmail),
                    ),
                    _divider(isDark, theme),
                    ListTile(
                      leading: Icon(
                        Icons.code_outlined,
                        color: isDark
                            ? Colors.white
                            : theme.colorScheme.primary,
                      ),
                      title: Text(
                        l10n.projectOnGithub,
                        style: TextStyle(color: textColor),
                      ),
                      onTap: () => _openUrl(githubProject),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- Issue report ---
              _glassCard(
                isDark: isDark,
                theme: theme,
                child: ListTile(
                  leading: const Icon(
                    Icons.bug_report_outlined,
                    color: Colors.orangeAccent,
                  ),
                  title: Text(
                    l10n.reportAnIssue,
                    style: TextStyle(color: textColor),
                  ),
                  onTap: () => _reportIssue(context),
                ),
              ),

              const SizedBox(height: 28),
              Center(
                child: Text(
                  "Made with ❤️ in Flutter",
                  style: TextStyle(color: subTextColor, fontSize: 12),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------ GlassCard ------------------------
  Widget _glassCard({
    required bool isDark,
    required ThemeData theme,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : theme.colorScheme.surfaceVariant.withOpacity(0.7),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.18)
              : theme.colorScheme.outlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _divider(bool isDark, ThemeData theme) {
    return Divider(
      height: 1,
      color: isDark
          ? Colors.white.withOpacity(0.12)
          : theme.colorScheme.outlineVariant,
    );
  }

  // ------------------------ CHANGELOG ------------------------
  void _showChangelogDialog(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
    ThemeData theme,
  ) {
    showDialog(
      context: context,
      barrierColor: isDark ? Colors.black.withOpacity(0.25) : Colors.black12,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AlertDialog(
            backgroundColor: isDark
                ? Colors.black.withOpacity(0.6)
                : theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.18)
                    : theme.colorScheme.outlineVariant,
              ),
            ),
            title: Text(
              l10n.versionHistory,
              style: TextStyle(
                color: isDark ? Colors.white : theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Text(
                '''
💎 نسخه 1.9.0 (جدید)
• بازطراحی کامل رابط کاربری با سبک شیشه‌ای
• پس‌زمینه دینامیک بر اساس وضعیت هوا
• انیمیشن‌های جدید صفحه اصلی
• لیست جستجوهای پیشرفته
• طراحی جدید Settings و About

🌈 نسخه 1.8.0
• ارتقا به Material 3

⭐ نسخه 1.7.0
• رفع باگ‌ها و بهبود پایداری

✨ نسخه 1.6.0
• انیمیشن‌های جدید

🎨 نسخه 1.5.0
• طراحی جدید صفحه درباره ما

🌈 نسخه 1.4.0
• بهبود آیکون‌های وضعیت آب‌وهوا

🛠 نسخه 1.3.0
• رفع مشکل نمایش اطلاعات

🌍 نسخه 1.2.0
• ذخیره چند شهر

🗣 نسخه 1.1.0
• اصلاح ترجمه‌ها

🚀 نسخه 1.0.0
• انتشار اولیه
''',
                style: TextStyle(
                  color: isDark
                      ? Colors.white70
                      : theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  l10n.close,
                  style: TextStyle(
                    color: isDark
                        ? Colors.lightBlueAccent
                        : theme.colorScheme.primary,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
