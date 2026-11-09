# Master Guide: International Multi-Currency Payments & Production Setup

> **Document Version:** `v1.0.0 Enterprise Production Ready`  
> **Modules Covered:** Walkie-Talkie Subscriptions, Login OTP Verification Charges, Cross-Border Gateways  
> **Target Audience:** Backend Engineers, Flutter Frontend Developers, DevOps & Operations Team  
> **Status:** ✅ **Backend Setup 100% Complete & Production Ready**

---

## 1. Executive Summary & Readiness Confirmation

The backend international payment infrastructure across **FG-Tracker** is **100% implemented, verified, and production-ready**.

Both domestic Indian users (`+91` / `INR`) and international users (`countryCode !== '+91'` / `USD`) are seamlessly supported:

| Feature / Capability | Domestic India Flow (`+91`) | International Flow (`+54`, `+1`, `+44`, etc.) | Status |
|---|---|---|:---:|
| **Currency** | `INR` (`₹`) | `USD` (`$`) (or `EUR`, `GBP`, `AED`) | ✅ **Ready** |
| **Payment Gateway** | Razorpay (UPI, Netbanking, Cards) | Razorpay (PayPal, International Cards with 3DS2) | ✅ **Ready** |
| **Taxation (GST)** | **18% GST** (`WALKIE_GST_PERCENT = 18`) | **0% GST** (Zero-rated export under LUT RFD-11) | ✅ **Ready** |
| **Phone Format** | 10 digits or `+919876543210` | Full E.164 standard (e.g. `+5491112345678`, `+14155552671`) | ✅ **Ready** |
| **Gateway Amount** | Minor units (Paise) | Minor units (Cents) | ✅ **Ready** |
| **Walkie Plans** | ₹500 (1 mo), ₹750 (3 mo), ₹1,500 (12 mo) | $5.99 (1 mo), $9.99 (3 mo), $19.99 (12 mo) | ✅ **Ready** |
| **Login OTP Charge** | **Free** (0 INR) | **$0.50 USD** (0% GST) after first free login | ✅ **Ready** |

---

## 2. Frontend Implementation Guide (Flutter App Setup)

The Flutter application must adhere to the following 5 golden rules to ensure international payments work smoothly:

### Rule 1: Never Hardcode Currency (`₹` or `INR`)
- Read `currency` from the backend response (`data.currency` or `data.razorpay.currency` or `otpCharge.currency`).
- Map currency to symbol dynamically:
  ```dart
  String formatCurrency(num amount, String currency) {
    final cur = currency.toUpperCase().trim();
    switch (cur) {
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      case 'INR':
        return '₹${amount.toStringAsFixed(2)}';
      case 'EUR':
        return '€${amount.toStringAsFixed(2)}';
      case 'GBP':
        return '£${amount.toStringAsFixed(2)}';
      case 'AED':
        return 'AED ${amount.toStringAsFixed(2)}';
      default:
        return '$cur ${amount.toStringAsFixed(2)}';
    }
  }
  ```

### Rule 2: Amount is Already in Minor Units (Do NOT Multiply by 100)
- In create-order responses (`walkie/payment/create-order` and `v2/otp-charge/create-order`), the backend sends:
  - `data.razorpay.amount`: Integer minor units (e.g., `599` for $5.99 USD, or `50` for $0.50 USD).
  - Pass this directly into `Razorpay.open({'amount': data.razorpay.amount})`.
  - Only multiply by 100 if you fall back to `pricing.finalAmount` (which is in major units).

### Rule 3: Always Pass Backend Customer Details (E.164 Contact Format)
- Always pass `data.customer.contact` into `prefill.contact`.
- For international users, the backend sends the full E.164 format with country code (e.g. `+5491112345678` or `+14155552671`).
- Passing numbers without country codes causes international issuing banks to decline 3D Secure 2.0 transactions.

### Rule 4: Enable PayPal Automatically (No Custom Config Blocks for USD)
- Razorpay natively renders **PayPal** inside the standard checkout modal whenever `currency == 'USD'`.
- **Critical:** For international / USD orders, **do NOT pass any custom `config` blocks** or forced Indian UPI methods in the options map. Pass standard clean options so Razorpay displays cards and PayPal automatically.

### Rule 5: Tax Breakdown Display (0% GST for International)
- Check `gstPercent` from the backend:
  - If `gstPercent == 0`: Show `GST: $0.00` (or `"GST (Export 0%): $0.00"`), and `Total = Subtotal`.
  - If `gstPercent == 18`: Show `GST (18%): ₹90.00`.

---

### Complete Flutter Razorpay Integration Snippet

```dart
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentGatewayService {
  late Razorpay _razorpay;

  void init({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
    required Function(ExternalWalletResponse) onWallet,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onWallet);
  }

  void openCheckout({
    required String keyId,
    required String orderId,
    required int amountMinor,       // e.g. 599 for $5.99 USD, 50 for $0.50 USD
    required String currency,       // 'USD' or 'INR'
    required String? customerName,
    required String? customerEmail,
    required String? contactNumber, // Full E.164 with country code: +5491112345678
    required String description,
  }) {
    final isUsdOrInternational = currency.toUpperCase() != 'INR';

    final options = {
      'key': keyId,
      'order_id': orderId,
      'amount': amountMinor,
      'currency': currency.toUpperCase(),
      'name': 'FG MANPOWER LLP',
      'description': description,
      'timeout': 300,
      'prefill': {
        'name': customerName ?? '',
        'email': customerEmail ?? '',
        'contact': contactNumber ?? '',
      },
      'theme': {
        'color': '#007AFF',
      },
    };

    // For Indian orders, you may optionally prioritize UPI.
    // For International orders (USD), keep options clean so PayPal and Global Cards render!
    if (!isUsdOrInternational) {
      options['notes'] = {'payment_type': 'domestic_inr'};
    } else {
      options['notes'] = {'payment_type': 'international_usd'};
    }

    _razorpay.open(options);
  }

  void dispose() {
    _razorpay.clear();
  }
}
```

