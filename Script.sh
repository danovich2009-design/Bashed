#!/usr/bin/env bash

# ==========================================
# Configuration & Global Variables
# ==========================================
TARGET_DIR="./test_zone"
BACKUP_DIR="./backups"
LOG_FILE="./homelab.log"

# Automatically create sample files if target directory doesn't exist (ideal for demos)
if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
    touch "$TARGET_DIR/vacation_photo.jpg" \
          "$TARGET_DIR/class_notes.pdf" \
          "$TARGET_DIR/project_report.docx" \
          "$TARGET_DIR/demo_track.mp3" \
          "$TARGET_DIR/old_backup.tmp" \
          "$TARGET_DIR/empty_file.txt"
    echo "Sample data for duplicate check" > "$TARGET_DIR/copy_1.txt"
    echo "Sample data for duplicate check" > "$TARGET_DIR/copy_2.txt"
fi

# Terminal colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# ==========================================
# Helper Functions
# ==========================================
log_event() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$LOG_FILE"
}

pause() {
    echo ""
    read -rp "Press [Enter] to return to the menu..."
}

print_header() {
    local title="$1"
    clear
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  $title${NC}"
    echo -e "${CYAN}========================================${NC}\n"
}

# ==========================================
# Module 1: System Health Monitor
# ==========================================
health_monitor() {
    print_header "SYSTEM HEALTH MONITOR"

    echo -e "${YELLOW}Host & Uptime:${NC}"
    echo "Hostname: $(hostname)"
    if command -v uptime > /dev/null 2>&1; then
        echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
    fi
    echo ""

    echo -e "${YELLOW}Disk Space:${NC}"
    df -h | grep -E "Filesystem|C:|D:|/$"
    echo ""

    echo -e "${YELLOW}Memory (RAM):${NC}"
    if command -v free > /dev/null 2>&1; then
        free -h | awk '/^Mem:/ {print "Total: " $2 " | Used: " $3 " | Free: " $4}'
    elif command -v powershell.exe > /dev/null 2>&1; then
        powershell.exe -NoProfile -Command "
            \$os = Get-CimInstance Win32_OperatingSystem;
            \$total = [math]::Round(\$os.TotalVisibleMemorySize / 1MB, 2);
            \$free = [math]::Round(\$os.FreePhysicalMemory / 1MB, 2);
            Write-Host \"Total: \$total GB | Free: \$free GB\"
        "
    fi
    echo ""

    echo -e "${YELLOW}Internet Connection Status:${NC}"
    if curl -Is --connect-timeout 3 https://1.1.1 > /dev/null 2>&1 || curl -Is --connect-timeout 3 https://google.com > /dev/null 2>&1; then
        echo -e "Connection: ${GREEN}ONLINE${NC}"
    else
        echo -e "Connection: ${RED}OFFLINE${NC}"
    fi

    log_event "Checked system health status."
    pause
}

