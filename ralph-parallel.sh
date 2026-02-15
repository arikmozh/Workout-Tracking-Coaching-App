#!/bin/bash
set -e

# --- Argument parsing ---
START_WAVE="A"
DRY_RUN=0
SLEEP_SECONDS=5

while [[ $# -gt 0 ]]; do
    case "$1" in
        --start-wave|-w)
            START_WAVE="$2"
            shift 2
            ;;
        --dry-run|-d)
            DRY_RUN=1
            shift
            ;;
        --sleep|-s)
            SLEEP_SECONDS="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"

# --- Colors ---
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# --- Ctrl+C handler ---
cleanup() {
    echo ""
    echo -e "${YELLOW}Orchestrator stopped by user.${NC}"
    # Clean up any worktrees
    for wt in "$REPO_ROOT"/../Workout-phase-*; do
        if [ -d "$wt" ]; then
            phase_num=$(basename "$wt" | sed 's/Workout-phase-//')
            echo -e "${YELLOW}  Cleaning up worktree: $wt${NC}"
            git -C "$REPO_ROOT" worktree remove "$wt" --force 2>/dev/null || true
            git -C "$REPO_ROOT" branch -d "phase-$phase_num" 2>/dev/null || true
        fi
    done
    exit 1
}
trap cleanup INT TERM

# --- Wave Definitions ---

WAVE_ORDER=("A" "B" "C" "D" "E" "F")

# Wave config: PHASES MODE DESCRIPTION
declare -A WAVE_PHASES WAVE_MODES WAVE_DESCS
WAVE_PHASES[A]="1 2 3 4 5 6 7"
WAVE_PHASES[B]="8 9 14"
WAVE_PHASES[C]="10 13"
WAVE_PHASES[D]="11"
WAVE_PHASES[E]="12"
WAVE_PHASES[F]="15"

WAVE_MODES[A]="sequential"
WAVE_MODES[B]="parallel"
WAVE_MODES[C]="parallel"
WAVE_MODES[D]="sequential"
WAVE_MODES[E]="sequential"
WAVE_MODES[F]="sequential"

WAVE_DESCS[A]="Foundation (setup, types, auth, i18n, nav, CRUD, clients)"
WAVE_DESCS[B]="Monitoring + Trainee Programs + Settings"
WAVE_DESCS[C]="Trainee Logging + Push Notifications"
WAVE_DESCS[D]="Trainee History"
WAVE_DESCS[E]="Progress Charts"
WAVE_DESCS[F]="Polish & Hardening"

FILES_TO_COPY="ralph.ps1 ralph.sh ralph-prompt.txt PRD.md progress.txt"

# --- Functions ---

show_wave_plan() {
    echo -e "${CYAN}==========================================="
    echo -e "  Ralph Parallel Orchestrator — Wave Plan"
    echo -e "==========================================${NC}"
    echo ""

    for wave_name in "${WAVE_ORDER[@]}"; do
        local phases="${WAVE_PHASES[$wave_name]}"
        local mode="${WAVE_MODES[$wave_name]}"
        local desc="${WAVE_DESCS[$wave_name]}"
        local marker=""
        [ "$wave_name" = "$START_WAVE" ] && marker=" <-- START"

        echo -e "${CYAN}  Wave $wave_name [$mode]: Phases $phases$marker${NC}"
        echo "    $desc"
    done
    echo ""
}

create_worktree() {
    local phase_num="$1"
    local worktree_path="$(dirname "$REPO_ROOT")/Workout-phase-$phase_num"
    local branch_name="phase-$phase_num"

    echo -e "${CYAN}  >> Creating worktree: $worktree_path (branch: $branch_name)${NC}"

    git -C "$REPO_ROOT" worktree add "$worktree_path" -b "$branch_name" 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}  >> Failed to create worktree for phase $phase_num${NC}"
        return 1
    fi

    # Copy ralph files into worktree
    for file in $FILES_TO_COPY; do
        if [ -f "$REPO_ROOT/$file" ]; then
            cp "$REPO_ROOT/$file" "$worktree_path/$file"
        fi
    done

    # Copy existing progress-phase files for cross-phase learnings
    for pf in "$REPO_ROOT"/progress-phase-*.txt; do
        [ -f "$pf" ] && cp "$pf" "$worktree_path/"
    done

    echo "$worktree_path"
}

