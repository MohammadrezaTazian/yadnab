# Yadnab

A full-stack educational platform with a Flutter mobile app, ASP.NET Core backend, and a Next.js landing page.

## Project Structure

```
yadnab/
├── Backend/                        # ASP.NET Core Backend
│   ├── DigitalStore.Api/           # Web API Controllers & Configuration
│   ├── DigitalStore.Application/   # Business Logic & Services
│   ├── DigitalStore.Domain/        # Domain Entities & Interfaces
│   ├── DigitalStore.Infrastructure/# Data Access, Repositories & JWT
│   └── DigitalStore.Database/      # SQL Scripts (MainScript.sql)
│
├── education_app/                  # Flutter Frontend
│   ├── lib/
│   │   ├── core/                   # Config, Constants, Routes, Services, Utils
│   │   ├── features/
│   │   │   ├── auth/               # Authentication (Login, OTP)
│   │   │   ├── comment/            # Comments & Replies
│   │   │   ├── course_topics/      # Course Topics & Syllabus
│   │   │   ├── education/          # Educational Content (Text, Video, Math)
│   │   │   ├── home/               # Home & Grade Selection
│   │   │   ├── profile/            # User Profile & Profile Picture
│   │   │   ├── quiz/               # Quizzes & Questions
│   │   │   ├── settings/           # Theme, Language, Font Size
│   │   │   └── upload/             # Image Upload & Content Management
│   │   ├── shared/                 # Network, Storage, Widgets, Theme
│   │   ├── l10n/                   # Localization (en, fa) - ARB files
│   │   └── injection_container.dart# Dependency Injection (GetIt)
│   └── assets/
│       ├── config.json             # Runtime configuration (API base URL)
│       └── fonts/Vazir/            # Persian Font
│
└── landing-page/                   # Next.js Landing Page
    ├── src/
    │   ├── app/[locale]/           # Locale-based routing (fa, en)
    │   ├── fonts/                  # Vazirmatn font
    │   ├── i18n.ts                 # i18n configuration
    │   └── middleware.ts           # Locale middleware
    ├── messages/                   # Translation files (en.json, fa.json)
    └── public/                     # Static assets
```

## Architecture

> **All business logic resides in the database layer.**

This project follows a **Database-First** architecture:

- **Database (`MainScript.sql`)** — All business logic, validation, and business rules are implemented as Stored Procedures in this single file.
- **Backend (ASP.NET Core)** — A thin layer that only transports data between the database and the client. No business logic exists in this layer.
- **Frontend (Flutter / Next.js)** — Purely a presentation layer. No logic is implemented on the UI side.

To modify or add any business logic, only edit `Backend/DigitalStore.Database/MainScript.sql`.

## Features

### Backend (ASP.NET Core)
- ✅ Clean Architecture (Domain, Application, Infrastructure, API)
- ✅ JWT Authentication (Access & Refresh Tokens)
- ✅ SQL Server with Stored Procedures
- ✅ Swagger UI (Development mode)
- ✅ EF Core Integration
- ✅ CORS Support (AllowAll policy)
- ✅ Static File Serving (with SVG support)
- ✅ Grade Seeder (initial data)
- ✅ Content Management (search & image upload)
- ✅ Comments & Likes System

### Frontend (Flutter)
- ✅ Feature-based Clean Architecture
- ✅ BLoC State Management
- ✅ Dio for HTTP Requests
- ✅ SharedPreferences for Local Storage
- ✅ Get_It for Dependency Injection
- ✅ Multi-language Support (Persian & English) via ARB files
- ✅ Theme Switching (Light & Dark)
- ✅ Adjustable Font Size
- ✅ Bottom Navigation Bar
- ✅ OTP Authentication with Pinput
- ✅ Course Topics & Syllabus Browser
- ✅ Educational Content Viewer
- ✅ Math Formula Rendering (flutter_math_fork)
- ✅ Quiz & Questions System
- ✅ Comments & Likes
- ✅ Image Upload & Content Management
- ✅ User Profile with Profile Picture
- ✅ Runtime Config Service (`assets/config.json`)

### Landing Page (Next.js)
- ✅ Next.js 16 with App Router
- ✅ Multi-language Support (Persian & English) via next-intl
- ✅ RTL/LTR Support
- ✅ TailwindCSS v4 Styling
- ✅ SEO Optimized (OpenGraph, alternates)
- ✅ Static Export for Production
- ✅ Responsive Design
- ✅ Vazirmatn Persian Font (local)

