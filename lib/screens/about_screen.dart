import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  final String developerName = "امین مناجاتی";
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

  Future<void> _reportIssue() async {
    // --- Collect App Version ---
    final package = await PackageInfo.fromPlatform();
    final appVersion = package.version;

    // --- Collect Device Info ---
    final deviceInfo = DeviceInfoPlugin();
    String deviceData = "Unknown";

    try {
      if (Theme.of(_globalContext!).platform == TargetPlatform.android) {
        final android = await deviceInfo.androidInfo;
        deviceData =
            "Android (${android.model})\nAndroid Version: ${android.version.release}\nSDK: ${android.version.sdkInt}";
      } else if (Theme.of(_globalContext!).platform == TargetPlatform.iOS) {
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

  /// Global context (used for platform detection)
  static BuildContext? _globalContext;

  @override
  Widget build(BuildContext context) {
    _globalContext = context; // Store context for platform detection
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutApp), centerTitle: true),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
            child: Text(
              l10n.appDescription,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.appVersion),
            subtitle: FutureBuilder<String>(
              future: _loadVersion(l10n),
              builder: (context, snap) {
                return Text(snap.data ?? l10n.readingVersion);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history_toggle_off_outlined),
            title: Text(l10n.changelog),
            onTap: () => _showChangelogDialog(context, l10n),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.developer),
            subtitle: Text(developerName),
            onTap: () => _openUrl(githubProfile),
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: Text(l10n.contactViaEmail),
            onTap: () => _sendEmail(developerEmail),
          ),
          ListTile(
            leading: const Icon(Icons.code_outlined),
            title: Text(l10n.projectOnGithub),
            onTap: () => _openUrl(githubProject),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: Text(l10n.reportAnIssue),
            onTap: _reportIssue,
          ),
        ],
      ),
    );
  }

  void _showChangelogDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.versionHistory),
          content: const SingleChildScrollView(
            child: Text('''
⭐ نسخه 1.7.0
• رفع باگ‌های جزئی و بهبود پایداری  
• نمایش پیام مناسب هنگام ورود بدون اینترنت  

✨ نسخه 1.6.0
• اضافه شدن انیمیشن‌های جدید در صفحه اصلی  

🎨 نسخه 1.5.0
• طراحی جدید صفحه «درباره برنامه»  
• اضافه شدن بخش تاریخچه تغییرات  

🌈 نسخه 1.4.0
• بهبود نمایش آیکون‌های آب‌وهوا  
• افزایش سرعت بارگذاری اطلاعات  

🛠 نسخه 1.3.0
• رفع مشکل عدم نمایش اطلاعات در برخی دستگاه‌ها  

🌍 نسخه 1.2.0
• اضافه شدن قابلیت ذخیره چند شهر مختلف  

🗣 نسخه 1.1.0
• بهبود ترجمه‌ها و اصلاح متن‌ها  

🚀 نسخه 1.0.0
• انتشار اولیه برنامه  
• نمایش وضعیت فعلی آب‌وهوا  
• پیش‌بینی ۵ روزه  
            ''', textAlign: TextAlign.start),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }
}
