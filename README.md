# Sistema de Gestión de Gimnasio - Flutter Web

Una aplicación web moderna para la gestión completa de un gimnasio, desarrollada con Flutter Web.

## Características

- **Login seguro** con validación de formularios
- **Dashboard** con métricas clave
- **Gestión de socios** - Administrar miembros del gimnasio
- **Membresías** - Gestionar planes y precios
- **Suscripciones** - Control de suscripciones activas
- **Control de pagos** - Registro y seguimiento de pagos
- **Asistencia** - Control de entrada y salida
- **Reportes y estadísticas** - Análisis de datos
- **Configuración** - Ajustes del sistema

## Tecnologías Utilizadas

- **Flutter 3.24+** - Framework de desarrollo
- **Dart 3+** - Lenguaje de programación
- **Material 3** - Sistema de diseño
- **go_router** - Navegación declarativa
- **flex_color_scheme** - Temas personalizables
- **Google Fonts** - Tipografías
- **fl_chart** - Gráficas y visualizaciones
- **printing** - Generación de recibos

## Requisitos

- Flutter 3.24 o superior
- Dart 3.0 o superior
- Navegador web moderno (Chrome, Firefox, Safari, Edge)

## Instalación y Ejecución

1. **Clonar el repositorio**
   ```bash
   git clone <repository-url>
   cd gym_web_ui
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Ejecutar en modo desarrollo**
   ```bash
   flutter run -d chrome
   ```

4. **Compilar para producción**
   ```bash
   flutter build web
   ```

## Estructura del Proyecto

```
lib/
├── app/
│   ├── app.dart          # Configuración principal de la app
│   └── router.dart       # Configuración de rutas
├── features/
│   ├── login/           # Página de inicio de sesión
│   ├── dashboard/       # Panel principal
│   ├── members/         # Gestión de socios
│   ├── plans/           # Membresías
│   ├── subscriptions/   # Suscripciones
│   ├── payments/        # Control de pagos
│   ├── attendance/      # Asistencia
│   ├── reports/         # Reportes y estadísticas
│   └── settings/        # Configuración
└── main.dart           # Punto de entrada
```

## Características de la Página de Login

- **Diseño moderno** con gradientes y Material 3
- **Validación de formularios** en tiempo real
- **Campos de entrada** con iconos y placeholders
- **Botón de mostrar/ocultar contraseña**
- **Estados de carga** con indicadores visuales
- **Mensajes informativos** para funcionalidades en desarrollo
- **Modo demo** con instrucciones claras
- **Responsive design** que se adapta a diferentes pantallas

## Modo Demo

La aplicación funciona en modo demo, lo que significa:
- Puedes usar cualquier email y contraseña para acceder
- Los datos son simulados (no hay persistencia real)
- Las funcionalidades muestran SnackBars informativos
- Perfecto para demostraciones y pruebas

## Navegación

- `/login` - Página de inicio de sesión
- `/` - Dashboard principal
- `/members` - Gestión de socios
- `/plans` - Membresías
- `/subscriptions` - Suscripciones
- `/payments` - Control de pagos
- `/attendance` - Asistencia
- `/reports` - Reportes y estadísticas
- `/settings` - Configuración

## Desarrollo

### Convenciones
- Widgets **stateful** solo donde sea necesario
- Datos en archivos constantes (sin persistencia)
- Uso de `Intl` para formateo en español mexicano
- Material 3 con temas claro/oscuro automático

### QA Rápido
1. Navega por todas las rutas desde la barra lateral
2. Usa los formularios: deben validar y mostrar SnackBars de demo
3. Verifica que el tema se adapte al sistema operativo
4. Prueba en diferentes tamaños de pantalla

## Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -m 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## Soporte

Para soporte técnico o preguntas, por favor abre un issue en el repositorio.
