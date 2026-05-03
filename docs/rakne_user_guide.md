# RAKNE — App Usage & Authentication Guide

> **Version:** 1.0 · **Audience:** New users · **Language:** English (Arabic version at [FILL: link])

---

## Introduction

**RAKNE** (راكنة) is a real-time parking-availability app for Amman, Jordan. It shows you live parking zone status on a map, lets you track your own parking sessions, and — if you choose to participate — allows you to contribute occupancy data by running the app in Camera Node Mode.

This guide walks you through creating an account, logging in, and using the app's core features.

---

## Prerequisites

Before you begin, make sure you have:

- An Android or iOS device running [FILL: minimum OS version]
- A **Jordanian mobile number** capable of receiving SMS messages
- The RAKNE app installed from [FILL: Google Play / App Store link]
- A stable internet connection for initial setup (the map requires connectivity)

---

## Sign-up (Step-by-step)

RAKNE uses a three-layer security model: **phone OTP → device PIN → optional biometrics**. You complete all three during first-time setup.

### Step 1 — Open the App

1. Launch **RAKNE** from your home screen.
2. On the welcome screen, tap **إنشاء حساب / Create Account**.

### Step 2 — Enter Your Mobile Number

| Field | Format | Example |
|---|---|---|
| Mobile number | Jordanian number, no country code | `079XXXXXXX` |

1. Type your mobile number in the field provided.
2. Tap **إرسال الرمز / Send Code**.
3. Wait up to **60 seconds** for an SMS containing a 6-digit one-time password (OTP).

### Step 3 — Enter the OTP

1. Type the 6-digit code from the SMS into the verification screen.
2. The code expires in **[FILL: X minutes]**. If it expires, tap **إعادة إرسال / Resend**.
3. A successful verification moves you automatically to the PIN setup screen.

### Step 4 — Set Your Device PIN

1. Choose a **4-digit PIN**. Avoid obvious sequences (e.g., 1234, 0000).
2. Re-enter the PIN to confirm.
3. This PIN is stored locally on your device and is required each time you open the app.

### Step 5 — Enable Biometrics *(Optional)*

1. If your device supports Face ID or fingerprint authentication, you will be prompted to enable it.
2. Tap **تفعيل / Enable** to use biometrics for faster login, or tap **تخطي / Skip** to use only your PIN.

### Step 6 — Choose Your Mode

On first launch after registration you will be asked to select a mode:

| Mode | Who it's for |
|---|---|
| **Citizen Mode** | Residents who want to find and track parking |
| **Camera Node Mode** | Volunteers or operators who supply live detection data |

Tap your preferred mode. You can switch modes later from the app settings.

### Step 7 — Account Created

You will land on the **Home Map** (Citizen Mode) or the **Camera Setup** screen (Camera Node Mode). Setup is complete.

---

## Sign-up Troubleshooting

| Problem | Likely cause | Fix |
|---|---|---|
| SMS not received after 60 s | Network delay or incorrect number | Check the number, tap **Resend**; wait another 60 s |
| OTP rejected | Code expired or mis-typed | Request a new OTP and enter it quickly |
| "Number already registered" error | Account exists under this number | Go to **Login** and use your existing PIN / biometrics |
| PIN confirmation mismatch | Typo on second entry | Re-enter both digits carefully |
| Biometric prompt fails | Device biometrics not configured in OS | Enable fingerprint/Face ID in device Settings, then retry |
| App freezes after OTP entry | Poor connection | Close and reopen the app; your number is saved, retry from Step 3 |

---

## Login (Step-by-step)

Once registered, login is faster because your phone number is already on file.

### Step 1 — Open the App

1. Launch **RAKNE**.
2. The app detects your registered device and goes directly to the **PIN / Biometrics** screen.

> **Tip:** If you are on a new device or reinstalled the app, you will be prompted to re-verify your phone number via OTP (follow Steps 2–3 of Sign-up above).

### Step 2 — Authenticate

**Option A — PIN**
1. Enter your 4-digit PIN.
2. Tap **تأكيد / Confirm**.

**Option B — Biometrics** *(if enabled)*
1. When the biometric prompt appears, use Face ID or your fingerprint.
2. On success you are taken directly to the Home Map.

> Three consecutive incorrect PIN entries will [FILL: lock the account for X minutes / trigger re-verification — confirm with app behaviour].

### Step 3 — You're In

The app opens on the **Home Map** in whichever mode you last used.

---

## Login Troubleshooting

