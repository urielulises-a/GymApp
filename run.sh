#!/bin/bash
echo "Iniciando Sistema de Gestión de Gimnasio..."
echo ""
echo "Instalando dependencias..."
flutter pub get
echo ""
echo "Ejecutando aplicación en Chrome..."
flutter run -d chrome
