# 🚀 Serendib Guide - Launch Checklist

**Use this checklist to track your progress toward launch.**

---

## 📋 Pre-Launch Checklist

### Phase 1: Content & Assets ⚠️ **CRITICAL PATH**

#### Attraction Content
- [ ] Expand attractions.json to 100+ free attractions
- [ ] Add 200+ premium attractions (total 300+)
- [ ] Add Sinhala (description_si) for all attractions
- [ ] Add Tamil (description_ta) for all attractions
- [ ] Verify all coordinates are accurate
- [ ] Check all entry fees are current
- [ ] Confirm opening hours for each attraction
- [ ] Review and proofread all descriptions
- [ ] Ensure proper tagging for search/filters
- [ ] Set is_premium flag correctly (100 free, 200+ premium)

#### Attraction Images
- [ ] Collect 4 high-quality images per attraction
- [ ] Total: 1,200 images (300 attractions × 4)
- [ ] Resize all images (max 1200px width)
- [ ] Compress images (85% quality, ~200KB each)
- [ ] Name correctly: `attractionname_1.jpg`, etc.
- [ ] Verify copyright/licensing for all images
- [ ] Place in `assets/images/attractions/`

#### App Branding
- [ ] Design app icon (512x512 PNG)
- [ ] Create adaptive icon foreground
- [ ] Design splash screen
- [ ] Create Android 12 splash variant
- [ ] Test icon at small sizes (48x48)
- [ ] Place in `assets/images/logo/`
- [ ] Run `flutter pub run flutter_launcher_icons`
- [ ] Run `flutter pub run flutter_native_splash:create`

**Estimated Time**: 100-150 hours

---

### Phase 2: Configuration ⚙️

#### Database Setup
- [ ] Review attractions.json completeness
- [ ] Run `dart run scripts/populate_database.dart`
- [ ] Verify database: `sqlite3 assets/database/attractions.db`
- [ ] Check free/premium split is correct
- [ ] Test queries on populated database
- [ ] Verify image filenames match database

#### Localization
- [ ] Review all ARB files for accuracy
- [ ] Run `flutter gen-l10n`
- [ ] Uncomment AppLocalizations.delegate in main.dart
- [ ] Test all three languages in app
- [ ] Fix any missing translations

#### Android Signing
- [ ] Generate release keystore: `keytool -genkey ...`
- [ ] Store keystore in secure location
- [ ] Create `android/key.properties`
- [ ] Update `android/app/build.gradle` with signing config
- [ ] Test release build: `flutter build apk --release`
- [ ] Verify signature: `keytool -printcert -jarfile ...`
- [ ] **BACKUP KEYSTORE SECURELY!**

**Estimated Time**: 8-12 hours

---

### Phase 3: Monetization 💰

#### Google AdMob
- [ ] Create AdMob account
- [ ] Add Serendib Guide app to AdMob
- [ ] Create Banner Ad Unit
- [ ] Create Interstitial Ad Unit
- [ ] Copy production ad unit IDs
- [ ] Replace TEST IDs in `lib/utils/constants.dart:52-56`
- [ ] Update `AndroidManifest.xml` with AdMob App ID
- [ ] Test ads in release build
- [ ] Verify ad impression tracking

#### Google Play In-App Purchase
- [ ] Create app in Google Play Console
- [ ] Setup merchant account
- [ ] Complete tax information
- [ ] Create product: `premium_unlock` ($14.99)
- [ ] Set price for all regions
- [ ] Activate product
- [ ] Test purchase flow in internal testing
- [ ] Verify premium features unlock correctly
- [ ] Test "Restore Purchases" functionality

**Estimated Time**: 4-6 hours

---

### Phase 4: Testing 🧪

#### Functional Testing
- [ ] Test all 37 screens load without errors
- [ ] Verify category filtering works
- [ ] Verify province filtering works
- [ ] Test search functionality
- [ ] Test favorites add/remove
- [ ] Test trip creation/edit/delete
- [ ] Verify free tier limits (20 favorites, 3 trips)
- [ ] Test premium unlock flow
- [ ] Verify premium features unlock after purchase
- [ ] Test all three languages
- [ ] Test dark mode
- [ ] Test offline functionality
- [ ] Verify maps display correctly
- [ ] Test all free API integrations (weather, currency, etc.)

