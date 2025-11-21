# Configuración de Android

Esta guía te ayudará a configurar y ejecutar la aplicación en Android.

## Requisitos Previos

1. **Flutter SDK instalado** (versión 3.24 o superior)
   - Verifica con: `flutter --version`

2. **Android Studio** o **Android SDK Command-line Tools**
   - Descarga Android Studio desde: https://developer.android.com/studio
   - O instala solo las herramientas de línea de comandos

3. **Configuración de Android SDK**
   - Abre Android Studio y ve a: `Tools` > `SDK Manager`
   - Instala el SDK Platform para Android API 34 (o superior)
   - Instala Android SDK Build-Tools
   - Acepta las licencias: `flutter doctor --android-licenses`

## Configuración Inicial

1. **Crear archivo local.properties**
   
   Flutter debería crear esto automáticamente, pero si necesitas crearlo manualmente:
   
   Crea el archivo `android/local.properties` con:
   ```
   sdk.dir=C\:\\Users\\TuUsuario\\AppData\\Local\\Android\\Sdk
   flutter.sdk=C\:\\ruta\\a\\flutter
   ```
   
   Ajusta las rutas según tu instalación.

2. **Verificar configuración**
   ```bash
   flutter doctor
   ```
   
   Deberías ver que Android toolchain está configurado correctamente.

## Ejecutar en Android

### Opción 1: Emulador Android

1. **Crear un emulador Android**
   - Abre Android Studio
   - Ve a `Tools` > `Device Manager`
   - Crea un nuevo dispositivo virtual (AVD)
   - Recomendado: Pixel 5 con Android 11 o superior

2. **Iniciar el emulador**
   - Desde Android Studio: Inicia el AVD
   - O desde la línea de comandos: `flutter emulators --launch <emulador_id>`

3. **Ejecutar la app**
   ```bash
   flutter run
   ```

### Opción 2: Dispositivo Físico

1. **Habilitar opciones de desarrollador**
   - Ve a `Configuración` > `Acerca del teléfono`
   - Toca `Número de compilación` 7 veces

2. **Habilitar depuración USB**
   - Ve a `Configuración` > `Opciones de desarrollador`
   - Activa `Depuración USB`

3. **Conectar el dispositivo**
   - Conecta tu dispositivo Android con un cable USB
   - Autoriza la depuración USB cuando aparezca el diálogo

4. **Verificar conexión**
   ```bash
   flutter devices
   ```
   
   Deberías ver tu dispositivo listado.

5. **Ejecutar la app**
   ```bash
   flutter run
   ```

## Compilar APK

### APK de Depuración
```bash
flutter build apk
```
El APK estará en: `build/app/outputs/flutter-apk/app-debug.apk`

### APK de Lanzamiento (sin firma)
```bash
flutter build apk --release
```
El APK estará en: `build/app/outputs/flutter-apk/app-release.apk`

### App Bundle para Google Play Store
```bash
flutter build appbundle --release
```
El bundle estará en: `build/app/outputs/bundle/release/app-release.aab`

## Configurar Iconos de la Aplicación

Para personalizar los iconos de la aplicación:

1. **Instalar flutter_launcher_icons** (opcional)
   ```bash
   flutter pub add dev:flutter_launcher_icons
   ```

2. **Configurar en pubspec.yaml**
   ```yaml
   flutter_launcher_icons:
     android: true
     image_path: "assets/icon/icon.png"
   ```

3. **Generar iconos**
   ```bash
   flutter pub run flutter_launcher_icons
   ```

O coloca manualmente los iconos en:
- `android/app/src/main/res/mipmap-*/ic_launcher.png`
- Varias resoluciones: mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi

## Solución de Problemas

### Error: "SDK location not found"
- Verifica que `android/local.properties` exista y tenga la ruta correcta del SDK

### Error: "Gradle build failed"
- Ejecuta: `cd android && ./gradlew clean`
- Luego: `flutter clean && flutter pub get`

### Error: "No devices found"
- Verifica que el dispositivo/emulador esté conectado: `adb devices`
- Reinicia el servidor ADB: `adb kill-server && adb start-server`

### Error de licencias de Android
```bash
flutter doctor --android-licenses
```
Acepta todas las licencias presionando `y`.

## Estructura de Archivos Android

```
android/
├── app/
│   ├── build.gradle          # Configuración del módulo app
│   └── src/main/
│       ├── AndroidManifest.xml    # Manifiesto de Android
│       ├── kotlin/.../MainActivity.kt  # Actividad principal
│       └── res/               # Recursos (iconos, strings, etc.)
├── build.gradle               # Configuración del proyecto raíz
├── settings.gradle            # Configuración de módulos
└── gradle.properties          # Propiedades de Gradle
```

## Características Implementadas

✅ Estructura completa de Android
✅ Configuración de Gradle moderna
✅ Soporte para Android API 21+
✅ MainActivity en Kotlin
✅ Permisos básicos (Internet)
✅ Configuración de temas Material
✅ Preparado para firma de aplicaciones

## Próximos Pasos

- [ ] Configurar firma de aplicación para releases
- [ ] Personalizar iconos de la aplicación
- [ ] Agregar splash screen personalizado
- [ ] Configurar notificaciones push (si es necesario)
- [ ] Optimizar para diferentes tamaños de pantalla

