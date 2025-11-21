# Marco Teórico — Sistema de Gestión de Gimnasio (Flutter **Web**, solo Vistas)
**Fecha:** 2025-10-14

## 1. Introducción
Se requiere una aplicación **web** para la operación de un gimnasio (miembros, planes, suscripciones, pagos/recibos, asistencias y reportes) donde en esta fase **solo se implementan las VISTAS (UI)**. No habrá backend, ni base de datos, ni almacenamiento local: los datos serán **mock** en memoria (constantes).

## 2. Fundamentos
- **SPA** (Single Page Application) construida con **Flutter Web**.
- **Navegación declarativa** con `go_router`.
- **UI desacoplada** de datos: la UI usa listas constantes y callbacks vacíos (snackbars “demo”). En el futuro se reemplazarán por repositorios/servicios reales sin reescribir vistas.
- **Internacionalización** mínima (textos en es‑MX) y formato de moneda/fecha local.

## 3. Dominio UI (mock)
- **Miembros** (listado, formulario de ejemplo).
- **Planes** (listado y formulario).
- **Suscripciones** (formulario con cálculo visual de fecha fin).
- **Pagos/Recibos** (formulario y pantalla de recibo lista para imprimir).
- **Asistencia** (búsqueda y botón de check‑in de demostración).
- **Reportes** (gráficas con datos estáticos).
- **Ajustes** (tema claro/oscuro, idioma visual).

## 4. Objetivos
- Navegación completa entre pantallas.
- Layout responsivo y accesible (Material 3).
- Componentes reusables (tarjetas KPI, tabla simple, diálogos/forms, recibo imprimible).
- Sin dependencias innecesarias para esta fase (sin estado global, sin persistencia).