#### Device Testing
- [ ] Test on Android 5.0 (API 21) - minimum supported
- [ ] Test on Android 8.0 (API 26) - common
- [ ] Test on Android 11 (API 30) - common
- [ ] Test on Android 14 (API 34) - latest
- [ ] Test on low-end device (2GB RAM)
- [ ] Test on mid-range device (4GB RAM)
- [ ] Test on high-end device (8GB+ RAM)
- [ ] Test on different screen sizes (small, normal, large)

#### Performance Testing
- [ ] Check app startup time (<3 seconds)
- [ ] Verify smooth scrolling (60 FPS)
- [ ] Test with 100+ attractions loaded
- [ ] Check memory usage (<200MB)
- [ ] Verify no memory leaks
- [ ] Test battery consumption
- [ ] Check APK/AAB size (<120MB)

#### Automated Testing
- [ ] Run unit tests: `flutter test`
- [ ] All tests pass
- [ ] Run `flutter analyze` with no errors
- [ ] Fix all warnings (optional but recommended)

**Estimated Time**: 20-30 hours

---

### Phase 5: Play Store Setup 📱

#### App Listing
- [ ] Upload app icon (512x512)
- [ ] Create feature graphic (1024x500)
- [ ] Write short description (80 chars, 3 languages)
- [ ] Write full description (4000 chars, 3 languages)
- [ ] Take 8 screenshots (1080x1920)
- [ ] Add screenshot captions
- [ ] Optional: Create promo video
- [ ] Select category: Travel & Local
- [ ] Add tags: travel, tourism, sri lanka, offline maps, travel guide

#### Legal & Privacy
- [ ] Write privacy policy
- [ ] Host privacy policy at www.serendibguide.com/privacy
- [ ] Write terms of service
- [ ] Host terms at www.serendibguide.com/terms
- [ ] Complete content rating questionnaire
- [ ] Review rating (should be "Everyone")
- [ ] Add privacy policy URL to Play Console
- [ ] Add developer email: support@serendibguide.com
- [ ] Add support website URL

#### Store Configuration
- [ ] Set app title: "Serendib Guide"
- [ ] Set package name: `com.serendibguide.srilanka`
- [ ] Set version: 1.0.0+1
- [ ] Select countries (All or specific)
- [ ] Set pricing: Free with in-app purchases
- [ ] Add in-app purchase: Premium Unlock ($14.99)
- [ ] Configure app access (all features available)
- [ ] Add data safety information
- [ ] Review app permissions

**Estimated Time**: 8-12 hours

---

### Phase 6: Internal Testing 🧑‍💻

#### Build & Upload
- [ ] Build release AAB: `flutter build appbundle --release`
- [ ] Upload to Internal Testing track
- [ ] Add internal testers (5-10 people)
- [ ] Share internal testing link
- [ ] Monitor crash reports
- [ ] Check for ANRs (Application Not Responding)
- [ ] Review tester feedback
- [ ] Fix critical bugs
- [ ] Upload new build if needed

#### Metrics to Monitor
- [ ] Crash-free rate >99%
- [ ] ANR rate <0.5%
- [ ] Average session duration
- [ ] Screen flow (identify drop-offs)
- [ ] Purchase conversion rate
- [ ] Ad impression rate (free users)

**Duration**: 1-2 weeks
**Estimated Time**: 10-20 hours (+ waiting period)

---

### Phase 7: Closed Testing (Optional) 🧑‍🤝‍🧑

#### Expand Testing
- [ ] Create closed testing track
- [ ] Add 50-100 testers
- [ ] Target Sri Lankan community groups
- [ ] Gather detailed feedback
- [ ] Analyze usage patterns
- [ ] Identify most popular attractions
- [ ] Fix remaining bugs
- [ ] Polish UI/UX based on feedback
- [ ] Optimize performance

**Duration**: 2-4 weeks (optional)
**Estimated Time**: 20-40 hours

