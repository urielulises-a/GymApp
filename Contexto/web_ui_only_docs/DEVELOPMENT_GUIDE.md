# Development Guide — Web UI-only

## Requisitos
- Flutter 3.24+, Dart 3+
- Chrome/Edge

## Pasos de desarrollo
```bash
flutter pub get
flutter run -d chrome --web-renderer skwasm
```
> `skwasm` o `canvaskit` funcionan bien en Flutter Web para UI nítida.

## Convenciones
- Widgets **stateful** solo donde sea necesario para inputs y navegación.
- Mantén los datos **en archivos constantes**. No agregues repositorios ni providers.
- Usa `Intl` para formateo (`es_MX`).

## QA rápido
- Navega por todas las rutas desde la barra lateral.
- Usa los formularios: deben validar mínimos y mostrar SnackBars de demo.
- Imprime un recibo desde `/payments/new` → `/payments/receipt/FAKE-0001`.
- Revisa gráficas con `fl_chart` (sincrónicas con dummy data).
