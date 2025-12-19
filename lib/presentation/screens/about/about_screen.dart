import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';
import 'package:weatherly_app/presentation/widgets/home/weather_background_wrapper.dart';
import 'package:weatherly_app/presentation/widgets/common/glass_container.dart';
import 'package:weatherly_app/data/models/weather_type.dart';

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
    final uri = Uri(
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

    final uri = Uri(
      scheme: 'mailto',
      path: developerEmail,
      query: Uri.encodeFull("subject=Weatherly Issue Report&body=$body"),
    );

    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<WeatherViewModel>();
    final l10n = AppLocalizations.of(context)!;

    final weatherType = vm.currentWeather?.weatherType ?? WeatherType.unknown;

    return WeatherBackgroundWrapper(
      weatherType: weatherType,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            l10n.aboutApp,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.black.withValues(alpha: 0.1),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 16),

            Center(
              child: GlassContainer(
                isDark: true,
                borderRadius: 100,
                padding: const EdgeInsets.all(24),
                child: const Icon(
                  Icons.cloud_circle_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 24),

            GlassContainer(
              isDark: true,
              margin: const EdgeInsets.only(bottom: 12),
              child: Text(
                l10n.appDescription,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  height: 1.4,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 20),

            GlassContainer(
              isDark: true,
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                    ),
                    title: Text(
                      l10n.appVersion,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: FutureBuilder<String>(
                      future: _loadVersion(l10n),
                      builder: (context, snap) {
                        return Text(
                          snap.data ?? l10n.readingVersion,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        );
                      },
                    ),
                  ),
                  _divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.history_outlined,
                      color: Colors.white,
                    ),
                    title: Text(
                      l10n.changelog,
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    onTap: () => _showChangelogDialog(context, l10n, theme),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            GlassContainer(
              isDark: true,
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                    ),
                    title: Text(
                      l10n.developer,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      l10n.developerName,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    onTap: () => _openUrl(githubProfile),
                  ),
                  _divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.email_outlined,
                      color: Colors.white,
                    ),
                    title: Text(
                      l10n.contactViaEmail,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () => _sendEmail(developerEmail),
                  ),
                  _divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.code_outlined,
                      color: Colors.white,
                    ),
                    title: Text(
                      l10n.projectOnGithub,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () => _openUrl(githubProject),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            GlassContainer(
              isDark: true,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(
                  Icons.bug_report_outlined,
                  color: Colors.orangeAccent,
                ),
                title: Text(
                  l10n.reportAnIssue,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () => _reportIssue(context),
              ),
            ),

            const SizedBox(height: 28),
            Center(
              child: Text(
                "Made with ❤️ in Flutter",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, color: Colors.white.withValues(alpha: 0.16));
  }

  void _showChangelogDialog(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) {
        final dialog = AlertDialog(
          backgroundColor: Colors.black.withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.20)),
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
🔔 نسخه 2.0.0 (آخرین نسخه)
• نوتیفیکیشن هوشمند آب‌وهوا
• هشدار صبحگاهی با ساعت دلخواه
• دکمه تست نوتیفیکیشن
• رفع باگ خطای اتصال

💎 نسخه 1.9.0
• بازطراحی کامل رابط کاربری
• پس‌زمینه دینامیک
• انیمیشن‌های جدید

🌈 نسخه 1.8.0
• ارتقا به Material 3

⭐ نسخه 1.7.0
• رفع باگ‌ها و بهبود پایداری
''',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
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
                  color: theme.colorScheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );

        if (kIsWeb) return dialog;

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: dialog,
        );
      },
    );
  }
}
