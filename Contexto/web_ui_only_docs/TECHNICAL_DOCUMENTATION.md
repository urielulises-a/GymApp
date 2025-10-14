# Technical Documentation — Flutter Web UI-only

## Stack (mínimo)
- Flutter 3.24+ (Web), Dart 3+
- Router: **go_router**
- UI: **Material 3** + **flex_color_scheme** (+ GoogleFonts opcional)
- Charts: **fl_chart** (gráficas con datos estáticos)
- Utilidades: **intl** (moneda/fechas), **printing** (imprimir recibo)

> Sin backend, sin Hive, sin Freezed, sin Riverpod. Datos locales embebidos (listas `const`).

## Estructura
```
lib/
  app/
    app.dart
    router.dart
    theme.dart
  core/
    widgets/ (KpiCard, DataTableX, FormDialog, ReceiptPreview, ConfirmDialog)
    utils/ (money.dart, dates.dart, dummy_data.dart)
  features/
    dashboard/
    members/
    plans/
    subscriptions/
    payments/
    attendance/
    reports/
    settings/
web/ (index.html, manifest PWA opcional)
```

## Rutas
- `/login`
- `/`
- `/members`
- `/plans`
- `/subscriptions`
- `/payments/new`
- `/payments/receipt/:id`
- `/attendance`
- `/reports`
- `/settings`

## Componentes
- **AppScaffold** (NavRail/Drawer + AppBar + responsive).
- **KpiCard** (título/valor/subtítulo).
- **DataTableX** (tabla simple con búsqueda local).
- **FormDialog** (Dialog con `Form` y `TextFormField`).
- **ReceiptPreview** (vista A5 con botón Imprimir/Guardar usando `printing`).

## Datos de ejemplo
Archivo `core/utils/dummy_data.dart` con listas `const` para:
- `kMembers`, `kPlans`, `kSubscriptions`, `kPayments`, `kAttendance` y KPIs/gráficas de dashboard.

## Reglas SOLO VISUALES (mock)
- Cálculo de `endDate = startDate + durationDays - 1` mostrado en la UI (no se guarda).
- “Crear/Editar/Eliminar” muestra **SnackBar** “Demostración: sin persistencia”.
- En `/payments/new`, al “guardar” navega a `/payments/receipt/FAKE-0001`.
