# Hotel & Travel Booking App

# Flutter is a comprehensive app for booking hotels, flights, and travel packages, with support for both Arabic and English.


# Flutter ## Features

- ✅ Login and Registration
- ✅ Search for Hotels, Flights, and Packages
- ✅ View Hotel and Room Details
- ✅ Make Reservations
- ✅ Manage Reservations (View, Cancel)
- ✅ Mock Payment System
- ✅ Arabic and English Language Support
- ✅ Local Data (Mock Data)

## Architecture

```
lib/
├── core/ # Common Cores (Enums, Constants, Helpers)
├── models/ # Data Models
├── services/ # Business Logic
├── storage/ # Local Data Management
├── state/ # State Management (Provider)
├── ui/ # User Interfaces
│ ├── screens/ # Screens
│ └── components/ # Common Components
├── localization/ # Translation
├── theme/ # Design
└── config/ # Settings

```

## Installation and Operation

1. Install Packages:
```bash
flutter pub get
```

2. Run the Application:
```bash
flutter run
```

## Test Data

The application uses local data (Mock Data) located in:
- `assets/data/users.json` - Users
- `assets/data/hotels.json` - Hotels
- `assets/data/rooms.json` - Rooms
- `assets/data/flights.json` - Flights
- `assets/data/packages.json` - Packages

## Test Users

- Email: `ahmed@example.com`

- Email: `fatima@example.com`

(No passwords - any password can be used) (Passage)

## Packages Used

- `provider` - State Management
- `shared_preferences` - Local Storage
- `intl` - Translation and Formatting
- `flutter_localizations` - Language Support

## Notes

- All data is local and does not require an internet connection.
- Mock Payment System
- Suitable for demonstrations and prototypes

## معاينة التطبيق

يمكنك مشاهدة عرض سريع للتطبيق هنا (ضع ملف الفيديو في المسار المشار إليه أدناه):

<video controls width="640" height="360">
	<source src="assets/videos/booking_app_showcase.mp4" type="video/mp4">
	متصفحك لا يدعم مشغل الفيديو. يمكنك تحميل الفيديو من هذا الرابط: <a href="assets/videos/booking_app_showcase.mp4">عرض الفيديو</a>
</video>

تعليمات: ضع ملف الفيديو باسم `booking_app_showcase.mp4` داخل المجلد `assets/videos/` في المستودع. على GitHub قد لا يعمل العرض المباشر في كل الحالات — إذا لم يظهر الفيديو، استخدم الرابط لتحميله أو قم برفعه إلى منصة مشاركة فيديو واستبدل المسار.

## Future Development

- Connect to a Real Database
- Connect to Real Payment Gateways
- Add User Ratings
- Notification System
- Multi-Currency Support