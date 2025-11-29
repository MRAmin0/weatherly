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
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
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

    const whiteText = TextStyle(color: Colors.white);
    final whiteSubText = TextStyle(color: Colors.white.withOpacity(0.7));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.aboutApp),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),

      body: Stack(
        children: [
          // 🔥 I. پس زمینه کاملاً شیشه‌ای
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(color: Colors.black.withOpacity(0.25)),
            ),
          ),

          // 🔥 II. محتوای اصلی
          ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              const SizedBox(height: 12),

              // --- Header Logo (شیشه‌ای) ---
              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.08),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.cloud_circle_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- Description (کارت شیشه‌ای) ---
              _glassCard(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.appDescription,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- Info Section ---
              _glassCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                      ),
                      title: Text(l10n.appVersion, style: whiteText),
                      subtitle: FutureBuilder<String>(
                        future: _loadVersion(l10n),
                        builder: (context, snap) => Text(
                          snap.data ?? l10n.readingVersion,
                          style: whiteSubText,
                        ),
                      ),
                    ),
                    _divider(),
                    ListTile(
                      leading: const Icon(
                        Icons.history_outlined,
                        color: Colors.white,
                      ),
                      title: Text(l10n.changelog, style: whiteText),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: whiteSubText.color,
                      ),
                      onTap: () => _showChangelogDialog(context, l10n),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- Dev Info ---
              _glassCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                      ),
                      title: Text(l10n.developer, style: whiteText),
                      subtitle: Text(l10n.developerName, style: whiteSubText),
                      onTap: () => _openUrl(githubProfile),
                    ),
                    _divider(),
                    ListTile(
                      leading: const Icon(
                        Icons.email_outlined,
                        color: Colors.white,
                      ),
                      title: Text(l10n.contactViaEmail, style: whiteText),
                      onTap: () => _sendEmail(developerEmail),
                    ),
                    _divider(),
                    ListTile(
                      leading: const Icon(
                        Icons.code_outlined,
                        color: Colors.white,
                      ),
                      title: Text(l10n.projectOnGithub, style: whiteText),
                      onTap: () => _openUrl(githubProject),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _glassCard(
                child: ListTile(
                  leading: const Icon(
                    Icons.bug_report_outlined,
                    color: Colors.orangeAccent,
                  ),
                  title: Text(l10n.reportAnIssue, style: whiteText),
                  onTap: () => _reportIssue(context),
                ),
              ),

              const SizedBox(height: 32),
              Center(
                child: Text(
                  "Made with ❤️ in Flutter",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------ GlassCard ------------------------
  Widget _glassCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.18),
            Colors.white.withOpacity(0.06),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _divider() =>
      Divider(color: Colors.white.withOpacity(0.12), height: 1);

  // ------------------------ CHANGELOG SHEET ------------------------
  void _showChangelogDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AlertDialog(
            backgroundColor: Colors.black.withOpacity(0.55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            title: Text(
              l10n.versionHistory,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Text('''
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
''', style: const TextStyle(color: Colors.white70, height: 1.4)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'بستن',
                  style: TextStyle(color: Colors.lightBlueAccent, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
