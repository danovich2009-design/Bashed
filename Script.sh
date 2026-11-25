#!/usr/bin/env bash


# Configuración y variables globales

CARPETA_OBJETIVO="./zona_pruebas"
ARCHIVO_LOG="./homelab.log"


if [ ! -d "$CARPETA_OBJETIVO" ]; then
    mkdir -p "$CARPETA_OBJETIVO"
    touch "$CARPETA_OBJETIVO/foto_vacaciones.jpg" \
          "$CARPETA_OBJETIVO/apuntes_clase.pdf" \
          "$CARPETA_OBJETIVO/respaldo_viejo.tmp" \
          "$CARPETA_OBJETIVO/archivo_vacio.txt"
fi

# Colores para la terminal
VERDE='\033[0;32m'
AMARILLO='\033[1;33m'
ROJO='\033[0;31m'
AZUL='\033[0;36m'
SIN_COLOR='\033[0m'


# Funciones auxiliares

registrar_evento() {
    local mensaje="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $mensaje" >> "$ARCHIVO_LOG"
}

pausar() {
    echo ""
    read -rp "Presiona [Enter] para volver al menú..."
}


# Módulo 1: Monitor de salud del sistema

monitor_salud() {
    clear
    echo -e "${AZUL}=== MONITOR DE SALUD DEL SISTEMA ===${SIN_COLOR}\n"

    echo -e "${AMARILLO} Espacio en discos:${SIN_COLOR}"
    df -h | grep -E "Filesystem|C:|D:|/$"
    echo ""

    echo -e "${AMARILLO} Memoria RAM:${SIN_COLOR}"
    if command -v free > /dev/null 2>&1; then
        free -h | awk '/^Mem:/ {print "Total: " $2 " | Usada: " $3 " | Libre: " $4}'
    elif command -v powershell.exe > /dev/null 2>&1; then
        powershell.exe -NoProfile -Command "
            \$os = Get-CimInstance Win32_OperatingSystem;
            \$total = [math]::Round(\$os.TotalVisibleMemorySize / 1MB, 2);
            \$libre = [math]::Round(\$os.FreePhysicalMemory / 1MB, 2);
            Write-Host \"Total: \$total GB | Libre: \$libre GB\"
        "
    fi
    echo ""

    echo -e "${AMARILLO} Estado de conexión a Internet:${SIN_COLOR}"
    if ping -c 1 8.8.8.8 > /dev/null 2>&1 || ping -n 1 8.8.8.8 > /dev/null 2>&1; then
        echo -e "Conexión: ${VERDE}EN LÍNEA${SIN_COLOR}"
    else
        echo -e "Conexión: ${ROJO}SIN INTERNET${SIN_COLOR}"
    fi

    registrar_evento "Consulta de estado de salud del sistema."
    pausar
}


# Módulo 2: Organizador de archivos

