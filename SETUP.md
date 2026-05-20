# 🚀 Guía de Configuración — Comidas App

## 1. Crear proyecto Supabase (5 minutos)

1. Ve a **https://supabase.com** → *Start your project*
2. Crea una cuenta (GitHub o email)
3. Click **New Project**:
   - **Name**: `comidas`
   - **Database Password**: elige una contraseña segura (guárdala)
   - **Region**: Europe West (o la más cercana a ti)
4. Espera ~2 minutos a que el proyecto arranque
5. Ve a **Settings → API** y copia:
   - `Project URL` → tu `SUPABASE_URL`
   - `anon public` key → tu `SUPABASE_ANON_KEY`

---

## 2. Crear la base de datos

1. En Supabase, ve a **SQL Editor** (icono de base de datos en el sidebar)
2. Click **New Query**
3. Copia y pega **todo** el contenido de `supabase/setup.sql`
4. Click **Run** (o `Ctrl+Enter`)
5. Deberías ver la tabla de verificación al final ✅

---

## 3. Configurar credenciales en la app Flutter

Edita `lib/main.dart` y reemplaza los valores por defecto:

```dart
await Supabase.initialize(
  url: 'https://TU-PROYECTO.supabase.co',       // ← tu URL
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6...',  // ← tu anon key
);
```

O mejor, usa variables de entorno (recomendado para producción):
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://TU-PROYECTO.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=TU_ANON_KEY
```

---

## 4. Build Android APK — GitHub Actions (GRATIS)

### Opción A: Build automático en cada push
1. Sube el proyecto a GitHub (o ya está subido)
2. Ve a **Settings → Secrets and Variables → Actions**
3. Añade dos secrets:
   - `SUPABASE_URL` = tu URL de Supabase
   - `SUPABASE_ANON_KEY` = tu anon key
4. Haz push a `main` o `claude/**`
5. Ve a **Actions** tab → el workflow `Android APK Build` arranca solo
6. Al terminar (~5-8 min), descarga el APK desde **Artifacts**

### Opción B: Build local
```bash
flutter pub get
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://TU-PROYECTO.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=TU_ANON_KEY
# APK en: build/app/outputs/flutter-apk/app-release.apk
```

---

## 5. Build iOS IPA — Codemagic (500 min/mes GRATIS)

### Requisitos
- Apple Developer Account ($99/año) — necesario para IPA firmado
- Sin developer account: puedes instalar en simulador, no en dispositivo real

### Pasos
1. Ve a **https://codemagic.io** → Sign up con GitHub
2. Click **Add application** → selecciona el repositorio `Comidas`
3. Elige **Flutter App**
4. En **Environment variables**, añade:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
5. Si tienes Apple Developer Account:
   - Ve a **Teams → Code signing identities**
   - Sube tu `.p12` y provisioning profile
6. Click **Start new build** → selecciona workflow `ios-release`
7. Al terminar (~15-20 min), descarga el `.ipa`

### Sin Apple Developer Account (para pruebas)
```bash
# En tu Mac con Xcode instalado:
flutter build ios --debug --simulator
open -a Simulator
flutter run
```

---

## 6. Estructura del proyecto

```
comidas/
├── lib/
│   ├── main.dart                    # Entry point + Supabase init
│   ├── core/theme/app_theme.dart    # Dark theme + colores
│   ├── models/                      # UserProfile, Meal, Workout, Shopping
│   ├── providers/                   # State management (Provider)
│   ├── data/                        # Mock data (meals, exercises)
│   ├── services/supabase_service.dart # Supabase CRUD
│   └── screens/
│       ├── onboarding/              # 4-step profile setup
│       ├── home/                    # Calorie ring, macro bars, carousels
│       ├── recipes/                 # Grid + detail
│       ├── workout/                 # Session tracker + history
│       ├── shopping/                # Auto-generated list
│       └── profile/                 # Stats + settings
├── supabase/
│   └── setup.sql                    # Schema completo + RLS + funciones
├── codemagic.yaml                   # iOS + Android CI/CD
└── .github/workflows/android-apk.yml  # GitHub Actions APK
```

---

## 7. Habilitar autenticación en Supabase (opcional)

La app funciona con datos locales por defecto. Para sincronización en la nube:

1. Supabase → **Authentication → Providers**
2. Activa **Email** (ya activo por defecto)
3. Opcionalmente activa **Google** o **Apple**
4. Implementa el login en la app añadiendo una pantalla de auth

---

## Variables de entorno para CI/CD

| Variable | Dónde configurar |
|---|---|
| `SUPABASE_URL` | GitHub Secrets / Codemagic env vars |
| `SUPABASE_ANON_KEY` | GitHub Secrets / Codemagic env vars |
| `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` | Codemagic (solo para Google Play) |
| `APP_STORE_CONNECT_PRIVATE_KEY` | Codemagic (solo para App Store) |
