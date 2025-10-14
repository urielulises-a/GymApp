# Prompts para Cursor — Web UI-only (sin backend, sin Hive, sin Freezed)

1) **Bootstrap del proyecto**
> Crea un proyecto Flutter llamado `gym_web_ui`. Copia el `pubspec.yaml` provisto. Configura Material 3 y `go_router`. Genera `AppScaffold` (NavRail/Drawer + AppBar) y las rutas listadas en TECHNICAL_DOCUMENTATION.md.

2) **Datos mock en memoria**
> Crea `core/utils/dummy_data.dart` con listas `const` para miembros, planes, suscripciones, pagos, asistencias y KPIs/gráficas. Agrega utilidades `money.dart` y `dates.dart` con `intl` (es_MX).

3) **Pantallas**
> Implementa todas las rutas con widgets estáticos y formularios mínimos. Los botones de guardar/editar/eliminar SOLO muestran SnackBars de demo. En `/payments/new` navega a `/payments/receipt/FAKE-0001`.

4) **Componentes reusables**
> Implementa `KpiCard`, `DataTableX`, `FormDialog`, `ReceiptPreview`, `ConfirmDialog`. Usa `fl_chart` con datos estáticos.

5) **Theming y Accesibilidad**
> Material 3 + `flex_color_scheme` con claro/oscuro; tamaños táctiles adecuados; focus visible.

6) **Entrega**
> README con pasos `flutter run -d chrome` y `flutter build web`. No agregar dependencias de estado/persistencia.
