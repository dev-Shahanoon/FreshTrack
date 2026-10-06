# FreshTrack

### Smart Food Inventory & Expiry Tracking App

FreshTrack is a Flutter-based food inventory management application designed to help users track stored food, monitor expiry dates, reduce food waste, and discover recipe ideas from available ingredients.

The application combines **Flutter, Firebase, food scanning, expiry monitoring, notifications, analytics, and Google Gemini AI** into one practical food-management solution.

---

## ✨ Features

### 📦 Food Inventory
- Add and manage food items
- Edit existing food details
- View the complete food inventory
- Track food status based on expiry dates
- Organize food information in one place

### ⏳ Expiry Tracking
- Automatically monitor food expiry dates
- Identify fresh, expiring, and expired items
- Dedicated food-status screen
- Expiry checking service for background status management

### 🔔 Expiry Alerts
- Notification system for important food-expiry events
- Helps users consume food before it goes to waste
- Dedicated alerts screen

### 📷 Food Scanning
- Scan food/product information
- Product service for retrieving product details
- Dedicated scanning and scanner screens
- Faster food entry compared with completely manual input

### 🤖 AI-Powered Recipe Assistance
- Generate recipe ideas using available food ingredients
- Gemini-powered recipe functionality
- Recipe database and recipe service
- Dedicated recipe screen

### 📊 Analytics
- Visualize food inventory information
- Monitor food status and inventory trends
- Dedicated analytics screen

### 👤 User Authentication
- User registration
- User login
- User profile
- Firebase-based authentication

### 🔥 Firebase Integration
- Firebase Authentication
- Cloud Firestore
- User-specific food data
- Firebase configuration for application services

---

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| Flutter | Cross-platform application development |
| Dart | Application programming language |
| Firebase Authentication | User authentication |
| Cloud Firestore | Cloud database |
| Google Gemini AI | AI-powered recipe assistance |
| Local Notifications | Expiry alerts |
| Barcode / Product Scanning | Food and product identification |
| Material UI | Application interface |

---

## 🏗️ Project Architecture

FreshTrack follows a structured Flutter architecture separating screens, models, and services.

```text
lib/
│
├── models/
│   └── recipe_model.dart
│
├── screens/
│   ├── add_food_screen.dart
│   ├── alerts_screen.dart
│   ├── analytics_screen.dart
│   ├── edit_food_screen.dart
│   ├── food_status_screen.dart
│   ├── home_screen.dart
│   ├── inventory_screen.dart
│   ├── login_screen.dart
│   ├── profile_screen.dart
│   ├── recipe_screen.dart
│   ├── scan_screen.dart
│   ├── scanner_screen.dart
│   ├── signup_screen.dart
│   └── splash_screen.dart
│
├── services/
│   ├── expiry_checker.dart
│   ├── firestore_service.dart
│   ├── gemini_service.dart
│   ├── notification_service.dart
│   ├── product_service.dart
│   ├── recipe_database.dart
│   └── recipe_service.dart
│
├── firebase_options.dart
└── main.dart
