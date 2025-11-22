# Inicio Rápido - Integración Backend + Flutter

## Pasos para empezar (5 minutos)

### 1. Iniciar el Backend

```bash
cd GymRestBack
npm install
npm run migrate
npm run seed
npm run dev
```

Deberías ver:
```
Server listening on http://localhost:3000
```

### 2. Configurar Flutter

```bash
cd GymApp
flutter pub get
```

El archivo `.env` ya está configurado con:
```env
API_BASE_URL=http://localhost:3000
```

### 3. Ejecutar la aplicación

```bash
# Para Web
flutter run -d chrome

# Para Android
flutter run -d android
```

### 4. Probar Login

- Email: `admin@gymrest.test`
- Password: `admin123`

---

## Estructura de la Integración

```
GymApp/
├── .env                          # Configuración de API
├── lib/
│   ├── core/
│   │   ├── config/
│   │   │   └── api_config.dart  # URLs y endpoints
│   │   ├── models/              # Modelos de datos
│   │   └── services/            # Servicios HTTP
│   └── features/
│       └── login/
│           └── login_page.dart  # YA INTEGRADO ✓
```

---

## Servicios Disponibles

Todos listos para usar:

```dart
// Autenticación
final authService = AuthService();
await authService.login(email, password);

// Miembros
final membersService = MembersService();
await membersService.getMembers();

// Planes
final plansService = PlansService();
await plansService.getPlans();

// Suscripciones
final subscriptionsService = SubscriptionsService();
await subscriptionsService.getSubscriptions();

// Pagos
final paymentsService = PaymentsService();
await paymentsService.getPayments();

// Asistencia
final attendanceService = AttendanceService();
await attendanceService.getAttendance();

// Reportes
final reportsService = ReportsService();
await reportsService.getSummary();
```

---

## Ejemplo de Uso en una Página

Ver archivo completo: `lib/features/members/members_page_integrated_example.dart`

Patrón básico:

```dart
import 'package:gym_web_ui/core/services/members_service.dart';

class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final _membersService = MembersService();
  List<Member> _members = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);

    try {
      final response = await _membersService.getMembers();
      setState(() {
        _members = response.data ?? [];
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() => _isLoading = false);
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _members.length,
      itemBuilder: (context, index) {
        return ListTile(title: Text(_members[index].name));
      },
    );
  }
}
```

---

## Verificar que todo funciona

### Backend

```bash
curl http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@gymrest.test","password":"admin123"}'
```

Deberías recibir un token.

### Frontend

1. Ejecuta `flutter run -d chrome`
2. Ingresa:
   - Email: `admin@gymrest.test`
   - Password: `admin123`
3. Deberías ver: "Bienvenido, Admin User"
4. Deberías ser redirigido al dashboard

---

## Próximos pasos

1. Revisa `INTEGRATION_GUIDE.md` para documentación completa
2. Estudia `members_page_integrated_example.dart` como referencia
3. Integra las demás páginas siguiendo el mismo patrón
4. Personaliza según tus necesidades

---

## Problemas comunes

**Backend no responde:**
```bash
cd GymRestBack
npm run dev
```

**Error de CORS:**
- Verifica que `FRONTEND_ORIGIN` en `.env` del backend incluya tu URL

**Error 401:**
- Haz login de nuevo para obtener un token válido

**Error al cargar .env:**
```bash
flutter clean
flutter pub get
```

---

## Credenciales de Prueba

- **Admin:** `admin@gymrest.test / admin123`

---

Para más detalles, consulta `INTEGRATION_GUIDE.md`