---

### Phase 8: Production Launch 🎉

#### Final Checks
- [ ] All critical bugs fixed
- [ ] Crash-free rate >99.5%
- [ ] All store assets finalized
- [ ] Privacy policy live
- [ ] Support email active
- [ ] Review Play Store listing one last time
- [ ] Prepare launch announcement
- [ ] Setup social media accounts (optional)

#### Launch
- [ ] Submit for production review
- [ ] Wait for approval (1-7 days)
- [ ] Once approved, publish to production
- [ ] Announce launch on social media
- [ ] Email testers to thank them
- [ ] Monitor reviews closely
- [ ] Respond to user feedback
- [ ] Fix critical issues immediately

#### Post-Launch (First 48 Hours)
- [ ] Monitor crash reports every 6 hours
- [ ] Respond to all reviews (especially negative)
- [ ] Track download numbers
- [ ] Check ad impressions
- [ ] Monitor purchase conversions
- [ ] Gather user feedback
- [ ] Plan first update based on feedback

**Estimated Time**: 2-4 hours (+ review waiting period)

---

## 📊 Progress Tracker

### Overall Completion

- [ ] Phase 1: Content & Assets (0%)
- [ ] Phase 2: Configuration (40%)
- [ ] Phase 3: Monetization (0%)
- [ ] Phase 4: Testing (30%)
- [ ] Phase 5: Play Store Setup (0%)
- [ ] Phase 6: Internal Testing (0%)
- [ ] Phase 7: Closed Testing (0%)
- [ ] Phase 8: Production Launch (0%)

**Overall: 10% Ready for Launch**

---

## ⏱️ Time Estimates

### Minimum (MVP with 50 attractions)
- Content Creation: 40 hours
- Assets & Config: 20 hours
- Testing: 15 hours
- Play Store: 8 hours
- **Total: ~85 hours (2-3 weeks full-time, 6-8 weeks part-time)**

### Full Version (300+ attractions)
- Content Creation: 120 hours
- Assets & Config: 25 hours
- Testing: 30 hours
- Play Store: 12 hours
- Internal Testing: 20 hours
- **Total: ~207 hours (5-6 weeks full-time, 12-16 weeks part-time)**

---

## 🎯 Launch Strategy Recommendations

### Strategy 1: MVP Launch (Fastest)
✅ **Recommended for getting to market quickly**

- Launch with 50 quality attractions
- Focus on most popular tourist destinations
- Get user feedback early
- Iterate based on real usage data
- Add more attractions in updates (v1.1, v1.2, etc.)

**Timeline**: 6-8 weeks part-time

---

### Strategy 2: Full Featured Launch
⏰ **More time investment, more polished**

- Launch with 300+ attractions
- Complete content before launch
- More thorough testing
- Better initial reviews
- Less need for immediate updates

**Timeline**: 12-16 weeks part-time

---

### Strategy 3: Soft Launch (Recommended)
🌟 **Best of both worlds**

- Launch with 100 attractions (free tier)
- Add premium attractions gradually
- Soft launch in Sri Lanka only
- Gather feedback from local users
- Expand to international markets after polish
- Use early revenue to fund content creation

**Timeline**: 8-10 weeks part-time

---

## 📞 Support Contacts

### Critical Issues
- Flutter issues: [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- Play Console: [Google Support](https://support.google.com/googleplay/android-developer)
- AdMob: [AdMob Help](https://support.google.com/admob)

### Community
- [Flutter Discord](https://discord.gg/flutter)
- [r/FlutterDev](https://reddit.com/r/FlutterDev)
- [Flutter Awesome](https://flutterawesome.com/)

---

## 🎉 Ready to Launch?

When you've checked all boxes in Phases 1-8, you're ready to go live!

**Remember**:
- Start small, iterate fast
- Listen to user feedback
- Fix critical bugs immediately
- Keep adding value with updates
- Marketing is as important as development

**Good luck with your launch! 🚀🇱🇰**

---

**Last Updated**: 2025-11-26
**Next Review**: Before Phase 6 (Internal Testing)