| Problem | Likely cause | Fix |
|---|---|---|
| PIN not accepted | Forgotten PIN or mistype | Tap **نسيت الرمز / Forgot PIN** and re-verify via OTP to reset |
| Biometric prompt not appearing | Biometrics disabled after OS update | Go to **Settings → Security → Biometrics** and re-enrol |
| "Session expired" message | Long period of inactivity | Log in again with PIN or biometrics |
| Locked out after failed PINs | Too many incorrect attempts | Wait [FILL: X minutes] or tap **Forgot PIN** to reset via SMS |
| App won't open / crashes on launch | Outdated app version | Update RAKNE from the app store and relaunch |

---

## Using the App — Core Flows

### Citizen Mode

#### Viewing the Live Parking Map

1. Open the app. The **Home Map** displays Amman with colour-coded zone pins:
   - **Green** — spots available now
   - **Red** — zone fully occupied
   - **Amber** — AI predicts availability soon based on historical patterns
2. Pinch to zoom; drag to pan.
3. Tap any pin to open the **Zone Detail View**.

#### Zone Detail View

The detail panel shows:
- Street address and zone name
- Current capacity count (free / total spots)
- **Busy-hours chart** — hourly occupancy for today
- **AI Prediction Strip** — forecast for the next [FILL: X minutes / hours]

Tap the map background to dismiss the panel.

#### Starting a Parking Session

1. When you park, tap **بدء جلسة / Start Session** on the relevant zone pin or from the **Sessions** tab.
2. Confirm the zone. The timer begins.
3. When you leave, tap **إنهاء الجلسة / End Session**.
4. The session is saved to your **History** tab.

#### Session History

- Navigate to **History** (bottom navigation bar).
- Each entry shows date, zone, duration, and [FILL: any cost/point data if applicable].

---

### Camera Node Mode

> **Who should use this mode?** Volunteers or government operators who mount their device in a parking area to supply live detection data.

1. Mount your device with a clear view of the parking spots you are covering.
2. Open RAKNE and select **Camera Node Mode** from the mode switcher.
3. Tap **بدء الرصد / Start Monitoring**.
4. The on-device AI model begins classifying spots as free or occupied — no video is uploaded; only aggregated status data is sent to the server.
5. Tap **إيقاف / Stop** when you are done. The session ends and data is finalised.

> **Privacy note:** The camera feed never leaves your device. Only anonymised occupancy counts are transmitted.

---

## Tips

- **Best map performance:** Use Wi-Fi or 4G; the map refreshes approximately every 200 ms.
- **Battery saving:** Camera Node Mode uses the camera continuously — connect to a charger for long monitoring sessions.
- **Language:** The app is Arabic-first. To switch to English, go to **Settings → Language → English**.
- **Biometrics:** Re-enable after every major OS update if the prompt stops appearing.
- **Session accuracy:** Start your session immediately on parking and end it as soon as you leave to keep historical data accurate for all users.

---

## FAQ

**Q: Can I use RAKNE without a Jordanian number?**
A: Not currently. Phone OTP verification requires a Jordanian mobile number. [FILL: update if international numbers are added.]

**Q: Is my camera footage stored or shared?**
A: No. The TFLite model runs fully on-device. Only anonymised spot status (free/occupied count) is sent to the server.

**Q: What does the amber pin mean exactly?**
A: Amber indicates that the AI prediction layer — based on historical occupancy patterns for that zone — forecasts a spot will open soon. It is not a guarantee.

**Q: Can I switch between Citizen Mode and Camera Node Mode?**
A: Yes. Go to **Settings → Mode** and select the mode you want.

**Q: What happens if I lose my phone?**
A: Your account is tied to your phone number, not the device. Install RAKNE on a new device, complete OTP verification, and set a new PIN. [FILL: confirm whether old device sessions are invalidated automatically.]

**Q: Is there a fee to use RAKNE?**
A: [FILL: free / subscription / government-funded — confirm.]

---

## Appendix

### Supported Devices

| Platform | Minimum version |
|---|---|
| Android | [FILL: Android X.X] |
| iOS | [FILL: iOS X.X] |

### Data & Privacy

- Authentication: Supabase phone OTP + device-local PIN + optional biometrics
- Occupancy data: aggregated and anonymised; no PII transmitted from camera
- Full privacy policy: [FILL: link]

### Contact & Support

- In-app: **Settings → Help & Support**
- Email: [FILL: support email]
- Government portal: [FILL: link if applicable]

---

*Document maintained by the RAKNE team. Last updated: [FILL: date].*
