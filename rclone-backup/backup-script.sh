#!/bin/bash

# ─────────────────────────────────────────
#   Google Drive Backup Script
#   Uses: rclone sync / copy
# ─────────────────────────────────────────

REMOTE="gdrive:Backups"

# ── Docker containers + their live volume paths ────────
# Navidrome & Jellyfin keep their SQLite DBs open while running — we stop
# them, sync their FULL data/config folders, then restart.
DOCKER_CONTAINERS=("navidrome" "jellyfin")   # <-- match `docker ps --format '{{.Names}}'`

declare -A DOCKER_PATHS=(                    # <-- set to your actual host bind-mount paths
    ["navidrome"]="/opt/docker/navidrome/data"
    ["jellyfin"]="/opt/docker/jellyfin/config"
)

declare -A DOCKER_REMOTE_NAMES=(
    ["navidrome"]="Navidrome-Data"
    ["jellyfin"]="Jellyfin-Config"
)

# Optional per-container excludes (rclone --exclude patterns, relative to
# the container's LOCAL_PATH above). Leave a container out of this map to
# sync it in full.
declare -A DOCKER_EXCLUDES=(
    ["jellyfin"]="metadata/**"
)

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

# ── Check + stop containers (only if running), restart right after sync ──
declare -A WAS_RUNNING
declare -A CONTAINER_FOUND

check_and_stop_containers() {
    for c in "${DOCKER_CONTAINERS[@]}"; do
        STATE=$(docker inspect -f '{{.State.Running}}' "$c" 2>/dev/null)

        if [ "$STATE" == "true" ]; then
            CONTAINER_FOUND["$c"]=1
            WAS_RUNNING["$c"]=1
            echo -e "${YELLOW}⏸  $c is running — stopping for consistent snapshot${NC}"
            docker stop "$c" >/dev/null 2>&1
        elif [ "$STATE" == "false" ]; then
            CONTAINER_FOUND["$c"]=1
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

# ── Track results ────────────────────────
SUCCESS=()
FAILED=()

check_and_stop_containers

# ── Sync FULL data/config folders while containers are stopped ──────────
for c in "${DOCKER_CONTAINERS[@]}"; do
    LOCAL_PATH="${DOCKER_PATHS[$c]}"
    REMOTE_NAME="${DOCKER_REMOTE_NAMES[$c]}"

    if [ -z "${CONTAINER_FOUND[$c]}" ]; then
        echo -e "${RED}✗ Skipping $c data — container not found${NC}\n"
        FAILED+=("$c data (container not found)")
        continue
    fi

    echo -e "${YELLOW}📦 Syncing $c: $LOCAL_PATH${NC}"
    echo -e "   To : $REMOTE/$REMOTE_NAME"

    if [ ! -d "$LOCAL_PATH" ]; then
        echo -e "   ${RED}✗ Skipped — folder not found${NC}\n"
        FAILED+=("$c data (folder not found)")
        continue
    fi

    EXCLUDE_ARGS=()
    if [ -n "${DOCKER_EXCLUDES[$c]}" ]; then
        echo -e "   Excluding : ${DOCKER_EXCLUDES[$c]}"
        EXCLUDE_ARGS=(--exclude "${DOCKER_EXCLUDES[$c]}")
    fi

    rclone sync "$LOCAL_PATH" "$REMOTE/$REMOTE_NAME" -P \
    "${EXCLUDE_ARGS[@]}" \
    --checkers 4 \
    --transfers 4 \
    --retries 5 \
    --retries-sleep 30s

    if [ $? -eq 0 ]; then
        echo -e "   ${GREEN}✓ Done${NC}\n"
        SUCCESS+=("$c data")
    else
        echo -e "   ${RED}✗ Failed${NC}\n"
        FAILED+=("$c data")
    fi
done

start_containers

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