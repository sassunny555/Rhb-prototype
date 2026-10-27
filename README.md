# Banking home screen — Flutter FYP prototype

A local academic prototype matching the supplied 738 × 1600 home-screen reference.

## Run

```sh
flutter pub get
flutter run -d chrome
```

Android/iOS: launch an emulator or connect a device and run `flutter run`.

## Implementation

- Responsive layout based on a 393-point reference width; centered at up to 520 points on desktop.
- Logo, side navigation artwork and favourites illustration come from the supplied reference. All four supplied promotion images appear in the horizontal carousel.
- Blue gradient, decorative stars, crescent and the circular QR/Services button are painted in Flutter.
- Balance visibility toggles. Header, account, favourites, promotion and navigation buttons open local demonstration panels.
- Screens use the phone’s real system status bar; hard-coded clocks, signal/battery indicators and decorative gesture bars have been removed.
- Promotion artwork uses the four supplied full images. The original font would be required for an exact typography match.
- No real authentication, account access or payment processing.

## Verify

```sh
flutter analyze
flutter test
flutter build web
```

## QR → OCR → demo receipt

Scan a payment QR. A checksum-valid EMV-style payment payload is parsed for the name (59) and optional MYR amount (54/53). Explicitly marked `fyp-payment` JSON demo QRs are also supported. Account details are never inferred from opaque merchant identifiers.

If the QR has no usable name, the full camera frame is processed locally: Tesseract.js in the browser, ML Kit on Android/iOS. Keep the printed name and its “Scan this QR to transfer to” / recipient label visible. OCR candidates require user review; unrecognized names can be entered manually. OCR is a heuristic, not recipient verification.

Browser OCR downloads pinned Tesseract.js code and language/model assets on first use and needs network access for those downloads. Camera images are processed in the browser, not sent to an AI API. Browser image import remains unavailable; camera OCR is supported. Native gallery QR scans also use the selected image for OCR fallback. iOS minimum deployment target is 15.5 for ML Kit.

On Payment Details, the tappable amount always starts at 00.00. Review the recipient, enter a positive amount, tap Next and approve on the full Review screen to generate/share a receipt prominently marked DEMO / NO MONEY TRANSFERRED. No real balance is debited. The Receive tab generates a `Demo Recipient` QR useful for testing between two devices.

Physical camera and OCR recognition quality must be checked on the intended device. Tests cover QR parsing/checksum rejection, labelled OCR text extraction, amount validation, required confirmation and demo receipt values; they do not emulate camera hardware or OCR engines.

## Transactions

Completed simulated payments are stored in local preferences, sorted newest first and grouped by MYT date. Status close/system back opens Transactions. Tapping a row reopens the saved receipt with its original timestamp/reference without recording another payment. Home → Accounts also opens Transactions. All/Receipts currently contain the same completed QR payments because these are the only recorded transaction type. Six default sample history rows from the supplied reference are appended below completed payments. Swipe any row left to delete it. Completed payment removals and hidden sample row IDs are saved locally so deletions survive refresh. They are display fixtures and do not create stored receipts. Clearing browser/app storage removes this history.

Each completed payment now has a derived green + MYR entry immediately above its red debit, for demonstrating incoming/outgoing activity. The derived receipt swaps sender and recipient and uses a -REV reference suffix. Default samples are not duplicated. Swiping away a credit hides only that derived entry; deleting its original debit removes the pair. These display examples do not adjust the account balance.

## GitHub Pages

The Pages workflow builds Flutter web and uploads `build/web`, with the repository base path set automatically. In repository Settings → Pages, the publishing source must be **GitHub Actions**, rather than serving the source branch with Jekyll. Pushes to `main` redeploy the app.
