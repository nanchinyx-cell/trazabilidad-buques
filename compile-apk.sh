#!/bin/bash

# Script completo para generar, firmar y alinear el APK
# Ejecuta: chmod +x compile-apk.sh && ./compile-apk.sh

set -e

echo "=================================="
echo "🚀 Compilador de APK - Trazabilidad"
echo "=================================="
echo ""

# Verificar si Cordova está instalado
if ! command -v cordova &> /dev/null; then
    echo "📦 Instalando Cordova globalmente..."
    npm install -g cordova
fi

# Verificar si keytool está disponible (viene con Java)
if ! command -v keytool &> /dev/null; then
    echo "❌ Java no está instalado. Por favor, instala Java JDK."
    echo "   Descárgalo desde: https://www.oracle.com/java/technologies/downloads/"
    exit 1
fi

# Verificar si jarsigner está disponible
if ! command -v jarsigner &> /dev/null; then
    echo "❌ jarsigner no encontrado. Instala Java JDK correctamente."
    exit 1
fi

# Paso 1: Limpiar proyectos anteriores
echo "🧹 Limpiando proyectos anteriores..."
rm -rf TrazabilidadApp 2>/dev/null || true

# Paso 2: Crear proyecto Cordova
echo "📁 Creando proyecto Cordova..."
cordova create TrazabilidadApp com.trazabilidad.buques TrazabilidadBuques
cd TrazabilidadApp

# Paso 3: Agregar plataforma Android
echo "🤖 Agregando plataforma Android..."
cordova platform add android

# Paso 4: Copiar archivos
echo "📋 Copiando archivos de la app..."
cp ../index.html www/
cp ../service-worker.js www/
cp ../manifest.json www/
cp ../server.js www/ 2>/dev/null || true
cp ../package.json www/ 2>/dev/null || true

# Paso 5: Crear config.xml
echo "⚙️  Configurando config.xml..."
cat > config.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<widget id="com.trazabilidad.buques" version="1.0.0" xmlns="http://www.w3.org/ns/widgets" xmlns:cdv="http://cordova.apache.org/ns/1.0">
    <name>Trazabilidad Buques</name>
    <description>App de trazabilidad de buques en tiempo real</description>
    <author email="nanchi.nyx@gmail.com" href="https://github.com/nanchinyx-cell">nanchinyx-cell</author>
    <content src="index.html" />
    <preference name="orientation" value="portrait" />
    <preference name="target-device" value="universal" />
    <preference name="fullscreen" value="false" />
    <preference name="android-minSdkVersion" value="21" />
    <access origin="*" />
    <plugin name="cordova-plugin-whitelist" spec="1" />
    <allow-intent href="http://*/*" />
    <allow-intent href="https://*/*" />
</widget>
EOF

# Paso 6: Compilar APK
echo ""
echo "🔨 Compilando APK en modo release (esto puede tardar 5-10 minutos)..."
cordova build android --release

# Paso 7: Verificar si se generó el APK sin firmar
APK_UNSIGNED="platforms/android/app/build/outputs/apk/release/app-release-unsigned.apk"

if [ ! -f "$APK_UNSIGNED" ]; then
    echo "❌ Error: No se pudo generar el APK"
    exit 1
fi

echo "✅ APK sin firmar generado correctamente"
echo ""

# Paso 8: Generar keystore si no existe
if [ ! -f "release-key.jks" ]; then
    echo "🔑 Generando keystore para firmar el APK..."
    keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 \
        -alias release -dname "CN=TrazabilidadBuques, OU=Dev, O=Company, L=City, ST=State, C=AR" \
        -storepass trazabilidad123 -keypass trazabilidad123
    echo "✅ Keystore generado"
else
    echo "ℹ️  Keystore existente encontrado, usando ese..."
fi

echo ""

# Paso 9: Firmar el APK
echo "✍️  Firmando el APK..."
jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 \
    -keystore release-key.jks -storepass trazabilidad123 -keypass trazabilidad123 \
    "$APK_UNSIGNED" release

echo "✅ APK firmado correctamente"
echo ""

# Paso 10: Alinear el APK
echo "📐 Alineando el APK..."
APK_SIGNED="platforms/android/app/build/outputs/apk/release/app-release.apk"
zipalign -v 4 "$APK_UNSIGNED" "$APK_SIGNED"

echo "✅ APK alineado correctamente"
echo ""

# Paso 11: Mostrar resultado
if [ -f "$APK_SIGNED" ]; then
    SIZE=$(du -h "$APK_SIGNED" | cut -f1)
    echo "=================================="
    echo "✅ ¡APK LISTO PARA INSTALAR!"
    echo "=================================="
    echo ""
    echo "📍 Ubicación del APK:"
    echo "   $(pwd)/$APK_SIGNED"
    echo ""
    echo "📦 Tamaño: $SIZE"
    echo ""
    echo "🚀 Instrucciones para instalar:"
    echo "   1. Transfiere el APK a tu Android"
    echo "   2. Abre el archivo desde el administrador de archivos"
    echo "   3. Toca 'Instalar' y sigue las instrucciones"
    echo ""
    echo "⚠️  Asegúrate de permitir instalación de apps de fuentes desconocidas"
    echo "    (Ajustes > Seguridad > Fuentes desconocidas)"
    echo ""
    
    # Paso 12: Copiar APK a un lugar accesible
    cp "$APK_SIGNED" ../TrazabilidadBuques.apk
    echo "📋 Copia disponible en: ../TrazabilidadBuques.apk"
    
else
    echo "❌ Error al alinear el APK"
    exit 1
fi

cd ..
echo ""
echo "🎉 ¡Proceso completado exitosamente!"
echo ""
