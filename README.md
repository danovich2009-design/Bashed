#  Indahouse - Local Homelab Control Panel

A terminal-based local homelab control panel written in pure Bash, featuring real-time system health monitoring, automated file organization, safe junk cleanup, compressed backups, and duplicate file detection.

---

## Features

1. **System Health Monitor:**
   - Displays system hostname and uptime.
   - Checks available and used disk space across drives.
   - Reads real-time RAM usage (cross-platform support for Linux `free -h` and Windows Git Bash).
   - Verifies active internet connectivity via HTTPS checks.

2. **Automated File Organizer:**
   - Automatically sorts files inside a target directory into categorized subfolders:
     - `Images` (`.jpg`, `.jpeg`, `.png`, `.gif`, `.webp`, `.svg`)
     - `Documents` (`.pdf`, `.doc`, `.docx`, `.txt`, `.xlsx`, `.pptx`, `.csv`, `.md`)
     - `Videos` (`.mp4`, `.mkv`, `.avi`, `.mov`, `.webm`)
     - `Audio` (`.mp3`, `.wav`, `.flac`, `.ogg`, `.m4a`)
     - `Archives` (`.zip`, `.rar`, `.7z`, `.tar`, `.gz`)
     - `Scripts_and_Apps` (`.exe`, `.msi`, `.sh`, `.py`, `.js`)
     - `Misc` (other file extensions)

3. **Safe Junk & Temp Cleaner:**
   - Scans for temporary files (`.tmp`, `.bak`, `.swp`) and empty `0-byte` files.
   - Lists every detected file and requires explicit user confirmation (`y/n`) before deletion.

4. **Automated Compressed Backups:**
   - Creates timestamped `.tar.gz` archives of the active working directory inside `./backups`.
   - Lists existing backup archives along with their file sizes.

5. **Storage & Duplicate File Audit:**
   - Calculates total file count and directory size.
   - Identifies the top 5 largest files.
   - Detects exact duplicate files using `SHA-256` checksums.

6. **Process & Network Inspector + Activity Logs:**
   - Displays local network interfaces and top memory-consuming processes.
   - Records timestamped actions in `homelab.log` with an option to view or clear logs from the menu.




