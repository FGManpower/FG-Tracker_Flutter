> **Superseded** — use [docs/packages/02_backend_requirements.md](packages/02_backend_requirements.md). Kept for history only.

# Package Pricing API (for backend) — old draft

The app's **Packages & Pricing** screen (side menu → Packages & Pricing) shows one card per module and opens a pricing details screen for the chosen module. All prices, tiers, durations and features come from these endpoints — nothing is hard-coded in the app.

Base URL: `ConstRes.aBaseUrl` (`http://fgtracker.in:3000/api/`). All calls send `Authorization: Bearer <token>`.

Module keys the app knows: `attendance`, `walkie_talkie`, `safe_zone_route`, `live_tracking`. New keys still render with a default icon.

> **Walkie-Talkie** keeps its existing flow (`walkie/plans` → order summary → payment). It only needs a card in `GET packages`; the app opens the existing Walkie plan screen when it is tapped.

---

## 1. `GET packages`

List shown on the first screen. Return them in display order (or use `sortOrder`). Leave out modules you don't want shown; send `isAvailable: false` for "Coming soon".

```json
{
  "status": true,
  "message": "Packages fetched",
  "data": {
    "packages": [
      {
        "id": 1,
        "moduleKey": "attendance",
        "title": "Attendance",
        "tagline": "Selfie + location check-ins for your whole team",
        "iconUrl": null,
        "themeColor": "#16A34A",
        "startingPrice": 49,
        "currency": "INR",
        "priceUnit": "/ member / month",
        "badge": "Popular",
        "isAvailable": true,
        "isSubscribed": false,
        "activeUntil": null,
        "highlights": ["Face check-in", "Geo-fenced", "Reports"],
        "sortOrder": 1
      }
    ]
  }
}
```

| Field | Type | Required | Notes |
|---|---|---|---|
| moduleKey | string | yes | One of the keys above |
| title | string | yes | |
| tagline | string | no | 1–2 lines under the title |
| iconUrl | string | no | If empty the app uses its built-in icon |
| themeColor | string | no | Hex accent colour; app has defaults per module |
| startingPrice | number | no | Lowest per-member price; if null the card says "View plans" |
| currency | string | no | Default `INR` |
| priceUnit | string | no | Text after the price |
| badge | string | no | Small label next to the title |
| isAvailable | bool | no | Default `true`. `false` = "Coming soon", not tappable |
| isSubscribed | bool | no | For the logged-in user. Shows a green "Active" pill |
| activeUntil | string | no | `yyyy-MM-dd` or ISO date |
| highlights | string[] | no | Up to 3 shown |
| sortOrder | int | no | Ascending |

---

## 2. `GET packages/{moduleKey}/plans`

Everything the details screen needs for one module.

```json
{
  "status": true,
  "message": "Plans fetched",
  "data": {
    "moduleKey": "attendance",
    "title": "Attendance",
    "description": "Members mark attendance with a selfie and live location.",
    "currency": "INR",
    "gstPercent": 18,
    "priceIncludesGst": false,
    "features": ["Selfie + face check-in", "Location captured with every check-in"],
    "termsNote": "Plans renew manually.",
    "tiers": [
      {
        "id": 12,
        "code": "pro",
        "name": "Pro",
        "description": "For growing teams that need reports",
        "badge": "Best value",
        "isRecommended": true,
        "minMembers": 5,
        "maxMembers": 200,
        "features": [
          { "title": "Excel / PDF reports", "subtitle": null, "included": true },
          { "title": "Priority support", "included": false }
        ],
        "durations": [
          { "planId": 111, "billingInterval": "monthly",   "durationMonths": 1,  "pricePerMember": 89 },
          { "planId": 112, "billingInterval": "quarterly", "durationMonths": 3,  "pricePerMember": 240, "mrpPerMember": 267 },
          { "planId": 113, "billingInterval": "yearly",    "durationMonths": 12, "pricePerMember": 854, "mrpPerMember": 1068, "savingsPercent": 20, "isRecommended": true }
        ]
      }
    ]
  }
}
```

**Module level**

| Field | Type | Notes |
|---|---|---|
| gstPercent | number | `0` hides GST |
| priceIncludesGst | bool | Default `true`. `false` = app adds a GST row on top |
| features | string[] or object[] | Shown above the tier's own features |
| termsNote | string | Small print under the price summary |

**Tier** — one tab on the screen (Basic / Pro, or Individual / Team). The tab bar is hidden when there is only one tier.

| Field | Type | Notes |
|---|---|---|
| name | string | Tab label |
| minMembers / maxMembers | int | `maxMembers: 1` hides the member picker (individual plan) |
| isRecommended | bool | Selected by default |
| features | string[] or `{title, subtitle?, included}`[] | `included: false` shows as not included |
| durations | array | A tier with no durations is not shown |

**Duration** — one purchasable plan row.

| Field | Type | Notes |
|---|---|---|
| planId | int | **Required.** Sent to create-order |
| billingInterval | string | `monthly` / `quarterly` / `half_yearly` / `yearly` |
| durationMonths | int | Used for labels and per-month price |
| pricePerMember | number | Price per member **for the whole duration** (not per month) |
| mrpPerMember | number | Optional strike-through price |
| savingsPercent | number | Optional; otherwise worked out from MRP or the monthly plan |
| label | string | Optional; overrides "Monthly" / "Quarterly" / "Yearly" |
| isRecommended | bool | Selected by default |

App total = `pricePerMember × members` (+ GST when `priceIncludesGst` is `false`). This is for display only — **the backend must recalculate the amount** in create-order.

---

## 3. `POST packages/payment/create-order`

Request:

```json
{ "planId": 113, "members": 12 }
```

Validate that `members` is within the tier's min/max. Create the Razorpay order and a pending payment row. Same response shape as `walkie/payment/create-order`:

```json
{
  "status": true,
  "message": "Order created",
  "data": {
    "payment":  { "id": 5521, "orderId": "PKG_1730533200", "status": "created" },
    "razorpay": { "keyId": "rzp_live_xxx", "orderId": "order_Pq1xyz", "amount": 1209264, "currency": "INR" }
  }
}
```

`razorpay.amount` is in **paise** and is what the user is charged.

## 4. `POST packages/payment/verify`

Called after Razorpay success. Must be idempotent (the app retries up to 3 times).

```json
{
  "paymentId": 5521,
  "razorpayOrderId": "order_Pq1xyz",
  "razorpayPaymentId": "pay_Pq1abc",
  "razorpaySignature": "…"
}
```

Response:

```json
{
  "status": true,
  "message": "Your Attendance plan is now active.",
  "data": { "subscription": { "id": 901, "activeUntil": "2027-11-02" } }
}
```

After this, `GET packages` should return `isSubscribed: true` and `activeUntil` for that module. Please also activate the plan from the Razorpay webhook in case verify never reaches the server.

## 5. `POST packages/payment/failed`

Called when the user cancels or payment fails. Response body is ignored.

```json
{ "paymentId": 5521, "razorpayOrderId": "order_Pq1xyz", "failureReason": "Payment cancelled" }
```

---

## Errors

Use the same format as the rest of the API: `{"status": false, "message": "…"}`. The app shows `message` to the user.

## App switch

Until these endpoints are live, debug builds show sample data. In `lib/app/Data/Repositories/package_pricing_repo.dart` set `_useMockInDebug = false` to call the real API. Release builds always call the real API.
