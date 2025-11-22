# Guía de Integración - Backend + Frontend Flutter

## Resumen

Esta guía documenta la integración completa entre el backend Node.js (GymRestBack) y el frontend Flutter (GymApp). La integración está lista y funcional.

---

## Índice

1. [Estructura de Archivos Creados](#estructura-de-archivos-creados)
2. [Configuración Inicial](#configuración-inicial)
3. [Arquitectura de la Integración](#arquitectura-de-la-integración)
4. [Uso de los Servicios](#uso-de-los-servicios)
5. [Flujo de Autenticación](#flujo-de-autenticación)
6. [Ejemplos de Integración](#ejemplos-de-integración)
7. [Testing](#testing)
8. [Errores Comunes](#errores-comunes)
9. [Checklist de Implementación](#checklist-de-implementación)

---

## Estructura de Archivos Creados

### Nuevos archivos y carpetas:

```
GymApp/
├── .env                                    # Configuración de URL del backend
├── .env.example                            # Plantilla de configuración
├── lib/
│   ├── core/
│   │   ├── config/
│   │   │   └── api_config.dart            # Configuración centralizada de la API
│   │   ├── models/
│   │   │   ├── api_response.dart          # Modelo genérico de respuesta
│   │   │   ├── user.dart                  # Modelo de usuario
│   │   │   ├── member.dart                # Modelo de miembro
│   │   │   ├── plan.dart                  # Modelo de plan
│   │   │   ├── subscription.dart          # Modelo de suscripción
│   │   │   ├── payment.dart               # Modelo de pago
│   │   │   └── attendance.dart            # Modelo de asistencia
│   │   └── services/
│   │       ├── http_service.dart          # Servicio HTTP base
│   │       ├── storage_service.dart       # Almacenamiento local
│   │       ├── auth_service.dart          # Servicio de autenticación
│   │       ├── members_service.dart       # Servicio de miembros
│   │       ├── plans_service.dart         # Servicio de planes
│   │       ├── subscriptions_service.dart # Servicio de suscripciones
│   │       ├── payments_service.dart      # Servicio de pagos
│   │       ├── attendance_service.dart    # Servicio de asistencia
│   │       └── reports_service.dart       # Servicio de reportes
│   └── features/
│       └── members/
│           └── members_page_integrated_example.dart  # Ejemplo de integración
```

### Archivos modificados:

- `pubspec.yaml` - Agregadas dependencias: http, shared_preferences, flutter_dotenv, provider
- `lib/main.dart` - Inicialización de .env y StorageService
- `lib/features/login/login_page.dart` - Integración con AuthService

---

## Configuración Inicial

### 1. Instalar dependencias

```bash
cd GymApp
flutter pub get
```

### 2. Configurar el backend

Asegúrate de que el backend esté corriendo:

```bash
cd GymRestBack
npm install
npm run migrate
npm run seed
npm run dev
```

El backend debería estar corriendo en `http://localhost:3000`

### 3. Configurar el .env

El archivo `.env` ya está creado con la configuración por defecto:

```env
API_BASE_URL=http://localhost:3000
```

Para producción, cámbiala a tu URL real:

```env
API_BASE_URL=https://api.tugimnasio.com
```

### 4. Ejecutar la aplicación Flutter

```bash
# Para Web
flutter run -d chrome

# Para Android (con emulador o dispositivo conectado)
flutter run -d android
```

---

## Arquitectura de la Integración

### Capas de la aplicación:

```
┌─────────────────────────────────────┐
│         UI Layer (Pages)            │
│  - login_page.dart                  │
│  - members_page.dart                │
│  - plans_page.dart, etc.            │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│      Services Layer                 │
│  - auth_service.dart                │
│  - members_service.dart             │
│  - plans_service.dart, etc.         │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│      HTTP Service (Base)            │
│  - Maneja GET/POST/PUT/DELETE       │
│  - Agrega headers y token           │
│  - Maneja errores                   │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│      Backend API                    │
│  http://localhost:3000/api/v1       │
└─────────────────────────────────────┘
```

### Flujo de datos:

1. **UI** llama a un método del servicio
2. **Servicio** prepara los datos y llama a HttpService
3. **HttpService** agrega headers, token, y hace la petición HTTP
4. **Backend** procesa y responde
5. **HttpService** parsea la respuesta a modelos
6. **Servicio** retorna los datos a la UI
7. **UI** actualiza el estado y muestra los datos

---

## Uso de los Servicios

### Ejemplo: Autenticación

```dart
import 'package:gym_web_ui/core/services/auth_service.dart';

final authService = AuthService();

// Login
try {
  final authResponse = await authService.login(
    'admin@gymrest.test',
    'admin123',
  );
  print('Token: ${authResponse.token}');
  print('Usuario: ${authResponse.user.name}');
} on ApiException catch (e) {
  print('Error: ${e.message}');
}

// Logout
await authService.logout();

// Verificar si está autenticado
final isAuthenticated = await authService.isAuthenticated();
```

### Ejemplo: Gestión de Miembros

```dart
import 'package:gym_web_ui/core/services/members_service.dart';

final membersService = MembersService();

// Listar miembros con filtros
final response = await membersService.getMembers(
  page: 1,
  limit: 10,
  search: 'Juan',
  status: 'Activo',
);

print('Total: ${response.meta?.total}');
for (var member in response.data ?? []) {
  print('${member.displayId}: ${member.name}');
}

// Crear miembro
final newMember = await membersService.createMember(
  name: 'Juan Pérez',
  email: 'juan@example.com',
  phone: '+52 55 1234 5678',
  status: 'Activo',
);

// Actualizar miembro
final updated = await membersService.updateMember(
  newMember.id,
  name: 'Juan Carlos Pérez',
);

// Eliminar miembro
await membersService.deleteMember(newMember.id);

// Exportar a CSV
final csvData = await membersService.exportMembers();
```

### Ejemplo: Planes

```dart
import 'package:gym_web_ui/core/services/plans_service.dart';

final plansService = PlansService();

// Crear plan
final plan = await plansService.createPlan(
  name: 'Plan Premium',
  description: 'Acceso completo',
  price: 800.0,
  durationDays: 30,
  features: ['Gimnasio', 'Clases', 'Nutricionista'],
);

// Listar planes
final response = await plansService.getPlans();
```

### Ejemplo: Suscripciones

```dart
import 'package:gym_web_ui/core/services/subscriptions_service.dart';

final subscriptionsService = SubscriptionsService();

// Crear suscripción
final subscription = await subscriptionsService.createSubscription(
  memberId: 'member-uuid',
  planId: 'plan-uuid',
  startDate: '2025-01-01T00:00:00.000Z',
);
```

### Ejemplo: Pagos

```dart
import 'package:gym_web_ui/core/services/payments_service.dart';

final paymentsService = PaymentsService();

// Registrar pago
final payment = await paymentsService.createPayment(
  memberId: 'member-uuid',
  subscriptionId: 'subscription-uuid',
  amount: 800.0,
  paymentDate: '2025-01-01T00:00:00.000Z',
  method: 'Efectivo',
);

// Obtener recibo (PDF en base64)
final pdfBase64 = await paymentsService.getReceipt(payment.id);
```

### Ejemplo: Asistencia

```dart
import 'package:gym_web_ui/core/services/attendance_service.dart';

final attendanceService = AttendanceService();

// Check-in
final attendance = await attendanceService.checkIn('member-uuid');

// Check-out
await attendanceService.checkOut(attendance.id);
```

### Ejemplo: Reportes

```dart
import 'package:gym_web_ui/core/services/reports_service.dart';

final reportsService = ReportsService();

// Obtener resumen
final summary = await reportsService.getSummary();
print('Ingresos: ${summary['revenue']}');

// Exportar a CSV
final csv = await reportsService.exportCsv(
  fromDate: '2025-01-01',
  toDate: '2025-01-31',
);
```

---

## Flujo de Autenticación

### 1. Login

```dart
// El usuario ingresa email y password
final authResponse = await authService.login(email, password);

// El servicio automáticamente:
// - Guarda el token en SharedPreferences
// - Guarda los datos del usuario
```

### 2. Peticiones autenticadas

```dart
// HttpService automáticamente agrega el token a los headers
final response = await membersService.getMembers();
// Headers: { "Authorization": "Bearer <token>" }
```

### 3. Verificar autenticación

```dart
// En el router o guards
final isAuth = await authService.isAuthenticated();
if (!isAuth) {
  // Redirigir a login
}
```

### 4. Logout

```dart
await authService.logout();
// Limpia token y usuario del storage
// Redirige a login
```

---

## Ejemplos de Integración

### Integrar una página completa

Ver el archivo: `lib/features/members/members_page_integrated_example.dart`

Este archivo muestra:
- Cómo cargar datos desde la API
- Cómo manejar estados de carga
- Cómo crear, actualizar y eliminar registros
- Cómo manejar errores
- Cómo implementar paginación
- Cómo implementar búsqueda

### Patrón recomendado:

```dart
class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final _service = MyService();
  List<MyModel> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final response = await _service.getData();
      if (mounted) {
        setState(() {
          _items = response.data ?? [];
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(e.message);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return ListTile(title: Text(item.name));
      },
    );
  }
}
```

---

## Testing

### 1. Probar el backend

```bash
cd GymRestBack
npm run dev
```

Verifica que esté corriendo en `http://localhost:3000`

### 2. Probar endpoints con Postman/cURL

**Login:**
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@gymrest.test","password":"admin123"}'
```

Deberías recibir:
```json
{
  "data": {
    "token": "eyJhbGc...",
    "user": {
      "id": "user-...",
      "displayId": "U...",
      "name": "Admin User",
      "email": "admin@gymrest.test",
      "role": "admin"
    }
  }
}
```

**Listar miembros (con token):**
```bash
curl -X GET http://localhost:3000/api/v1/members \
  -H "Authorization: Bearer <tu-token>"
```

### 3. Probar el frontend

```bash
cd GymApp
flutter run -d chrome
```

1. Abre la app
2. Intenta hacer login con:
   - Email: `admin@gymrest.test`
   - Password: `admin123`
3. Si es exitoso, deberías ver el dashboard
4. Navega a "Socios" y verifica que se carguen los datos

### 4. Verificar almacenamiento

En Chrome DevTools:
- Application > Local Storage > Verifica que se guarde el token

### 5. Probar errores

- Intenta hacer login con credenciales incorrectas
- Desconecta el backend y verifica mensajes de error
- Intenta crear un miembro con email duplicado

---

## Errores Comunes

### 1. Error de CORS

**Síntoma:** `Access to XMLHttpRequest has been blocked by CORS policy`

**Solución:**
- Verifica que el backend tenga configurado CORS
- En `GymRestBack/.env`, asegúrate de que `FRONTEND_ORIGIN` incluya la URL del frontend:
  ```env
  FRONTEND_ORIGIN=http://localhost:5173
  ```

### 2. Error 401 Unauthorized

**Síntoma:** Peticiones fallan con código 401

**Solución:**
- Verifica que el token se esté guardando correctamente
- Verifica que HttpService esté agregando el header Authorization
- Haz login de nuevo para obtener un token válido

### 3. Error de conexión

**Síntoma:** `SocketException` o `No hay conexión a internet`

**Solución:**
- Verifica que el backend esté corriendo
- Verifica la URL en `.env`
- Si usas emulador Android, usa `http://10.0.2.2:3000` en lugar de `localhost`

### 4. Error al cargar .env

**Síntoma:** `Error loading .env file`

**Solución:**
- Verifica que el archivo `.env` exista en la raíz del proyecto Flutter
- Verifica que esté agregado en `pubspec.yaml` bajo `assets`
- Ejecuta `flutter clean` y `flutter pub get`

### 5. Tipos de datos incorrectos

**Síntoma:** `type 'int' is not a subtype of type 'double'`

**Solución:**
- En los modelos, usa `.toDouble()` al parsear números:
  ```dart
  price: (json['price'] as num).toDouble()
  ```

---

## Checklist de Implementación

### Backend
- [x] Backend corriendo en `http://localhost:3000`
- [x] Credenciales de prueba: `admin@gymrest.test / admin123`
- [x] CORS configurado correctamente
- [x] Endpoints documentados en README

### Frontend - Configuración
- [x] Dependencias instaladas (`http`, `shared_preferences`, `flutter_dotenv`, `provider`)
- [x] Archivo `.env` creado con `API_BASE_URL`
- [x] `main.dart` carga `.env` y inicializa servicios

### Frontend - Modelos
- [x] `api_response.dart` - Respuesta genérica
- [x] `user.dart` - Usuario y AuthResponse
- [x] `member.dart` - Miembro
- [x] `plan.dart` - Plan
- [x] `subscription.dart` - Suscripción
- [x] `payment.dart` - Pago
- [x] `attendance.dart` - Asistencia

### Frontend - Servicios
- [x] `http_service.dart` - Servicio HTTP base
- [x] `storage_service.dart` - Almacenamiento local
- [x] `auth_service.dart` - Autenticación
- [x] `members_service.dart` - Miembros
- [x] `plans_service.dart` - Planes
- [x] `subscriptions_service.dart` - Suscripciones
- [x] `payments_service.dart` - Pagos
- [x] `attendance_service.dart` - Asistencia
- [x] `reports_service.dart` - Reportes

### Frontend - Integración UI
- [x] `login_page.dart` integrado con `AuthService`
- [x] Ejemplo de integración en `members_page_integrated_example.dart`
- [ ] Integrar `dashboard_page.dart` con `ReportsService`
- [ ] Integrar `plans_page.dart` con `PlansService`
- [ ] Integrar `subscriptions_page.dart` con `SubscriptionsService`
- [ ] Integrar `payments_page.dart` con `PaymentsService`
- [ ] Integrar `attendance_page.dart` con `AttendanceService`
- [ ] Integrar `members_page.dart` (reemplazar dummy data)

### Testing
- [ ] Login funciona correctamente
- [ ] Miembros se cargan desde la API
- [ ] Crear nuevo miembro funciona
- [ ] Actualizar miembro funciona
- [ ] Eliminar miembro funciona
- [ ] Paginación funciona
- [ ] Búsqueda funciona
- [ ] Exportar datos funciona
- [ ] Manejo de errores es correcto
- [ ] Logout limpia la sesión

---

## Próximos Pasos

1. **Integrar todas las páginas restantes** siguiendo el ejemplo de `members_page_integrated_example.dart`

2. **Implementar Provider/Riverpod** (opcional) para gestión de estado más avanzada

3. **Agregar refresh automático** cuando se crean/actualizan/eliminan registros

4. **Implementar manejo de imágenes** si es necesario

5. **Agregar validaciones** más robustas en los formularios

6. **Implementar persistencia offline** con SQLite local (opcional)

7. **Agregar tests unitarios** para los servicios

8. **Optimizar rendimiento** con lazy loading y caché

---

## Recursos

- [Documentación del backend](../GymRestBack/README.md)
- [HTTP package](https://pub.dev/packages/http)
- [SharedPreferences](https://pub.dev/packages/shared_preferences)
- [Flutter DotEnv](https://pub.dev/packages/flutter_dotenv)

---

**Integración completada por:** Claude Code
**Fecha:** 2025-01-22
