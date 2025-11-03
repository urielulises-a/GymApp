#!/bin/bash
echo "Iniciando Sistema de Gestión de Gimnasio en Android..."
echo ""
echo "Instalando dependencias..."
flutter pub get
echo ""
echo "Verificando dispositivos Android disponibles..."
flutter devices
echo ""
echo "Ejecutando aplicación en Android..."
flutter run -d android

