#!/usr/bin/env bash


# Configuración y variables

CARPETA_OBJETIVO="$HOME/Downloads"
ARCHIVO_LOG="./homelab.log"

# Colores para la terminal
VERDE='\033[0;32m'
AMARILLO='\033[1;33m'
ROJO='\033[0;31m'
AZUL='\033[0;36m'
SIN_COLOR='\033[0m'

# Funciones 

registrar_evento() {
    local mensaje="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $mensaje" >> "$ARCHIVO_LOG"
}

pausar() {
    echo ""
    read -rp "Presiona [Enter] para volver al menú..."
}

# Módulo 1: Monitor de salud 

monitor_salud() {
    clear
    echo -e "${AZUL}=== MONITOR DE SALUD DEL SISTEMA ===${SIN_COLOR}\n"

    echo -e "${AMARILLO}[1] Espacio en discos:${SIN_COLOR}"
    df -h | grep -E "Filesystem|C:|D:"
    echo ""

    echo -e "${AMARILLO}[2] Memoria RAM (Windows):${SIN_COLOR}"
    
    powershell.exe -NoProfile -Command "
        \$os = Get-CimInstance Win32_OperatingSystem;
        \$total = [math]::Round(\$os.TotalVisibleMemorySize / 1MB, 2);
        \$libre = [math]::Round(\$os.FreePhysicalMemory / 1MB, 2);
        Write-Host \"Total: \$total GB | Libre: \$libre GB\"
    "
    echo ""

    echo -e "${AMARILLO}[3] Estado de conexión a Internet:${SIN_COLOR}"
    if ping -n 1 8.8.8.8 > /dev/null 2>&1; then
        echo -e "Conexión: ${VERDE}EN LÍNEA${SIN_COLOR}"
    else
        echo -e "Conexión: ${ROJO}SIN INTERNET${SIN_COLOR}"
    fi

    registrar_evento "Consulta de estado de salud del sistema."
    pausar
}

#Modulo 2: Organizador

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

#Dentro de carpeta
for archivo in "$CARPETA_OBJETIVO"/*; do
[ -f "$archivo"] || continue

local nombre_base
nombre_base=$(basename "$archivo")
local extension="${nombre_base##*.}"
extension=$(echo "$extension"  | tr '[:upper:]' '[:lower:]')

local destino==""

case "$extension" in
  jpg|jpeg|png|gif|webp|svg)
  destino="Imagenes"
  ;;
    mp4|mkv|avi|mov|flv)
    destino="Videos
    ;;
    pdf|doc|docx|txt|xlsx|pptx|csv)
    destino="Documentos"
    ;;
    mp3|wav|flac|aac)
    destino="Musica"
    ;;
    zip|rar|7z|tar|gz)
    destino="Comprimidos"
    exe|msi)
 destino="Instaladores"
     ;;
    *)
    Continue
    ;;
    esac

mkdir -p "$CARPETA_OBJETIVO/$destino"
mv "$archivo" "$CARPETA_OBJETIVO/$destino/"
((movidos++))
done

echo -e "${VERDE}nombre_base${SIN_COLOR} --> $destino/"
((movidos++)
done

echo -e "\nTotal de archivos organizados : ${VERDEvidos${SIN_COLOR}"
registar_ejvento "Organizados $movidos archivos en $CARPETA_OBJETIVO."
pausar
}

#Moulo: Limpiador

limpiar_basura() {
clear
echo -e "${AZUL}=== LIMPIADOR DE ARCHIVOS INNECESARIOS ===${SIN_COLOR}"
echo -e "Analizando: ${AMARILLO}$CARPETA_OBJETIVO${SIN_COLOR}\n"

#Busca archivos temporales

local candidatos=()
while IFS= read -r -d '' f; do
candidatos+=("$f")
done  < <(find "$CARPETA_OBJETIVO" -maxdepth 1 -type f \( -name "*.tmp" -o -name "*.log" -o -name "*.bak" \) -print0)

if [ ${#candidatos[@]} -eq 0 ]; then
echo -e "${VERDE} Todo quedo limpio!, No se encontraron archivos temporales o de registro.${SIN_COLOR}"
pausar
return
fi

echo "Se encontraron los siguientes archivos:"
for item in "${candidatos[@]}"; do
echo -e " - ${ROJO}$(basename "$item")${SIN_COLOR}"
done

echo""
read -rp "Deseas eliminar estos ${"confirmar" == "S" ]]; then
for item in "${candidatos[@]}"; do
rm -f "$item"
done
echo -e "${VERDE}Archivos eliminados correctamente.${SIN_COLOR}"
registrar_evento "Eliminados ${#candidatos[@]} archivos basura en $CARPETA_OBJETIVO."
else
echo "Operacion cancelada. No se ha eliminado nada."
fi

pausar
}

#Modulo 4: Camiar carpeta

cambiar_carpeta() [
    clear
    echo -e "${AZUL}=== CAMBIAR CARPETA ===${SIN_COLOR}"
    echo -e "Ruta actual: ${AMARILLO}$CARPETA_OBJETIVOS${SIN_COLOR}\n"
    read -rp "Escribe la nueva ruta de la carpeta: " nueva_ruta

    if [-d "$nueva_ruta" ]; then
    CARPETA_OBJETIVO="$nueva_ruta"
    echo -e "${VERDE}Carpeta actualizada.${SIN_COLOR}"
    registar_evento "Cambio de carpeta objetivo a $CARPETA_OBJETIVO."
    else
    echo -e "${ROJO}La ruta no es valida o no existe.${SIN_CCOLOR)"
    fi
    pausar
]

#Bucle principal 
While true; do
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


fabbbbbbnnnnnnnnnnnnnnnnnnnnnnnnnnnnnhjhbbb nnhhhhhhhhhhhhhhhhhhhbbbbkkkkkj
jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjhhhhhjhjhjjjhhjjhjj
hhhhhbbbbbbbbbbbbbbbbbbhjggññññññññññññññññññññññññññññññññññññññññññññññññ
ddddddddd23daaa afafafafafaffffffafafadddgggggggggggggggjjjjjjjjjsssssssssssss