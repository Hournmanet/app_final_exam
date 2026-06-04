# ITE Store

Flutter final exam e-commerce app with **4 environments** (flavors), product catalog from API, search, and shopping cart.

## Features

| Screen | Features |
|--------|----------|
| **Home** | Product list (Fake Store API), search by name, add to cart, cart badge count, open cart |
| **Cart** | Increase/decrease quantity, remove items, total price, checkout with success dialog, clear cart and return home |

## Environments

| Flavor | App name (launcher) | `APP_ENV` | Cart |
|--------|---------------------|-----------|------|
| `dev` | ITE Store Dev | `dev` | Enabled |
| `uat` | ITE Store Test | `uat` | Enabled |
| `demo` | ITE Store Demo | `demo` | **Disabled** (browse only) |
| `production` | ITE Store | `production` | Enabled |

## Run

From the `final_exam` folder:

```bash
flutter pub get

# Dev
flutter run --flavor dev --dart-define=APP_ENV=dev

# UAT
flutter run --flavor uat --dart-define=APP_ENV=uat

# Demo (no cart)
flutter run --flavor demo --dart-define=APP_ENV=demo

# Production
flutter run --flavor production --dart-define=APP_ENV=production
```

In VS Code / Cursor, use the launch configurations in `.vscode/launch.json`.

## Build APK

```bash
flutter build apk --flavor dev --dart-define=APP_ENV=dev
flutter build apk --flavor production --dart-define=APP_ENV=production
```

## API

Products: [https://fakestoreapi.com/products](https://fakestoreapi.com/products)

## Project structure

```
lib/
  config/       # Environment & theme
  models/       # Product, CartItem
  providers/    # Cart state (Provider)
  screens/      # Home, Cart
  services/     # API client
  widgets/      # Reusable UI
```
