# Education App - Full Stack Template

A complete template for an educational Flutter application with ASP.NET Core backend.

## Project Structure

```
My/
├── Backend/                    # ASP.NET Core Backend
│   ├── DigitalStore.Api/       # Web API Controllers
│   ├── DigitalStore.Application/ # Business Logic & Services
│   ├── DigitalStore.Domain/    # Domain Entities & Interfaces
│   ├── DigitalStore.Infrastructure/ # Data Access & JWT
│   └── DigitalStore.Database/  # SQL Scripts (Tables & Stored Procedures)
│
└── education_app/              # Flutter Frontend
    ├── lib/
    │   ├── core/               # Constants, Routes, Utils
    │   ├── features/           # Feature-based modules
    │   │   ├── auth/           # Authentication (Login, OTP)
    │   │   ├── home/           # Home & Grade Selection
    │   │   ├── settings/       # Theme, Language, Font Size
    │   │   └── profile/        # User Profile & Logout
    │   ├── shared/             # Network, Storage, Widgets, Theme
    │   └── injection_container.dart # Dependency Injection
    └── assets/
        ├── translations/       # i18n (en, fa)
        └── fonts/Vazir/        # Persian Font
```

## Features

### Backend (ASP.NET Core)
- ✅ Clean Architecture (Domain, Application, Infrastructure, API)
- ✅ JWT Authentication (Access & Refresh Tokens)
- ✅ SQL Server with Stored Procedures
- ✅ Swagger UI
- ✅ EF Core Integration

### Frontend (Flutter)
- ✅ Feature-based Clean Architecture
- ✅ BLoC State Management
- ✅ Dio for HTTP Requests
- ✅ SharedPreferences for Local Storage
- ✅ Get_It for Dependency Injection
- ✅ Multi-language Support (Persian & English)
- ✅ Theme Switching (Light & Dark)
- ✅ Bottom Navigation Bar

## Setup Instructions

### 1. Database Setup
1. Ensure SQL Server 2022 is running at `.\SQL2022`
2. Navigate to `Backend/DigitalStore.Database/`
3. Follow instructions in `README.md` to create database and run scripts

### 2. Backend Setup
```bash
cd Backend
dotnet restore
dotnet build
cd DigitalStore.Api
dotnet run
```
Backend will run on `http://localhost:5000`

### 3. Frontend Setup
```bash
cd education_app

# Install Vazir font files in assets/fonts/Vazir/
# Download from: https://github.com/rastikerdar/vazir-font

flutter pub get
flutter run
```

## API Endpoints

### Authentication
- `POST /api/Auth/send-otp` - Send OTP to phone number
- `POST /api/Auth/login` - Verify OTP and login
- `POST /api/Auth/refresh-token` - Refresh access token

### Products (Grades)
- `GET /api/Products?category={category}` - Get products by category

### Settings
- `GET /api/Settings/theme` - Get theme setting
- `POST /api/Settings/theme` - Update theme
- `GET /api/Settings/language` - Get language setting
- `POST /api/Settings/language` - Update language

## Technologies Used

### Backend
- ASP.NET Core 9.0
- Entity Framework Core
- SQL Server 2022
- JWT Bearer Authentication
- Swagger/OpenAPI

### Frontend
- Flutter 3.32.4
- Dart 3.8.1
- flutter_bloc ^8.1.6
- dio ^5.7.0
- get_it ^8.0.3
- shared_preferences ^2.3.4
- go_router ^14.6.2
- intl ^0.20.1

## Default Credentials
- OTP Code: `12345` (hardcoded for demo)

## Notes
- Backend runs on port 5000
- Frontend connects to `http://localhost:5000/api`
- Vazir font files must be added manually
- Database must be set up before running backend
