import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // اطلاعات سازنده
  final String developerName = "امین مناجاتی";
  final String developerEmail = "aminmonajati9@gmail.com";
  final String githubProject = "https://github.com/MRAmin0/Weatherly";
  final String githubProfile = "https://github.com/MRAmin0";

  // گرفتن نسخه برنامه
  Future<String> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return '—';
    }
  }

  // باز کردن لینک‌ها
  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // باز کردن اپ ایمیل
  Future<void> _sendEmail(String email) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
      query: "subject=بازخورد درباره Weatherly",
    );
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('درباره برنامه'), centerTitle: true),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // توضیحات برنامه
              const Text(
                'یک اپلیکیشن ساده و شیک برای مشاهده وضعیت آب‌وهوا و پیش‌بینی.\n'
                'منابع داده: OpenWeatherMap',
                textAlign: TextAlign.right,
              ),

              const SizedBox(height: 24),

              // نسخه برنامه
              FutureBuilder<String>(
                future: _loadVersion(),
                builder: (context, snap) {
                  final ver = snap.data;
                  return Text(
                    ver == null ? 'در حال خواندن نسخه…' : 'نسخه $ver',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  );
                },
              ),

              const SizedBox(height: 32),

              // عنوان سازنده
              const Text(
                "سازنده:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(developerName),

              const SizedBox(height: 24),

              const Text(
                "راه ارتباطی:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: () => _sendEmail(developerEmail),
                child: const Text(
                  "ایمیل",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // لینک‌ها
              const Text(
                "لینک‌ها:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              InkWell(
                onTap: () => _openUrl(githubProfile),
                child: const Text(
                  "پروفایل گیت‌هاب",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              InkWell(
                onTap: () => _openUrl(githubProject),
                child: const Text(
                  "مخزن Weatherly",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                ),
              ),

              const Spacer(),

              // دکمه گزارش مشکل (فعلاً خالی)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: اضافه کردن سیستم گزارش خطا
                  },
                  icon: const Icon(Icons.bug_report),
                  label: const Text("گزارش مشکل"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