remove_worktree() {
    local phase_num="$1"
    local worktree_path="$(dirname "$REPO_ROOT")/Workout-phase-$phase_num"
    local branch_name="phase-$phase_num"

    echo -e "${CYAN}  >> Removing worktree: $worktree_path${NC}"

    if [ -d "$worktree_path" ]; then
        git -C "$REPO_ROOT" worktree remove "$worktree_path" --force 2>/dev/null || true
    fi
    git -C "$REPO_ROOT" branch -d "$branch_name" 2>/dev/null || true
}

merge_worktree_branch() {
    local phase_num="$1"
    local branch_name="phase-$phase_num"
    local worktree_path="$(dirname "$REPO_ROOT")/Workout-phase-$phase_num"

    echo -e "${CYAN}  >> Merging $branch_name into main...${NC}"

    # Copy back PRD and progress changes before merge
    if [ -f "$worktree_path/PRD.md" ]; then
        cp "$worktree_path/PRD.md" "$REPO_ROOT/PRD.md"
    fi
    if [ -f "$worktree_path/progress-phase-$phase_num.txt" ]; then
        cp "$worktree_path/progress-phase-$phase_num.txt" "$REPO_ROOT/progress-phase-$phase_num.txt"
    fi

    # Stage and commit changes on main from worktree copy
    cd "$REPO_ROOT"
    git add -A 2>/dev/null || true
    if ! git diff --cached --quiet 2>/dev/null; then
        git commit -m "merge: incorporate phase $phase_num changes" 2>/dev/null || true
    fi

    # Merge the branch
    if ! git merge "$branch_name" --no-ff -m "merge: phase $phase_num complete" 2>&1; then
        echo -e "${RED}  >> Merge conflict on $branch_name! Resolve manually.${NC}"
        echo -e "${RED}  >> After resolving, run: ./ralph-parallel.sh --start-wave <next>${NC}"
        return 1
    fi

    # Consolidate phase progress
    local phase_progress="$REPO_ROOT/progress-phase-$phase_num.txt"
    local main_progress="$REPO_ROOT/progress.txt"
    if [ -f "$phase_progress" ]; then
        echo "" >> "$main_progress"
        echo "---" >> "$main_progress"
        echo "## Phase $phase_num Progress" >> "$main_progress"
        cat "$phase_progress" >> "$main_progress"
        echo -e "${CYAN}  >> Consolidated progress-phase-$phase_num.txt into progress.txt${NC}"
    fi

    return 0
}

run_sequential_wave() {
    local phases=($@)

    for phase in "${phases[@]}"; do
        echo ""
        echo -e "${CYAN}==========================================="
        echo -e "  Running Phase $phase (sequential)"
        echo -e "==========================================${NC}"
        echo ""

        "$REPO_ROOT/ralph.sh" --phase "$phase"
        local exit_code=$?

        if [ $exit_code -ne 0 ]; then
            echo -e "${RED}  >> Phase $phase did not complete successfully (exit code: $exit_code)${NC}"
            echo -e "${RED}  >> Fix issues and rerun: ./ralph-parallel.sh --start-wave <wave>${NC}"
            exit 1
        fi

        echo -e "${GREEN}  >> Phase $phase complete${NC}"
        sleep "$SLEEP_SECONDS"
    done
}