# ==========================================
# Module 2: File Organizer
# ==========================================
organize_files() {
    print_header "FILE ORGANIZER"
    echo -e "Current folder: ${YELLOW}$TARGET_DIR${NC}\n"

    if [ ! -d "$TARGET_DIR" ]; then
        echo -e "${RED}Error: Directory does not exist.${NC}"
        pause
        return
    fi

    local moved=0

    for file in "$TARGET_DIR"/*; do
        [ -f "$file" ] || continue

        local base_name
        base_name=$(basename "$file")
        local extension="${base_name##*.}"
        extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')

        local destination=""
        case "$extension" in
            jpg|jpeg|png|gif|webp|svg)
                destination="Images"
                ;;
            pdf|doc|docx|txt|xlsx|pptx|csv|md)
                destination="Documents"
                ;;
            mp4|mkv|avi|mov|webm)
                destination="Videos"
                ;;
            mp3|wav|flac|ogg|m4a)
                destination="Audio"
                ;;
            zip|rar|7z|tar|gz)
                destination="Archives"
                ;;
            exe|msi|sh|py|js)
                destination="Scripts_and_Apps"
                ;;
            *)
                destination="Misc"
                ;;
        esac

        mkdir -p "$TARGET_DIR/$destination"
        mv "$file" "$TARGET_DIR/$destination/"
        echo -e "Moved: ${GREEN}$base_name${NC} -> $destination/"
        ((moved++))
    done

    echo -e "\nTotal files organized: ${GREEN}$moved${NC}"
    log_event "Organized $moved files in $TARGET_DIR."
    pause
}

# ==========================================
# Module 3: Safe Junk Cleaner
# ==========================================
clean_junk() {
    print_header "JUNK & TEMP FILE CLEANER"
    echo -e "Scanning: ${YELLOW}$TARGET_DIR${NC}\n"

    local candidates=()
    while IFS= read -r -d '' f; do
        candidates+=("$f")
    done < <(find "$TARGET_DIR" -maxdepth 2 -type f \( -name "*.tmp" -o -name "*.bak" -o -name "*.swp" -o -size 0 \) -print0)

    if [ ${#candidates[@]} -eq 0 ]; then
        echo -e "${GREEN}All clean! No temporary or empty files found.${NC}"
        pause
        return
    fi

    echo "The following files were found:"
    for item in "${candidates[@]}"; do
        echo -e " - ${RED}$item${NC}"
    done

    echo ""
    read -rp "Do you want to permanently delete these ${#candidates[@]} files? (y/n): " confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        for item in "${candidates[@]}"; do
            rm -f "$item"
        done
        echo -e "${GREEN}Files deleted successfully.${NC}"
        log_event "Deleted ${#candidates[@]} junk files in $TARGET_DIR."
    else
        echo "Operation canceled. Nothing was deleted."
    fi

    pause
}

# ==========================================
# Module 4: Automated Compressed Backups
# ==========================================
create_backup() {
    print_header "AUTOMATED BACKUP MANAGER"

    if [ ! -d "$TARGET_DIR" ]; then
        echo -e "${RED}Error: Target directory '$TARGET_DIR' does not exist.${NC}"
        pause
        return
    fi

    mkdir -p "$BACKUP_DIR"
    local timestamp
    timestamp=$(date '+%Y%m%d_%H%M%S')
    local folder_name
    folder_name=$(basename "$TARGET_DIR")
    local backup_file="$BACKUP_DIR/${folder_name}_backup_${timestamp}.tar.gz"

    echo -e "Compressing ${YELLOW}$TARGET_DIR${NC}..."
    if tar -czf "$backup_file" -C "$(dirname "$TARGET_DIR")" "$folder_name" 2>/dev/null; then
        local size
        size=$(du -h "$backup_file" | cut -f1)
        echo -e "${GREEN}✔ Backup created successfully!${NC}"
        echo -e "File: ${CYAN}$backup_file${NC} ($size)"
        log_event "Created backup $backup_file ($size)."
    else
        echo -e "${RED}Failed to create backup archive.${NC}"
        log_event "Backup failed for $TARGET_DIR."
    fi

    echo -e "\n${YELLOW}Existing Backups:${NC}"
    ls -lh "$BACKUP_DIR" 2>/dev/null | awk 'NR>1 {print " - " $9 " (" $5 ")"}'
    pause
}

# ==========================================
# Module 5: Storage & Duplicate Audit
# ==========================================
storage_audit() {
    print_header "STORAGE & DUPLICATE FILE AUDIT"
    echo -e "Analyzing: ${YELLOW}$TARGET_DIR${NC}\n"

    if [ ! -d "$TARGET_DIR" ]; then
        echo -e "${RED}Directory not found.${NC}"
        pause
        return
    fi

    local total_files
    total_files=$(find "$TARGET_DIR" -type f | wc -l)
    local total_size
    total_size=$(du -sh "$TARGET_DIR" 2>/dev/null | cut -f1)

    echo -e "Total files: ${GREEN}$total_files${NC}"
    echo -e "Total folder size: ${GREEN}$total_size${NC}\n"

    echo -e "${YELLOW}Top 5 Largest Files:${NC}"
    find "$TARGET_DIR" -type f -exec du -h {} + 2>/dev/null | sort -rh | head -n 5 | awk '{print " - " $2 " (" $1 ")"}'
    echo ""

    echo -e "${YELLOW}Duplicate File Check (SHA-256):${NC}"
    if command -v sha256sum > /dev/null 2>&1; then
        local duplicates
        duplicates=$(find "$TARGET_DIR" -type f -exec sha256sum {} + 2>/dev/null | sort | uniq -w64 -D)
        if [ -n "$duplicates" ]; then
            echo -e "${RED}Duplicate files detected:${NC}"
            echo "$duplicates" | awk '{print " - [" substr($1,1,10) "...] " $2}'
        else
            echo -e "${GREEN}No exact duplicate files found.${NC}"
        fi
    else
        echo "sha256sum utility not available on this system."
    fi

    log_event "Ran storage and duplicate audit on $TARGET_DIR."
    pause
}

# ==========================================
# Module 6: Process & Network Inspector
# ==========================================
network_and_processes() {
    print_header "PROCESS & NETWORK INSPECTOR"

    echo -e "${YELLOW}Local Network Interfaces:${NC}"
    if command -v ip > /dev/null 2>&1; then
        ip -brief addr show 2>/dev/null
    elif command -v hostname > /dev/null 2>&1; then
        hostname -I 2>/dev/null || echo "Local IP check unavailable."
    fi
    echo ""

    echo -e "${YELLOW}Top Running Processes:${NC}"
    if ps aux > /dev/null 2>&1; then
        ps aux --sort=-%mem 2>/dev/null | head -n 6 | awk '{printf "%-10s %-8s %-6s %s\n", $1, $2, $4"%", $11}'
    else
        ps -ef | head -n 6
    fi

    log_event "Inspected running processes and network info."
    pause
}

# ==========================================
# Module 7: Change Working Directory
# ==========================================
change_directory() {
    print_header "CHANGE TARGET DIRECTORY"
    echo -e "Current path: ${YELLOW}$TARGET_DIR${NC}\n"
    read -rp "Enter the new path (e.g., /tmp or ./test_zone): " new_path

    if [ -d "$new_path" ]; then
        TARGET_DIR="$new_path"
        echo -e "${GREEN}Directory updated successfully.${NC}"
        log_event "Changed target directory to $TARGET_DIR."
    else
        echo -e "${RED}Invalid path or directory does not exist.${NC}"
    fi
    pause
}

# ==========================================
# Main Menu Loop
# ==========================================
while true; do
    clear

echo -e "${PURPLE}========================================${NC}"
echo -e "${PURPLE}       LOCAL HOMELAB - CONTROL PANEL    ${NC}"
echo -e "${PURPLE}========================================${NC}"
echo -e "Active folder: ${YELLOW}$TARGET_DIR${NC}\n"
echo "1. System health monitor (Disks, RAM & Network)"
echo "2. Organize files by category"
echo "3. Clean temporary and empty files"
echo "4. Create compressed backup (.tar.gz)"
echo "5. Storage & duplicate file audit"
echo "6. Process & network inspector"
echo "7. Change working directory"
echo "8. View or clear activity logs"
echo "9. Exit"
echo ""
read -rp "Select an option [1-9]: " option
case "$option" in
1) health_monitor ;;
2) organize_files ;;
3) clean_junk ;;
4) create_backup ;;
5) storage_audit ;;
6) network_and_processes ;;
7) change_directory ;;
8)
print_header "ACTIVITY HISTORY (LOGS)"
if [ -f "$LOG_FILE" ]; then
cat "$LOG_FILE"
echo ""
read -rp "Do you want to clear the log file? (y/n): " clear_log
if [[ "$clear_log" == "y" || "$clear_log" == "Y" ]]; then
> "$LOG_FILE"
echo -e "${GREEN}Logs cleared.${NC}"
fi
else
echo "No logs recorded yet."
fi
pause
;;
9)
echo -e "\n${GREEN}Shutting down Local Homelab. Goodbye!${NC}"
exit 0
;;
*)
echo -e "\n${RED}Invalid option.${NC}"
sleep 1
;;
esac
done
