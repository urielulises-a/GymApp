# Mapeo de Endpoints - Backend ↔ Frontend

## Resumen

Este documento mapea los endpoints del backend con los servicios de Flutter.

Base URL: `http://localhost:3000/api/v1`

---

## Autenticación

### POST `/auth/login`
- **Servicio:** `AuthService.login(email, password)`
- **Body:** `{ email, password }`
- **Response:** `{ token, user }`

### POST `/auth/register`
- **Servicio:** `AuthService.register(name, email, password, role)`
- **Body:** `{ name, email, password, role }`
- **Response:** `{ token, user }`

### POST `/auth/forgot-password`
- **Servicio:** `AuthService.forgotPassword(email)`
- **Body:** `{ email }`
- **Response:** `{ message }`

### POST `/auth/logout`
- **Servicio:** `AuthService.logout()`
- **Body:** `{}`
- **Response:** `{ message }`

---

## Miembros (Members)

### GET `/members`
- **Servicio:** `MembersService.getMembers(...)`
- **Query Params:**
  - `page`, `limit`, `sortBy`, `order`
  - `search`, `status`, `planId`
  - `fromDate`, `toDate`
- **Response:** `{ data: [Member], meta: { page, limit, total, totalPages } }`

### GET `/members/:id`
- **Servicio:** `MembersService.getMemberById(id)`
- **Response:** `{ data: Member }`

### POST `/members`
- **Servicio:** `MembersService.createMember(...)`
- **Body:** `{ name, email, phone, joinDate, status, planId }`
- **Response:** `{ data: Member }`

### PUT `/members/:id`
- **Servicio:** `MembersService.updateMember(id, ...)`
- **Body:** `{ name?, email?, phone?, joinDate?, status?, planId? }`
- **Response:** `{ data: Member }`

### DELETE `/members/:id`
- **Servicio:** `MembersService.deleteMember(id)`
- **Response:** `{ data: true }`

### GET `/members/export`
- **Servicio:** `MembersService.exportMembers()`
- **Response:** CSV file (Content-Disposition header)

---

## Planes (Plans)

### GET `/plans`
- **Servicio:** `PlansService.getPlans(...)`
- **Query Params:** `page`, `limit`, `sortBy`, `order`, `search`, `status`
- **Response:** `{ data: [Plan], meta }`

### GET `/plans/:id`
- **Servicio:** `PlansService.getPlanById(id)`
- **Response:** `{ data: Plan }`

### POST `/plans`
- **Servicio:** `PlansService.createPlan(...)`
- **Body:** `{ name, description, price, durationDays, features, status }`
- **Response:** `{ data: Plan }`

### PUT `/plans/:id`
- **Servicio:** `PlansService.updatePlan(id, ...)`
- **Body:** `{ name?, description?, price?, durationDays?, features?, status? }`
- **Response:** `{ data: Plan }`

### DELETE `/plans/:id`
- **Servicio:** `PlansService.deletePlan(id)`
- **Response:** `{ data: true }`

---

## Suscripciones (Subscriptions)

### GET `/subscriptions`
- **Servicio:** `SubscriptionsService.getSubscriptions(...)`
- **Query Params:**
  - `page`, `limit`, `sortBy`, `order`
  - `memberId`, `planId`, `status`
  - `fromDate`, `toDate`
- **Response:** `{ data: [Subscription], meta }`

### GET `/subscriptions/:id`
- **Servicio:** `SubscriptionsService.getSubscriptionById(id)`
- **Response:** `{ data: Subscription }`

### POST `/subscriptions`
- **Servicio:** `SubscriptionsService.createSubscription(...)`
- **Body:** `{ memberId, planId, startDate, status? }`
- **Response:** `{ data: Subscription }`
- **Nota:** `endDate` se calcula automáticamente: `startDate + plan.durationDays`

### PUT `/subscriptions/:id`
- **Servicio:** `SubscriptionsService.updateSubscription(id, ...)`
- **Body:** `{ startDate?, status? }`
- **Response:** `{ data: Subscription }`

### DELETE `/subscriptions/:id`
- **Servicio:** `SubscriptionsService.deleteSubscription(id)`
- **Response:** `{ data: true }`

### GET `/subscriptions/export`
- **Servicio:** `SubscriptionsService.exportSubscriptions()`
- **Response:** CSV file

---

## Pagos (Payments)

### GET `/payments`
- **Servicio:** `PaymentsService.getPayments(...)`
- **Query Params:**
  - `page`, `limit`, `sortBy`, `order`
  - `memberId`, `subscriptionId`, `method`, `status`
  - `fromDate`, `toDate`
- **Response:** `{ data: [Payment], meta }`

### GET `/payments/:id`
- **Servicio:** `PaymentsService.getPaymentById(id)`
- **Response:** `{ data: Payment }`

### POST `/payments`
- **Servicio:** `PaymentsService.createPayment(...)`
- **Body:** `{ memberId, subscriptionId, amount, paymentDate, method, status, notes? }`
- **Response:** `{ data: Payment }`
- **Nota:** Genera notificación automática para el miembro

### PUT `/payments/:id`
- **Servicio:** `PaymentsService.updatePayment(id, ...)`
- **Body:** `{ amount?, paymentDate?, method?, status?, notes? }`
- **Response:** `{ data: Payment }`

### DELETE `/payments/:id`
- **Servicio:** `PaymentsService.deletePayment(id)`
- **Response:** `{ data: true }`

### GET `/payments/:id/receipt`
- **Servicio:** `PaymentsService.getReceipt(id)`
- **Response:** `{ data: { pdf: "base64..." } }`
- **Nota:** PDF simulado en base64

