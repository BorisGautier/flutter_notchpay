# Welcome to the flutter_notchpay Wiki! 🚀

The official Flutter SDK for [NotchPay](https://notchpay.co) — Africa's unified payment gateway (Mobile Money, Cards, Bank Transfers).

***

## 📚 Quick Navigation

- 🚀 **[Getting Started](Getting-Started)** — Installation, initialization, and opening your first checkout sheet.
- 🎨 **[Theme Presets & Customization](Theme-Presets-&-Customization)** — Using pre-built themes (`darkMode`, `emerald`, `purple`, `ocean`) and customizing colors & borders.
- 🧪 **[Testing & Sandbox Guide](Testing-&-Sandbox-Guide)** — Test numbers for Mobile Money (Success, Insufficient Funds, Timeout), unit testing with mocks, and running live Sandbox integration tests.
- ⚡ **[API Reference & Backend Services](API-Reference-&-Backend-Services)** — Deep dive into all 10 API services (Payments, Customers, Identity, Payment Methods, Resources, Balance, Transfers, Recipients, Refunds, Sync).
- 🔒 **[Webhooks & Security](Webhooks-&-Security)** — Signature verification (HMAC-SHA256), public vs. secret key rules, and security best practices.

***

## ✨ Key Features

- 🌐 **Unified Mobile Money Checkout**: Native support for MTN, Orange, Moov, Wave, Airtel, Vodafone, M-Pesa, Free, Express Union, Glo, Tigo, and more across **18+ African countries**.
- 💳 **PCI-Compliant Card Payments**: Secure card payments via NotchPay's hosted payment sheet.
- 🎨 **Built-in Theme Presets**: Ready-to-use Light, Dark, Emerald, Purple, and Ocean design themes.
- 🔔 **Explicit Checkout Callbacks**: Handle `onSuccess`, `onCancelled`, and `onError` directly when launching the checkout sheet.
- 📱 **Smart Phone & Operator Detection**: Automatic phone number normalization and operator detection for Cameroon and other African countries.
- 🌍 **Built-in Localizations**: Automatic English and French translations based on device locale, with full custom string override support.
- 🔐 **Backend & Admin Operations**: Full Dart support for private key operations (Balance, Transfers, Recipients, Refunds, Sync sub-accounts).