## Setup Instructions

### 1. Database Setup
1. Ensure SQL Server 2022 is running at `.\SQL2022`
2. Create a database named `YadnabDB`
3. Navigate to `Backend/DigitalStore.Database/`
4. Run `MainScript.sql` to create tables and stored procedures

### 2. Backend Setup
```bash
cd Backend
dotnet restore
dotnet build
cd DigitalStore.Api
dotnet run
```
Backend will run on `http://localhost:5100`

Swagger UI is available at `http://localhost:5100/swagger` (Development mode only)

### 3. Frontend Setup
```bash
cd education_app

# Install Vazir font files in assets/fonts/Vazir/
# Download from: https://github.com/rastikerdar/vazir-font

flutter pub get
flutter run
```

> **Note:** The API base URL is configured in `assets/config.json`. Update it if the backend runs on a different address.

### 4. Landing Page Setup
```bash
cd landing-page
npm install
npm run dev
```
Landing page will run on `http://localhost:3000`

For production build (static export):
```bash
npm run build
```

## API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/Auth/send-otp` | Send OTP to phone number |
| `POST` | `/api/Auth/login` | Verify OTP and login |
| `POST` | `/api/Auth/refresh-token` | Refresh access token |

### User
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| `GET` | `/api/User/profile` | Get user profile | ✅ |
| `PUT` | `/api/User/profile` | Update user profile | ✅ |
| `GET` | `/api/User/grades` | Get available grades | ✅ |
| `POST` | `/api/User/profile-picture` | Update profile picture (Base64) | ✅ |

### Products (Grades)
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| `GET` | `/api/Products?category={category}` | Get products by category | ✅ |

### Course Topics
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| `GET` | `/api/CourseTopics/{category}` | Get topics by category | ✅ |

### Education Contents
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| `GET` | `/api/EducationContents/topic/{topicItemId}` | Get contents by topic | ✅ |
| `GET` | `/api/EducationContents/{id}` | Get content by ID | ✅ |

### Questions (Quiz)
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| `GET` | `/api/Questions/topic/{topicItemId}` | Get questions by topic | ✅ |
| `GET` | `/api/Questions/{id}` | Get question by ID | ✅ |

### Comments
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| `GET` | `/api/Comments/{targetType}/{targetId}` | Get comments for a target | ❌ |
| `POST` | `/api/Comments` | Add a comment | ✅ |
| `DELETE` | `/api/Comments/{id}` | Delete a comment | ✅ |

### Likes
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| `POST` | `/api/Likes/toggle` | Toggle like on a target | ✅ |

### Content Management
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| `GET` | `/api/ContentManagement/search?entityTypeId={id}&searchText={text}` | Search entities | ✅ |
| `POST` | `/api/ContentManagement/upload` | Upload image (multipart/form-data) | ✅ |

### Settings
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| `GET` | `/api/Settings` | Get all user settings | ✅ |
| `GET` | `/api/Settings/theme` | Get theme setting | ✅ |
| `POST` | `/api/Settings/theme` | Update theme | ✅ |
| `GET` | `/api/Settings/language` | Get language setting | ✅ |
| `POST` | `/api/Settings/language` | Update language | ✅ |
| `GET` | `/api/Settings/fontsize` | Get font size setting | ✅ |
| `POST` | `/api/Settings/fontsize` | Update font size | ✅ |

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
- equatable ^2.0.7
- dio ^5.7.0
- dartz ^0.10.1
- get_it ^8.0.3
- shared_preferences ^2.3.4
- go_router ^14.6.2
- intl ^0.20.1
- provider ^6.1.2
- flutter_svg ^2.0.16
- pinput ^5.0.0
- image_picker ^1.1.2
- flutter_math_fork ^0.7.4

### Landing Page
- Next.js 16.0.10
- React 19.2.1
- TypeScript ^5
- TailwindCSS v4
- next-intl ^4.6.0

## Default Credentials
- OTP Code: `12345` (hardcoded for demo)

## Notes
- Backend runs on port `5100`
- Frontend connects to `http://localhost:5100/api` (configurable via `assets/config.json`)
- Landing page runs on port `3000`
- Vazir font files must be added manually to `education_app/assets/fonts/Vazir/`
- Database (`YadnabDB`) must be set up before running backend
- Swagger UI is only available in Development environment