### GET `/payments/export`
- **Servicio:** `PaymentsService.exportPayments()`
- **Response:** CSV file

---

## Asistencia (Attendance)

### GET `/attendance`
- **Servicio:** `AttendanceService.getAttendance(...)`
- **Query Params:**
  - `page`, `limit`, `sortBy`, `order`
  - `memberId`, `status`
  - `fromDate`, `toDate`
- **Response:** `{ data: [Attendance], meta }`

### GET `/attendance/:id`
- **Servicio:** `AttendanceService.getAttendanceById(id)`
- **Response:** `{ data: Attendance }`

### POST `/attendance/check-in`
- **Servicio:** `AttendanceService.checkIn(memberId)`
- **Body:** `{ memberId }`
- **Response:** `{ data: Attendance }`
- **Validaciones:**
  - Verifica que el miembro tenga suscripción activa
  - Evita duplicados (no puede haber dos check-ins abiertos)

### POST `/attendance/check-out/:id`
- **Servicio:** `AttendanceService.checkOut(attendanceId)`
- **Body:** `{}`
- **Response:** `{ data: Attendance }`
- **Nota:** Actualiza `checkOutTime` y cambia estado a "Completado"

### POST `/attendance`
- **Servicio:** `AttendanceService.createAttendance(...)`
- **Body:** `{ memberId, checkInTime, checkOutTime?, status }`
- **Response:** `{ data: Attendance }`
- **Nota:** Para registro manual de asistencia

### PUT `/attendance/:id`
- **Servicio:** `AttendanceService.updateAttendance(id, ...)`
- **Body:** `{ checkInTime?, checkOutTime?, status? }`
- **Response:** `{ data: Attendance }`

### DELETE `/attendance/:id`
- **Servicio:** `AttendanceService.deleteAttendance(id)`
- **Response:** `{ data: true }`

### GET `/attendance/export`
- **Servicio:** `AttendanceService.exportAttendance()`
- **Response:** CSV file

---

## Reportes (Reports)

### GET `/reports/summary`
- **Servicio:** `ReportsService.getSummary()`
- **Response:**
  ```json
  {
    "data": {
      "revenue": { "total": 45000, "monthly": [...] },
      "members": { "total": 120, "active": 100, "growth": 5 },
      "planDistribution": [{ planId, planName, count, percentage }],
      "recentPayments": [...]
    }
  }
  ```

### GET `/reports/export-csv`
- **Servicio:** `ReportsService.exportCsv(fromDate?, toDate?)`
- **Query Params:** `fromDate`, `toDate`
- **Response:** CSV file

### GET `/reports/export-pdf`
- **Servicio:** `ReportsService.exportPdf(fromDate?, toDate?)`
- **Query Params:** `fromDate`, `toDate`
- **Response:** `{ data: { pdf: "base64..." } }`

---

## Configuración (Settings)

### GET `/settings`
- **Endpoint:** `/settings`
- **Response:** `{ data: { gymName, email, phone, address, ... } }`

### PUT `/settings`
- **Endpoint:** `/settings`
- **Body:** `{ gymName?, email?, phone?, address?, ... }`
- **Response:** `{ data: Settings }`

### POST `/settings/backup`
- **Endpoint:** `/settings/backup`
- **Response:** `{ data: { filename, path, size } }`
- **Nota:** Crea backup de la base de datos

### GET `/settings/backups`
- **Endpoint:** `/settings/backups`
- **Response:** `{ data: [{ filename, date, size }] }`

---

## Notificaciones

### GET `/notifications`
- **Endpoint:** `/notifications`
- **Query Params:** `page`, `limit`, `type`, `isRead`
- **Response:** `{ data: [Notification], meta }`

### POST `/notifications/:id/read`
- **Endpoint:** `/notifications/:id/read`
- **Response:** `{ data: Notification }`
- **Nota:** Marca notificación como leída

---

## Formato de Respuesta Estándar

Todas las respuestas siguen este formato:

```json
{
  "data": <T>,
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 100,
    "totalPages": 10
  },
  "errors": [
    {
      "message": "Error message",
      "field": "fieldName",
      "code": "ERROR_CODE"
    }
  ]
}
```

---

## Autenticación

Todas las peticiones (excepto `/auth/login` y `/auth/register`) requieren token JWT:

```
Authorization: Bearer <token>
```

El token se obtiene al hacer login y se guarda automáticamente en `SharedPreferences`.

---

## Paginación

Endpoints con paginación aceptan:
- `page`: Número de página (default: 1)
- `limit`: Items por página (default: 10)
- `sortBy`: Campo para ordenar (default: 'createdAt')
- `order`: 'asc' o 'desc' (default: 'desc')

---

## Filtros por Fecha

Formato: ISO 8601
- `fromDate`: `2025-01-01T00:00:00.000Z`
- `toDate`: `2025-01-31T23:59:59.999Z`

---

## IDs

El backend usa dos tipos de IDs:
- **id (UUID):** ID interno único (usado en peticiones)
- **displayId:** ID legible con prefijo (M001, P001, etc.) para mostrar al usuario

Ejemplos:
- Member: `M001`, `M002`
- Plan: `P001`, `P002`
- Subscription: `S001`, `S002`
- Payment: `PAY001`, `PAY002`
- Attendance: `A001`, `A002`

---

## Tareas Automáticas (Cron)

El backend ejecuta diariamente a las 00:00:
- Marca suscripciones vencidas
- Genera notificaciones de advertencia para suscripciones próximas a vencer

---

Para más información, consulta `INTEGRATION_GUIDE.md`
