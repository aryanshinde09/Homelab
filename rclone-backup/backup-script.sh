#!/bin/bash

# ─────────────────────────────────────────
#   Google Drive Backup Script
#   Uses: rclone sync / copy
# ─────────────────────────────────────────

REMOTE="gdrive:Backups"

# ── Docker container + its live volume path ────────────
# Navidrome keeps its SQLite DB open while running — we stop it,
# upload navidrome.db straight from its live path, then restart.
DOCKER_CONTAINERS=("navidrome")              # <-- match `docker ps --format '{{.Names}}'`
NAVIDROME_LIVE="/opt/docker/navidrome/data"     # <-- set to your actual host bind-mount path
NAVIDROME_DB="$NAVIDROME_LIVE/navidrome.db"

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
echo "║       Google Drive Sync              ║"
echo "╚══════════════════════════════════════╝"
echo -e "${NC}"
echo -e "Started at: $(date '+%d-%m-%Y %H:%M:%S')\n"

# ── Stop containers (only if running), stage locally, restart right away ──
declare -A WAS_RUNNING

stop_containers() {
    for c in "${DOCKER_CONTAINERS[@]}"; do
        STATE=$(docker inspect -f '{{.State.Running}}' "$c" 2>/dev/null)

        if [ "$STATE" == "true" ]; then
            WAS_RUNNING["$c"]=1
            echo -e "${YELLOW}⏸  $c is running — stopping for local snapshot${NC}"
            docker stop "$c" >/dev/null 2>&1
        elif [ "$STATE" == "false" ]; then
            echo -e "${CYAN}ℹ  $c already stopped — leaving it as is${NC}"
        else
            echo -e "${RED}⚠  $c not found — skipping${NC}"
        fi
    done
}

start_containers() {
    for c in "${!WAS_RUNNING[@]}"; do
        echo -e "${YELLOW}▶  Restarting $c (was running before backup)${NC}"
        docker start "$c" >/dev/null 2>&1
    done
    # only restart once — clear so a later trap call is a no-op
    WAS_RUNNING=()
}

# Safety net: if the script dies partway through staging, still restart
# whatever we stopped. Harmless no-op if start_containers already ran.
trap start_containers EXIT

stop_containers

echo -e "${YELLOW}📥 Uploading navidrome.db to Drive...${NC}"
rclone copyto "$NAVIDROME_DB" "$REMOTE/Navidrome-Data/navidrome.db" -P \
--checkers 4 \
--transfers 4 \
--retries 5 \
--retries-sleep 30s

if [ $? -eq 0 ]; then
    echo -e "   ${GREEN}✓ Done${NC}\n"
else
    echo -e "   ${RED}✗ Failed${NC}\n"
fi

start_containers

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
echo -e "${CYAN}  Sync Summary${NC}"
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