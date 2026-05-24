#!/bin/bash

# Script para compilar la app en APK de Android
# Ejecuta: chmod +x build.sh && ./build.sh

echo "🚀 Iniciando compilación del APK..."
echo ""

# Instalar Cordova
echo "📦 Instalando Cordova..."
npm install -g cordova

# Crear proyecto Cordova
echo "📁 Creando proyecto Cordova..."
cordova create TrazabilidadApp com.trazabilidad.buques TrazabilidadBuques

cd TrazabilidadApp

# Agregar plataforma Android
echo "🤖 Agregando plataforma Android..."
cordova platform add android

# Copiar archivos
echo "📋 Copiando archivos..."
cp ../index.html www/
cp ../service-worker.js www/
cp ../manifest.json www/
cp ../server.js www/
cp ../package.json www/

# Actualizar config.xml
echo '<?xml version="1.0" encoding="UTF-8"?>
<widget id="com.trazabilidad.buques" version="1.0.0" xmlns="http://www.w3.org/ns/widgets" xmlns:cdv="http://cordova.apache.org/ns/1.0">
    <name>Trazabilidad Buques</name>
    <description>App de trazabilidad de buques en tiempo real</description>
    <author email="nanchi.nyx@gmail.com" href="https://github.com/nanchinyx-cell">nanchinyx-cell</author>
    <content src="index.html" />
    <preference name="orientation" value="portrait" />
    <preference name="target-device" value="universal" />
    <preference name="fullscreen" value="false" />
    <access origin="*" />
    <plugin name="cordova-plugin-whitelist" spec="1" />
    <allow-intent href="http://*/*" />
    <allow-intent href="https://*/*" />
</widget>' > config.xml

# Compilar APK
echo "🔨 Compilando APK (esto puede tardar varios minutos)..."
cordova build android --release

# Verificar si se generó correctamente
if [ -f "platforms/android/app/build/outputs/apk/release/app-release-unsigned.apk" ]; then
    echo "✅ APK generado exitosamente!"
    echo "📍 Ubicación: $(pwd)/platforms/android/app/build/outputs/apk/release/app-release-unsigned.apk"
    echo ""
    echo "⚠️  Nota: Este APK es sin firmar. Para distribuirlo, necesitas:"
    echo "   1. Generar un keystore: keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release"
    echo "   2. Firmar el APK y alinearlo"
    echo ""
else
    echo "❌ Error al generar el APK"
    exit 1
fi

cd ..
echo "🎉 ¡Compilación completada!"
