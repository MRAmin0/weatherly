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

  // ✅ FIX: گرفتن platform قبل از اولین await
  Future<void> _reportIssue(BuildContext context) async {
    final TargetPlatform platform = Theme.of(
      context,
    ).platform; // خواندن context

    // --- Collect App Version ---
    final package = await PackageInfo.fromPlatform();
    final appVersion = package.version;

    // --- Collect Device Info ---
    final deviceInfo = DeviceInfoPlugin();
    String deviceData = "Unknown";

    try {
      if (platform == TargetPlatform.android) {
        final android = await deviceInfo.androidInfo;
        deviceData =
            "Android (${android.model})\nAndroid Version: ${android.version.release}\nSDK: ${android.version.sdkInt}";
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

    final String body =
        """
Please describe the issue below:

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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // استایل متن سفید برای خوانایی روی گرادینت
    const whiteText = TextStyle(color: Colors.white);
    final whiteSubText = TextStyle(color: Colors.white.withValues(alpha: 0.7));

    return Scaffold(
      backgroundColor: Colors.transparent, // شفاف برای دیدن گرادینت اصلی
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          // --- Header Logo ---
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2), // شیشه‌ای
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.cloud_circle_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Description ---
          _buildGlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                l10n.appDescription,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- Info List ---
          _buildGlassCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline, color: Colors.white),
                  title: Text(l10n.appVersion, style: whiteText),
                  subtitle: FutureBuilder<String>(
                    future: _loadVersion(l10n),
                    builder: (context, snap) {
                      return Text(
                        snap.data ?? l10n.readingVersion,
                        style: whiteSubText,
                      );
                    },
                  ),
                ),
                Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.history_toggle_off_outlined,
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

          const SizedBox(height: 16),

          // --- Developer Info ---
          _buildGlassCard(
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
                Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.email_outlined,
                    color: Colors.white,
                  ),
                  title: Text(l10n.contactViaEmail, style: whiteText),
                  onTap: () => _sendEmail(developerEmail),
                ),
                Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
                ListTile(
                  leading: const Icon(Icons.code_outlined, color: Colors.white),
                  title: Text(l10n.projectOnGithub, style: whiteText),
                  onTap: () => _openUrl(githubProject),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --- Report Issue ---
          _buildGlassCard(
            child: ListTile(
              leading: const Icon(
                Icons.bug_report_outlined,
                color: Colors.orangeAccent,
              ),
              title: Text(l10n.reportAnIssue, style: whiteText),
              onTap: () => _reportIssue(context), // پاس دادن کانتکست
            ),
          ),

          const SizedBox(height: 32),
          Center(
            child: Text(
              "Made with ❤️ in Flutter",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ویجت کمکی برای ساخت کارت‌های شیشه‌ای
  Widget _buildGlassCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1), // پس‌زمینه شیشه‌ای
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  void _showChangelogDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // بلور پس‌زمینه
          child: AlertDialog(
            backgroundColor: Colors.black.withValues(alpha: 0.65), // شیشه‌ای
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            ),
            title: Text(
              l10n.versionHistory,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Text(
                '''
💎 نسخه 1.9.0 (جدید)
• بازطراحی کامل رابط کاربری با سبک شیشه‌ای (Glassmorphism)
• اضافه شدن پس‌زمینه گرادینت پویا بر اساس وضعیت هوا و شب/روز
• بهبود انیمیشن‌های صفحه اصلی (توربین بادی هوشمند، خورشید چرخان)
• قابلیت پین کردن و مدیریت لیست جستجوها
• بازطراحی صفحه تنظیمات و درباره ما

🌈 نسخه 1.8.0
• هماهنگی کامل رنگ‌های رابط با ColorScheme
• پشتیبانی کامل از Material Design 3

⭐ نسخه 1.7.0
• رفع باگ‌های جزئی و بهبود پایداری  

✨ نسخه 1.6.0
• اضافه شدن انیمیشن‌های جدید در صفحه اصلی  

🎨 نسخه 1.5.0
• طراحی جدید صفحه «درباره برنامه»  

🌈 نسخه 1.4.0
• بهبود نمایش آیکون‌های آب‌وهوا  

🛠 نسخه 1.3.0
• رفع مشکل عدم نمایش اطلاعات در برخی دستگاه‌ها  

🌍 نسخه 1.2.0
• اضافه شدن قابلیت ذخیره چند شهر مختلف  

🗣 نسخه 1.1.0
• بهبود ترجمه‌ها و اصلاح متن‌ها  

🚀 نسخه 1.0.0
• انتشار اولیه برنامه  
            ''',
                textAlign: TextAlign.start,
                style: const TextStyle(color: Colors.white70, height: 1.5),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'بستن',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
