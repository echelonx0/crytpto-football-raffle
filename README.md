# Football Raffle Flutter App - Setup Guide

## Prerequisites
- Flutter SDK 3.0+
- Firebase project configured
- Lisk Sepolia testnet access

## Step 1: Install Dependencies

```bash
flutter pub get
```

## Step 2: Firebase Setup

1. Create Firebase project at https://console.firebase.google.com
2. Add Android/iOS apps
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Place in respective folders:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

## Step 3: Enable Firebase Services

In Firebase Console:
- ✅ Authentication → Enable Email/Password
- ✅ Firestore Database → Create database
- ✅ Cloud Functions → Deploy functions (see functions/ folder)

## Step 4: Update Configuration

### lib/shared/constants/app_constants.dart
```dart
static const String transakApiKey = 'YOUR_TRANSAK_API_KEY';
```

Get Transak API key: https://transak.com/

### lib/core/utils/encryption_helper.dart
```dart
const deviceSecret = 'YOUR_SECURE_RANDOM_KEY';
```

Generate with: `openssl rand -base64 32`

## Step 5: Android Configuration

### android/app/build.gradle
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

### android/app/src/main/AndroidManifest.xml
Add internet permission:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## Step 6: iOS Configuration

### ios/Podfile
Uncomment:
```ruby
platform :ios, '15.0'
```

### ios/Runner/Info.plist
Add camera permission (for QR scanner):
```xml
<key>NSCameraUsageDescription</key>
<string>Scan QR codes to receive crypto</string>
```

## Step 7: Deploy Firebase Functions

```bash
cd functions
npm install
npm run build
firebase deploy --only functions
```

## Step 8: Run App

```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

## Step 9: Test Flow

1. **Sign Up** → Auto-creates wallet
2. **View Wallet** → Copy address
3. **Fund Wallet** → Send test USDT to address
4. **Browse Raffles** → See active raffles
5. **Join Raffle** → Place bet
6. **Wait** → Transaction confirms
7. **Win!** → Receive prize

## Troubleshooting

### "No wallet found"
- Check Firebase Authentication is enabled
- Verify user is signed in
- Check Firestore permissions

### "Transaction failed"
- Ensure sufficient ETH for gas
- Check USDT balance
- Verify network (Lisk Sepolia)

### "Firebase not initialized"
- Verify google-services.json/plist exists
- Run `flutterfire configure`

### "Function not found"
- Redeploy Firebase Functions
- Check function names match

## Production Checklist

- [ ] Replace Transak API key
- [ ] Update encryption keys
- [ ] Configure proper Firestore rules
- [ ] Enable Firebase App Check
- [ ] Add rate limiting
- [ ] Implement biometric auth
- [ ] Add crash reporting (Sentry/Crashlytics)
- [ ] Test on real devices
- [ ] Security audit
- [ ] Terms of service

## Next Steps

- Add push notifications (Firebase Messaging)
- Implement referral system
- Add transaction history UI
- Create admin dashboard
- Integrate analytics
- Build leaderboard

## Support

For issues, check:
- Firebase Console logs
- Flutter console output
- Blockchain explorer: https://sepolia-blockscout.lisk.com