organizar_archivos() {
    clear
    echo -e "${AZUL}=== ORGANIZADOR DE ARCHIVOS ===${SIN_COLOR}"
    echo -e "Carpeta actual: ${AMARILLO}$CARPETA_OBJETIVO${SIN_COLOR}\n"

    if [ ! -d "$CARPETA_OBJETIVO" ]; then
        echo -e "${ROJO}Error: La carpeta no existe.${SIN_COLOR}"
        pausar
        return
    fi

    local movidos=0

    for archivo in "$CARPETA_OBJETIVO"/*; do
        [ -f "$archivo" ] || continue

        local nombre_base
        nombre_base=$(basename "$archivo")
        local extension="${nombre_base##*.}"
        extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')

        local destino=""
        case "$extension" in
            jpg|jpeg|png|gif|webp|svg)
                destino="Imagenes"
                ;;
            pdf|doc|docx|txt|xlsx|pptx|csv)
                destino="Documentos"
                ;;
            mp4|mkv|avi|mov)
                destino="Videos"
                ;;
            mp3|wav|flac|ogg)
                destino="Audio"
                ;;
            zip|rar|7z|tar|gz)
                destino="Comprimidos"
                ;;
            exe|msi)
                destino="Instaladores"
                ;;
            *)
                continue
                ;;
        esac

        mkdir -p "$CARPETA_OBJETIVO/$destino"
        mv "$archivo" "$CARPETA_OBJETIVO/$destino/"
        echo -e "Movido: ${VERDE}$nombre_base${SIN_COLOR} -> $destino/"
        ((movidos++))
    done

    echo -e "\nTotal de archivos organizados: ${VERDE}$movidos${SIN_COLOR}"
    registrar_evento "Organizados $movidos archivos en $CARPETA_OBJETIVO."
    pausar
}

# ==========================================
# Módulo 3: Limpiador seguro

limpiar_basura() {
    clear
    echo -e "${AZUL}=== LIMPIADOR DE ARCHIVOS INNECESARIOS ===${SIN_COLOR}"
    echo -e "Analizando: ${AMARILLO}$CARPETA_OBJETIVO${SIN_COLOR}\n"

    local candidatos=()
    while IFS= read -r -d '' f; do
        candidatos+=("$f")
    done < <(find "$CARPETA_OBJETIVO" -maxdepth 1 -type f \( -name "*.tmp" -o -name "*.bak" -o -size 0 \) -print0)

    if [ ${#candidatos[@]} -eq 0 ]; then
        echo -e "${VERDE}¡Todo limpio! No se encontraron archivos temporales ni vacíos.${SIN_COLOR}"
        pausar
        return
    fi

    echo "Se encontraron los siguientes archivos:"
    for item in "${candidatos[@]}"; do
        echo -e " - ${ROJO}$(basename "$item")${SIN_COLOR}"
    done

    echo ""
    read -rp "¿Deseas eliminar estos ${#candidatos[@]} archivos permanentemente? (s/n): " confirmar

    if [[ "$confirmar" == "s" || "$confirmar" == "S" ]]; then
        for item in "${candidatos[@]}"; do
            rm -f "$item"
        done
        echo -e "${VERDE}Archivos eliminados correctamente.${SIN_COLOR}"
        registrar_evento "Eliminados ${#candidatos[@]} archivos basura en $CARPETA_OBJETIVO."
    else
        echo "Operación cancelada. No se borró nada."
    fi

    pausar
}


# Módulo 4: Cambiar carpeta de trabajo

cambiar_carpeta() {
    clear
    echo -e "${AZUL}=== CAMBIAR CARPETA OBJETIVO ===${SIN_COLOR}"
    echo -e "Ruta actual: ${AMARILLO}$CARPETA_OBJETIVO${SIN_COLOR}\n"
    read -rp "Escribe la nueva ruta (ej. /tmp): " nueva_ruta

    if [ -d "$nueva_ruta" ]; then
        CARPETA_OBJETIVO="$nueva_ruta"
        echo -e "${VERDE}Carpeta actualizada con éxito.${SIN_COLOR}"
        registrar_evento "Cambio de carpeta objetivo a $CARPETA_OBJETIVO."
    else
        echo -e "${ROJO}La ruta no es válida o no existe.${SIN_COLOR}"
    fi
    pausar
}


# Bucle principal (Menú)

while true; do
    clear
    echo -e "${AZUL}========================================${SIN_COLOR}"
    echo -e "${AZUL}       HOMELAB LOCAL - CONTROL PANEL    ${SIN_COLOR}"
    echo -e "${AZUL}========================================${SIN_COLOR}"
    echo -e "Carpeta activa: ${AMARILLO}$CARPETA_OBJETIVO${SIN_COLOR}\n"
    echo "1. Monitor de salud (Discos, RAM y Red)"
    echo "2. Organizar archivos por categoría"
    echo "3. Limpiar archivos temporales y vacíos"
    echo "4. Cambiar carpeta de trabajo"
    echo "5. Ver historial de actividad (Logs)"
    echo "6. Salir"
    echo ""
    read -rp "Selecciona una opción [1-6]: " opcion

    case "$opcion" in
        1) monitor_salud ;;
        2) organizar_archivos ;;
        3) limpiar_basura ;;
        4) cambiar_carpeta ;;
        5)
            clear
            echo -e "${AZUL}=== HISTORIAL DE ACTIVIDAD ===${SIN_COLOR}\n"
            if [ -f "$ARCHIVO_LOG" ]; then
                cat "$ARCHIVO_LOG"
            else
                echo "Aún no hay registros guardados."
            fi
            pausar
            ;;
        6)
            echo -e "\n${VERDE}Cerrando Homelab Local. ¡Hasta luego!${SIN_COLOR}"
            exit 0
            ;;
        *)
            echo -e "\n${ROJO}Opción inválida.${SIN_COLOR}"
            sleep 1
            ;;
    esac
done