---

## 3. Production Deployment Checklist (Backend & Live Server Setup)

To take International Payments live on production, follow this step-by-step checklist:

### A. Live Razorpay Dashboard Configuration (1-Time Setup)
1. **Activate International Payments:**
   - Log in to your live Razorpay Dashboard (`dashboard.razorpay.com`).
   - Navigate to: **Settings -> Payment Methods -> International Payments**.
   - Ensure the toggle for **International Payments** is set to **Active**.
2. **Activate PayPal:**
   - Under the same International Payments section, verify **PayPal** is toggled to **Active**.
   - Note: PayPal displays automatically in the checkout sheet when orders are placed in `USD`.
3. **Configure Export Purpose Code (Mandatory for RBI & Cross-Border Compliance):**
   - Navigate to: **Settings -> International Payments -> Export Settings**.
   - Select RBI Export Purpose Code: **`P0802`** (*Software implementation, SaaS subscription licenses, and downloads*).
   - This ensures foreign inward remittances are cleared and Razorpay automatically generates monthly Foreign Inward Remittance Statements (FIRS / FIRC).
4. **Settlement Account:**
   - Settles in Indian Rupees (`INR`) into your Indian current bank account at live RBI-approved interbank exchange rates.

---

### B. Legal & Statutory GST Compliance (Form GST RFD-11 / LUT)
1. **File Letter of Undertaking (LUT):**
   - Digital software SaaS exported to users outside India is categorized as a **Zero-Rated Supply (0% GST)** under Section 16 of the Integrated Goods and Services Tax (IGST) Act, 2017.
   - File the annual **Letter of Undertaking (LUT)** on the official GST Portal (`services.gst.gov.in` -> *User Services -> Furnish Letter of Undertaking (Form GST RFD-11)*).
   - Filing is instant, online, and free. It provides the statutory legal umbrella to charge 0% GST to international customers.

---

### C. Production Environment Variables (`.env`)
Ensure your production `.env` file contains the following configurations:

```env
# =====================================================
# PAYMENT GATEWAY & RAZORPAY (LIVE KEYS)
# =====================================================
RAZORPAY_MODE=live
ACTIVE_PAYMENT_GATEWAY=razorpay
PAYMENT_ENABLED=true

RAZORPAY_LIVE_KEY_ID=rzp_live_xxxxxxxxxxxxxx
RAZORPAY_LIVE_KEY_SECRET=yyyyyyyyyyyyyyyyyyyyyyyy

# Module-wise inheritance (defaults to live)
RAZORPAY_WALKIE_MODE=live
RAZORPAY_OTP_CHARGE_MODE=live

# Webhook Secret (from Razorpay Dashboard -> Webhooks)
RAZORPAY_WEBHOOK_SECRET=your_production_webhook_secret

# =====================================================
# WALKIE-TALKIE MODULE TAXATION
# =====================================================
WALKIE_GST_PERCENT=18
WALKIE_INTERNATIONAL_GST_PERCENT=0

# =====================================================
# OTP CHARGES (INTERNATIONAL AUTH FLOW)
# =====================================================
OTP_CHARGES_ENABLED=true
OTP_CHARGE_CURRENCY=INR
OTP_CHARGE_INTERNATIONAL_CURRENCY=USD
OTP_CHARGE_DEFAULT_USD_PRICE=0.50
```

---

### D. Production Database Migrations
Run database migrations on the production server to ensure all required tables and columns exist:

```bash
# In the project directory on production server:
npm run db:migrate
```

Specific migrations executed:
1. `migrations/20261107200000-add-countrycode-to-users.js`:
   - Adds `countryCode` (`VARCHAR(10)`) column to the `users` table.
   - Automatically backfills all existing 10-digit Indian users with `+91`.
2. `migrations/20261108150000-seed-usd-walkie-plans.js`:
   - Seeds active USD Walkie-Talkie plans into `walkie_plans` ($5.99 / $9.99 / $19.99).

---

## 4. End-to-End Testing Verification Matrix

| Test Case | Test Input | Expected Currency | Expected Tax (GST) | Expected Checkout Options | Result |
|---|---|:---:|:---:|---|:---:|
| **1. Argentina Login OTP** | `+5491112345678` | **`USD`** | **0%** ($0.00) | Amount: `50` cents, Currency: `USD`. Opens PayPal + Cards. | ✅ **PASS** |
| **2. India Login OTP** | `+919876543210` | **`INR`** | **0%** (Free) | No charge screen. OTP sent immediately. | ✅ **PASS** |
| **3. Argentina Walkie Plans** | User `countryCode: "+54"` | **`USD`** | **0%** ($0.00) | Returns USD plans: $5.99, $9.99, $19.99. | ✅ **PASS** |
| **4. India Walkie Plans** | User `countryCode: "+91"` | **`INR`** | **18%** (₹90.00) | Returns INR plans: ₹500, ₹750, ₹1,500 + 18% GST. | ✅ **PASS** |
| **5. Order Summary (Intl)** | Plan ID 5 ($5.99 USD) | **`USD`** | **0%** ($0.00) | `subtotal: 5.99`, `gstAmount: 0.00`, `finalAmount: 5.99`. | ✅ **PASS** |
| **6. Create-Order Prefill** | International User | **`USD`** | — | `contact: "+5491112345678"`, `countryCode: "+54"`. | ✅ **PASS** |

