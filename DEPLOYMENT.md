# راهنمای دیپلوی Weatherly برای وب

## تغییرات انجام شده برای بهینه‌سازی وب

### ✅ بهینه‌سازی‌های انجام شده:

1. **بهینه‌سازی `config_reader.dart`**
   - پشتیبانی از بارگذاری `keys.json` در وب
   - Fallback mechanism برای اطمینان از دسترسی به API key
   - مدیریت خطا بهتر

2. **بهینه‌سازی `web/index.html`**
   - افزودن meta tags کامل برای SEO
   - بهبود viewport settings برای responsive design
   - افزودن Open Graph و Twitter Card meta tags
   - Preconnect و DNS prefetch برای API calls
   - بهبود font loading با font-display: swap

3. **بهبود `web/manifest.json`**
   - تنظیمات بهتر برای PWA
   - پشتیبانی از orientation: any
   - افزودن categories و language settings

4. **بهینه‌سازی Geolocator**
   - افزودن timeout برای location requests
   - پیام‌های خطای بهتر برای وب
   - بررسی HTTPS برای location services

## مراحل دیپلوی

### 1. Build برای Web

```bash
flutter build web --release
```

### 2. بررسی فایل `keys.json`

اطمینان حاصل کنید که فایل `keys.json` در root پروژه موجود است و شامل API key شماست:

```json
{
  "openweathermap_api_key": "YOUR_API_KEY_HERE"
}
```

**نکته مهم:** این فایل به صورت خودکار در build web قرار می‌گیرد، اما برای امنیت بیشتر، می‌توانید از environment variables استفاده کنید.

### 3. دیپلوی

#### گزینه 1: Firebase Hosting

```bash
# نصب Firebase CLI (اگر نصب نشده)
npm install -g firebase-tools

# Login
firebase login

# Initialize (اگر قبلا انجام نشده)
firebase init hosting

# Deploy
firebase deploy --only hosting
```

#### گزینه 2: GitHub Pages

```bash
# Build
flutter build web --release --base-href "/YOUR_REPO_NAME/"

# کپی فایل‌ها به gh-pages branch
# یا استفاده از GitHub Actions
```

#### گزینه 3: Netlify

1. فولدر `build/web` را به Netlify drag & drop کنید
2. یا از Netlify CLI استفاده کنید:

```bash
netlify deploy --prod --dir=build/web
```

#### گزینه 4: Vercel

```bash
vercel --prod build/web
```

#### گزینه 5: سرور شخصی

فایل‌های موجود در `build/web` را به سرور وب خود آپلود کنید.

### 4. تنظیمات سرور

برای عملکرد بهتر، این header ها را در سرور تنظیم کنید:

```
Cache-Control: public, max-age=31536000, immutable
Content-Type: application/javascript
```

برای فایل‌های static (JS, CSS, images):
```
Cache-Control: public, max-age=31536000
```

### 5. بررسی HTTPS

**مهم:** برای استفاده از Geolocator در وب، حتما باید از HTTPS استفاده کنید. مرورگرها در HTTP اجازه دسترسی به location را نمی‌دهند.

### 6. تست

پس از دیپلوی، این موارد را بررسی کنید:

- ✅ بارگذاری صفحه
- ✅ دریافت اطلاعات آب و هوا
- ✅ استفاده از location (نیاز به HTTPS)
- ✅ PWA installation
- ✅ Responsive design در موبایل و دسکتاپ

## نکات امنیتی

1. **API Key:** در production، بهتر است API key را از طریق environment variables یا backend proxy مدیریت کنید.

2. **CORS:** اگر از API های خارجی استفاده می‌کنید، مطمئن شوید که CORS به درستی تنظیم شده است.

3. **HTTPS:** برای استفاده از location services، حتما HTTPS فعال باشد.

## بهینه‌سازی‌های بیشتر (اختیاری)

### Code Splitting
```bash
flutter build web --release --web-renderer canvaskit
```

### Tree Shaking
به صورت خودکار در build release انجام می‌شود.

### Service Worker
به صورت خودکار توسط Flutter ایجاد می‌شود و در `flutter_service_worker.js` قرار دارد.

## عیب‌یابی

### مشکل: API key پیدا نمی‌شود
- بررسی کنید که `keys.json` در root پروژه موجود است
- بررسی کنید که فایل در `pubspec.yaml` به عنوان asset تعریف شده است

### مشکل: Location کار نمی‌کند
- اطمینان حاصل کنید که از HTTPS استفاده می‌کنید
- بررسی کنید که کاربر permission داده است
- در console مرورگر خطاها را بررسی کنید

### مشکل: فونت‌ها لود نمی‌شوند
- بررسی کنید که فایل‌های فونت در `assets/fonts/` موجود هستند
- بررسی کنید که در `pubspec.yaml` تعریف شده‌اند

## پشتیبانی

برای سوالات و مشکلات، لطفا issue ایجاد کنید.

