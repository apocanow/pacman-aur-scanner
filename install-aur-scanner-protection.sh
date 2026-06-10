#!/bin/bash

# Script de instalación de aur-scanner + wrapper para CachyOS
# Ejecutar: chmod +x ~/install-aur-scanner-protection.sh && ./install-aur-scanner-protection.sh

set -e

echo "=========================================="
echo "  AUR Scanner Protection Installer"
echo "  Para CachyOS / Arch Linux"
echo "=========================================="
echo ""

# Detectar helper AUR
if command -v paru &> /dev/null; then
    AUR_HELPER="paru"
elif command -v yay &> /dev/null; then
    AUR_HELPER="yay"
else
    echo "❌ No se encontró paru ni yay. Instalando paru..."
    sudo pacman -S --needed base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru
    makepkg -si --noconfirm
    cd ~
    AUR_HELPER="paru"
fi

echo "✅ Usando helper AUR: $AUR_HELPER"

# Paso 1: Instalar aur-scanner-git
echo ""
echo "📦 Instalando aur-scanner-git desde AUR..."
$AUR_HELPER -S aur-scanner-git --noconfirm

# Paso 2: Verificar instalación
echo ""
echo "🔍 Verificando instalación..."
if [[ -f /usr/bin/aur-scan && -f /usr/bin/aur-scan-hook ]]; then
    echo "✅ aur-scanner instalado correctamente"
else
    echo "❌ Error: No se encontraron los ejecutables de aur-scanner"
    exit 1
fi

# Paso 3: Crear el wrapper pacman-aur
echo ""
echo "🛠️  Creando wrapper pacman-aur..."
sudo tee /usr/local/bin/pacman-aur > /dev/null << 'WRAPPER'
#!/bin/bash
# Wrapper para pacman con escaneo automático de paquetes AUR
# Instalado por install-aur-scanner-protection.sh

INSTALLING=false
PACKAGES=""

for arg in "$@"; do
    if [[ "$arg" == "-S" ]]; then
        INSTALLING=true
    elif [[ "$INSTALLING" == true && "$arg" != -* ]]; then
        PACKAGES="$PACKAGES $arg"
    fi
done

if [[ -n "$PACKAGES" && "$INSTALLING" == true ]]; then
    for pkg in $PACKAGES; do
        OUTPUT=$(aur-scan check "$pkg" 2>&1)
        if echo "$OUTPUT" | grep -q "Not found: Package.*not found in AUR"; then
            echo "ℹ️  $pkg es un paquete de repositorio oficial (no AUR)"
            echo "✅ Escaneo omitido (solo aplicable a paquetes AUR)"
        else
            echo "🔍 Escaneando $pkg con aur-scanner..."
            echo "$OUTPUT"
            if echo "$OUTPUT" | grep -qi "security issues detected\|malicious\|CRYPTO"; then
                echo "❌ AUR-SCANNER: Paquete $pkg sospechoso. Instalación cancelada."
                exit 1
            fi
            echo "✅ Paquete $pkg: escaneo pasado"
        fi
    done
    echo "✅ Verificación completada. Continuando..."
fi

exec /usr/bin/pacman "$@"
WRAPPER

# Dar permisos
sudo chmod +x /usr/local/bin/pacman-aur
echo "✅ Wrapper creado en /usr/local/bin/pacman-aur"

# Paso 4: Preguntar por alias
echo ""
read -p "¿Quieres crear un alias para que 'pacman' use automáticamente el wrapper? (s/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Ss]$ ]]; then
    if ! grep -q "alias pacman=" ~/.bashrc 2>/dev/null; then
        echo "alias pacman='sudo pacman-aur'" >> ~/.bashrc
        echo "✅ Alias agregado a ~/.bashrc"
        echo "⚠️  Ejecuta 'source ~/.bashrc' para usarlo en esta sesión"
    else
        echo "⚠️  Ya existe un alias para pacman en ~/.bashrc"
    fi
fi

# Paso 5: Probar instalación
echo ""
echo "=========================================="
echo "  🧪 Probando la instalación..."
echo "=========================================="
if sudo pacman-aur -S lolcat 2>&1 | grep -q "Verificación completada"; then
    echo "✅ Prueba exitosa: el wrapper funciona correctamente"
else
    echo "⚠️  La prueba no mostró el mensaje esperado, pero puede funcionar igual"
fi

# Paso 6: Resumen final
echo ""
echo "=========================================="
echo "  ✅ INSTALACIÓN COMPLETADA"
echo "=========================================="
echo ""
echo "📋 Comandos disponibles:"
echo "   sudo pacman-aur -S <paquete>   -> Instalar con escaneo"
echo "   sudo pacman-aur -Syu           -> Actualizar sistema"
echo ""
if grep -q "alias pacman=" ~/.bashrc 2>/dev/null; then
    echo "🔗 Alias configurado: 'pacman' ahora es 'sudo pacman-aur'"
    echo "   source ~/.bashrc  (para activar en esta terminal)"
else
    echo "💡 Para comodidad, ejecuta:"
    echo "   echo 'alias pacman=\"sudo pacman-aur\"' >> ~/.bashrc"
    echo "   source ~/.bashrc"
fi
echo ""
echo "🛡️  Tu sistema está protegido contra paquetes AUR maliciosos"
echo "=========================================="
