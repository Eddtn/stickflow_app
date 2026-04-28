# stockflow

> A cross-platform mobile inventory management app built for small and medium businesses — replacing paper-based stock tracking with a real-time, role-based mobile solution.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat&logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?style=flat&logo=firebase)
![Riverpod](https://img.shields.io/badge/State-Riverpod_2.0-0553B1?style=flat)
![License](https://img.shields.io/badge/License-MIT-green?style=flat)

---

## Problem

Most small warehouses, retail shops, and manufacturers in Nigeria track inventory on paper or basic Excel spreadsheets. This leads to stockouts, overstocking, zero team visibility, and wasted time reconciling records manually.

**StockFlow solves this** by giving businesses a mobile-first inventory system their whole team can use in real time.

---

## Screenshots

> Coming soon — demo video link will be added here

---

## Features

- 📊 **Live Dashboard** — real-time stock stats, inventory value, low stock alerts, and bar charts
- 📦 **Product Management** — add/edit/delete products with barcode scanning and photo upload
- 🔄 **Stock Movements** — record stock in/out with reasons, full audit trail, atomic transactions
- 📈 **Reports** — pie charts, 7-day line charts, PDF and CSV export with date range filter
- 👥 **Role-based Access** — admin and staff roles with different permissions
- 🔔 **Push Notifications** — automatic alerts when stock falls below threshold
- 🔐 **Authentication** — Firebase Auth with email/password and password reset

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter + Dart |
| State Management | Riverpod 2.0 |
| Navigation | GoRouter |
| Backend | Firebase (Auth + Firestore + Storage) |
| Charts | FL Chart |
| Export | pdf + csv + share_plus |
| Barcode Scanner | mobile_scanner |
| Notifications | flutter_local_notifications |

---

## Architecture

```
lib/
├── core/               # Constants, theme, utility functions
├── models/             # UserModel, ProductModel, TransactionModel
├── services/           # AuthService, ProductService, ReportService, NotificationService
├── providers/          # Riverpod providers (auth, products, transactions, search)
├── screens/
│   ├── auth/           # Splash, Login
│   ├── dashboard/      # Dashboard with charts and alerts
│   ├── products/       # Product list, detail, add/edit
│   ├── transactions/   # Stock in/out, movement history
│   ├── reports/        # Charts and export
│   └── settings/       # Profile, user management
├── widgets/            # Reusable UI components
├── router.dart         # GoRouter with auth redirect guard
└── main.dart           # Firebase init + ProviderScope
```

**Key design decisions:**
- Firestore **transactions** (atomic writes) ensure stock quantity and movement log never get out of sync
- Riverpod **StreamProviders** keep the UI reactive to live Firestore changes
- Role-based routing enforced at both the UI layer and Firestore security rules level
- Transactions are **immutable** — once written, they cannot be updated or deleted (full audit trail)

---

## Getting Started

### Prerequisites
- Flutter SDK 3.x
- Firebase account
- Android Studio or VS Code

### 1. Clone the repo

```bash
git clone https://github.com/Eddtn/stockflow.git
cd stockflow
flutter pub get
```

### 2. Firebase setup

1. Create a project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Authentication** → Email/Password
3. Enable **Firestore Database**
4. Enable **Firebase Storage**
5. Download `google-services.json` → place in `android/app/`
6. Download `GoogleService-Info.plist` → place in `ios/Runner/`

### 3. Apply Firestore security rules

Copy the contents of `firestore.rules` into your Firestore console under the **Rules** tab.

### 4. Create your first admin user

In Firebase console → Authentication → Add user manually, then add their document to Firestore:

```
Collection: users
Document ID: <user_uid>

{
  "uid": "<user_uid>",
  "name": "Your Name",
  "email": "admin@company.com",
  "role": "admin",
  "createdAt": <timestamp>,
  "isActive": true
}
```

### 5. Run the app

```bash
flutter run
```

---

## Firestore Data Model

```
users/
  {uid}
    name, email, role (admin|staff), isActive

products/
  {productId}
    name, sku, category, quantity, lowStockThreshold, unitPrice, imageUrl, createdBy, updatedAt

transactions/
  {txId}
    productId, productName, type (in|out), quantity, reason,
    performedBy, performedByName, timestamp, prevQty, newQty, note
```

---

## Business Impact

This app targets small businesses that currently manage stock manually. Key value propositions:

- Eliminates stockout surprises with real-time low stock notifications
- Gives managers full audit trail of every stock movement and who made it
- Enables remote visibility — managers can check stock from anywhere
- Reduces reconciliation time from hours to seconds with PDF/CSV export

---

## Roadmap

- [ ] Multi-location/warehouse support
- [ ] Supplier management module
- [ ] Purchase order generation
- [ ] Barcode label printing
- [ ] WhatsApp notification integration
- [ ] Offline mode with sync

---

## Author

**Eddieton** — Industrial Engineer + Flutter Developer  
[GitHub](https://github.com/Eddtn) · [LinkedIn](#) · [Email](#)

---

## License

MIT — feel free to use this as a reference or starting point for your own projects.
"# stickflow_app" 
