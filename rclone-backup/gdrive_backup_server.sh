#!/bin/bash

# ─────────────────────────────────────────
#   Google Drive Backup Script — Docker
#   (Navidrome & Jellyfin)
#   Uses: rclone sync
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
    ["navidrome"]="cache/**"
    ["jellyfin"]="metadata/**,cache/**,transcodes/**"
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
echo "║       Google Drive Sync — Docker     ║"
echo "╚══════════════════════════════════════╝"
echo -e "${NC}"
echo -e "Started at: $(date '+%d-%m-%Y %H:%M:%S')\n"

# ── Check + stop containers (only if running), restart right after sync ──
# NOTE: docker state is ONLY used to decide whether to stop/start the
# container for a consistent snapshot. It does NOT gate whether we sync —
# the data folder on disk is backed up regardless of whether the container
# currently exists in Docker (e.g. after `docker compose down`, a removed
# container, or one that hasn't been (re)created yet).
declare -A WAS_RUNNING

check_and_stop_containers() {
    for c in "${DOCKER_CONTAINERS[@]}"; do
        STATE=$(docker inspect -f '{{.State.Running}}' "$c" 2>/dev/null)

        if [ "$STATE" == "true" ]; then
            WAS_RUNNING["$c"]=1
            echo -e "${YELLOW}⏸  $c is running — stopping for consistent snapshot${NC}"
            docker stop "$c" >/dev/null 2>&1
        elif [ "$STATE" == "false" ]; then
            echo -e "${CYAN}ℹ  $c already stopped — leaving it as is${NC}"
        else
            echo -e "${CYAN}ℹ  $c container not found — will still sync its data folder if present${NC}"
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
        IFS=',' read -ra PATTERNS <<< "${DOCKER_EXCLUDES[$c]}"
        for pattern in "${PATTERNS[@]}"; do
            EXCLUDE_ARGS+=(--exclude "$pattern")
        done
    fi

    rclone sync "$LOCAL_PATH" "$REMOTE/$REMOTE_NAME" -P \
    "${EXCLUDE_ARGS[@]}" \
    --fast-list \
    --checkers 16 \
    --transfers 16 \
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

# ── Summary ──────────────────────────────
echo -e "${CYAN}══════════════════════════════════════${NC}"
echo -e "${CYAN}  Sync Summary — Docker${NC}"
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