run_parallel_wave() {
    local phases=($@)
    local pids=()
    local worktrees=()

    # Create worktrees and start background processes
    for phase in "${phases[@]}"; do
        echo ""
        echo -e "${CYAN}  Setting up parallel Phase $phase...${NC}"

        local worktree_path
        worktree_path=$(create_worktree "$phase")
        if [ $? -ne 0 ]; then
            echo -e "${RED}  >> Failed to create worktree for phase $phase. Aborting wave.${NC}"
            exit 1
        fi
        worktrees+=("$phase")

        # Start Ralph in background
        (cd "$worktree_path" && ./ralph.sh --phase "$phase") &
        local pid=$!
        pids+=("$pid")

        echo -e "${CYAN}  >> Phase $phase started (PID: $pid)${NC}"
    done

    echo ""
    echo -e "${CYAN}==========================================="
    echo -e "  All parallel phases launched. Waiting..."
    echo -e "  Phases: ${phases[*]}"
    echo -e "==========================================${NC}"

    # Wait for all background processes
    local all_success=1
    for idx in "${!pids[@]}"; do
        local pid="${pids[$idx]}"
        local phase="${phases[$idx]}"

        wait "$pid"
        local exit_code=$?

        if [ $exit_code -eq 0 ]; then
            echo -e "${GREEN}  Phase $phase: completed (PID $pid)${NC}"
        else
            echo -e "${RED}  Phase $phase: failed (PID $pid, exit $exit_code)${NC}"
            all_success=0
        fi
    done

    echo ""
    echo -e "${CYAN}==========================================="
    echo -e "  Merging parallel phases back to main..."
    echo -e "==========================================${NC}"

    # Merge each worktree branch back
    for phase in "${worktrees[@]}"; do
        if ! merge_worktree_branch "$phase"; then
            echo -e "${RED}  >> Merge failed for phase $phase. Resolve and restart.${NC}"
            exit 1
        fi
        remove_worktree "$phase"
        echo -e "${GREEN}  >> Phase $phase merged and cleaned up${NC}"
    done
}

# --- Main ---

echo ""
show_wave_plan

if [ "$DRY_RUN" -eq 1 ]; then
    echo -e "${YELLOW}  DRY RUN — no execution. Use without --dry-run to start.${NC}"
    exit 0
fi

# Validate we're on main branch
current_branch=$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD 2>&1)
if [ "$current_branch" != "main" ]; then
    echo -e "${RED}  >> Must be on 'main' branch to run parallel orchestrator.${NC}"
    echo -e "${RED}  >> Current branch: $current_branch${NC}"
    exit 1
fi

# Validate clean working tree
git_status=$(git -C "$REPO_ROOT" status --porcelain 2>&1)
if [ -n "$git_status" ]; then
    echo -e "${YELLOW}  >> Warning: working tree has uncommitted changes.${NC}"
    echo -e "${YELLOW}  >> Consider committing before running parallel waves.${NC}"
    echo ""
fi

# Find start index
start_index=-1
for i in "${!WAVE_ORDER[@]}"; do
    if [ "${WAVE_ORDER[$i]}" = "$START_WAVE" ]; then
        start_index=$i
        break
    fi
done

if [ "$start_index" -lt 0 ]; then
    echo -e "${RED}  >> Invalid start wave: $START_WAVE. Use A-F.${NC}"
    exit 1
fi

total_start=$(date +%s)

for ((w=start_index; w<${#WAVE_ORDER[@]}; w++)); do
    wave_name="${WAVE_ORDER[$w]}"
    mode="${WAVE_MODES[$wave_name]}"
    phases="${WAVE_PHASES[$wave_name]}"
    desc="${WAVE_DESCS[$wave_name]}"

    echo ""
    echo -e "${CYAN}==========================================="
    echo -e "  WAVE $wave_name: $desc"
    echo -e "  Mode: $mode | Phases: $phases"
    echo -e "==========================================${NC}"

    if [ "$mode" = "sequential" ]; then
        run_sequential_wave $phases
    else
        run_parallel_wave $phases
    fi

    echo -e "${GREEN}  Wave $wave_name complete!${NC}"
    echo ""
done

total_end=$(date +%s)
total_elapsed=$((total_end - total_start))
total_hours=$((total_elapsed / 3600))
total_min=$(( (total_elapsed % 3600) / 60 ))
total_sec=$((total_elapsed % 60))
total_str=$(printf "%02d:%02d:%02d" $total_hours $total_min $total_sec)

echo ""
echo -e "${GREEN}==========================================="
echo -e "  ALL WAVES COMPLETE — Total time: $total_str"
echo -e "==========================================${NC}"
exit 0
