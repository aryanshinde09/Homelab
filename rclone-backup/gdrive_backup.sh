#!/bin/bash

# ─────────────────────────────────────────
#   Google Drive Backup Script — Folders
#   Uses: rclone sync
# ─────────────────────────────────────────

REMOTE="gdrive:Backups"

# ── Folders to back up ──────────────────
declare -A FOLDERS=(
    ["Documents"]="$HOME/Documents"
    ["Pictures"]="$HOME/Pictures"
    ["Desktop"]="$HOME/Desktop"
    ["Music"]="/mnt/hdd/Music"
    ["Resumes"]="/mnt/hdd/Resumes"
    ["Obsidian"]="/mnt/hdd/obsidian"
)

# ── Colors ───────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ── Header ───────────────────────────────
echo -e "${CYAN}"
echo "╔══════════════════════════════════════╗"
echo "║       Google Drive Sync — Folders    ║"
echo "╚══════════════════════════════════════╝"
echo -e "${NC}"
echo -e "Started at: $(date '+%d-%m-%Y %H:%M:%S')\n"

# ── Track results ────────────────────────
SUCCESS=()
FAILED=()

# ── Run backups ──────────────────────────
for NAME in "${!FOLDERS[@]}"; do
    PATH_LOCAL="${FOLDERS[$NAME]}"
    PATH_REMOTE="$REMOTE/$NAME"

    echo -e "${YELLOW}📁 Backing up: $NAME${NC}"
    echo -e "   From : $PATH_LOCAL"
    echo -e "   To   : $PATH_REMOTE"

    # Check if folder exists before trying to back up
    if [ ! -d "$PATH_LOCAL" ]; then
        echo -e "   ${RED}✗ Skipped — folder not found${NC}\n"
        FAILED+=("$NAME (folder not found)")
        continue
    fi

    # Run rclone
    rclone sync "$PATH_LOCAL" "$PATH_REMOTE" -P \
    --checkers 4 \
    --transfers 4 \
    --retries 5 \
    --retries-sleep 30s

    if [ $? -eq 0 ]; then
        echo -e "   ${GREEN}✓ Done${NC}\n"
        SUCCESS+=("$NAME")
    else
        echo -e "   ${RED}✗ Failed${NC}\n"
        FAILED+=("$NAME")
    fi
done

# ── Summary ──────────────────────────────
echo -e "${CYAN}══════════════════════════════════════${NC}"
echo -e "${CYAN}  Sync Summary — Folders${NC}"
echo -e "${CYAN}══════════════════════════════════════${NC}"
echo -e "Finished at: $(date '+%d-%m-%Y %H:%M:%S')\n"

if [ ${#SUCCESS[@]} -gt 0 ]; then
    echo -e "${GREEN}✓ Successful (${#SUCCESS[@]}):${NC}"
    for item in "${SUCCESS[@]}"; do
        echo -e "   • $item"
    done
fi

if [ ${#FAILED[@]} -gt 0 ]; then
    echo -e "\n${RED}✗ Failed (${#FAILED[@]}):${NC}"
    for item in "${FAILED[@]}"; do
        echo -e "   • $item"
    done
fi

echo -e "\n${GREEN}Sync complete! ✓${NC}"
