#!/bin/bash
set -e

# --- Argument parsing ---
PHASE=0
MAX_ITERATIONS=0
PAUSE_SECONDS=2

while [[ $# -gt 0 ]]; do
    case "$1" in
        --phase|-p)
            PHASE="$2"
            shift 2
            ;;
        --max|-m)
            MAX_ITERATIONS="$2"
            shift 2
            ;;
        --sleep|-s)
            PAUSE_SECONDS="$2"
            shift 2
            ;;
        *)
            # Positional: first arg is phase if numeric
            if [[ "$1" =~ ^[0-9]+$ ]] && [ "$PHASE" -eq 0 ]; then
                PHASE="$1"
            fi
            shift
            ;;
    esac
done

# Determine effective max iterations
if [ "$MAX_ITERATIONS" -eq 0 ]; then
    if [ "$PHASE" -gt 0 ]; then
        EFFECTIVE_MAX=100
    else
        EFFECTIVE_MAX=10
    fi
else
    EFFECTIVE_MAX=$MAX_ITERATIONS
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT_FILE="$SCRIPT_DIR/ralph-prompt.txt"
OUTPUT_FILE="$SCRIPT_DIR/.ralph-output.tmp"

# Session tracking: fresh ID per cycle, reuse only for Q&A continuation
CONTINUE_SESSION_ID=""
PENDING_ANSWER=""
CYCLE_SESSION_ID=""

# --- Colors ---
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# --- Ctrl+C handler ---
cleanup() {
    echo ""
    echo -e "${YELLOW}Ralph stopped by user.${NC}"
    exit 0
}
trap cleanup INT TERM

# --- Helpers ---

get_prd_path() {
    local prd_path="$SCRIPT_DIR/prd/PRD.md"
    if [ ! -f "$prd_path" ]; then
        prd_path="$SCRIPT_DIR/PRD.md"
    fi
    echo "$prd_path"
}

get_task_stats() {
    local prd_path
    prd_path=$(get_prd_path)
    if [ ! -f "$prd_path" ]; then
        echo ""
        return
    fi

    local checked unchecked total
    checked=$(grep -c '\- \[x\]' "$prd_path" 2>/dev/null || echo 0)
    unchecked=$(grep -c '\- \[ \]' "$prd_path" 2>/dev/null || echo 0)
    total=$((checked + unchecked))
    echo "${checked}/${total} complete, ${unchecked} remaining"
}

get_phase_stories() {
    local phase_num="$1"
    local prd_path
    prd_path=$(get_prd_path)

    if [ ! -f "$prd_path" ]; then
        echo -e "${RED}  PRD.md not found${NC}" >&2
        exit 1
    fi

    # Extract phase title
    PHASE_TITLE=$(grep -E "^### Phase ${phase_num}:" "$prd_path" | sed "s/^### Phase ${phase_num}: *//" | head -1)

    if [ -z "$PHASE_TITLE" ]; then
        echo -e "${RED}  Phase $phase_num not found in PRD.md${NC}" >&2
        exit 1
    fi

    # Extract story IDs between this phase header and the next phase header
    PHASE_STORIES=()
    local in_phase=0
    while IFS= read -r line; do
        if echo "$line" | grep -qE "^### Phase ${phase_num}:"; then
            in_phase=1
            continue
        fi
        if [ "$in_phase" -eq 1 ] && echo "$line" | grep -qE "^### Phase [0-9]+:"; then
            break
        fi
        if [ "$in_phase" -eq 1 ]; then
            local story_id
            story_id=$(echo "$line" | grep -oE "^### (US-[0-9]+):" | grep -oE "US-[0-9]+" || true)
            if [ -n "$story_id" ]; then
                PHASE_STORIES+=("$story_id")
            fi
        fi
    done < "$prd_path"
}

is_phase_complete() {
    local phase_num="$1"
    local prd_path
    prd_path=$(get_prd_path)

    # Get stories for this phase
    get_phase_stories "$phase_num"

    local content
    content=$(cat "$prd_path")

    for story_id in "${PHASE_STORIES[@]}"; do
        # Extract section for this story and check for unchecked tasks
        local story_section
        story_section=$(echo "$content" | sed -n "/^### ${story_id}:/,/^### /p" | head -n -1)
        if echo "$story_section" | grep -q '\- \[ \]'; then
            return 1  # not complete
        fi
    done
    return 0  # all complete
}

get_phase_task_stats() {
    local phase_num="$1"
    local prd_path
    prd_path=$(get_prd_path)

    get_phase_stories "$phase_num"

    local content
    content=$(cat "$prd_path")

    PHASE_CHECKED=0
    PHASE_UNCHECKED=0

    for story_id in "${PHASE_STORIES[@]}"; do
        local story_section
        story_section=$(echo "$content" | sed -n "/^### ${story_id}:/,/^### /p" | head -n -1)
        local c u
        c=$(echo "$story_section" | grep -c '\- \[x\]' 2>/dev/null || echo 0)
        u=$(echo "$story_section" | grep -c '\- \[ \]' 2>/dev/null || echo 0)
        PHASE_CHECKED=$((PHASE_CHECKED + c))
        PHASE_UNCHECKED=$((PHASE_UNCHECKED + u))
    done

    PHASE_TASK_TOTAL=$((PHASE_CHECKED + PHASE_UNCHECKED))
}

build_phase_prompt() {
    local phase_num="$1"
    local phase_title="$2"
    shift 2
    local stories=("$@")

    local stories_list
    stories_list=$(IFS=", "; echo "${stories[*]}")

    local phase_block
    phase_block="## Phase Assignment
You are assigned to **Phase ${phase_num}: ${phase_title}**.
Your stories: ${stories_list}.
ONLY work on unchecked tasks ([ ]) within this range. Ignore all other phases.

## Progress File
Write your progress entries to \`progress-phase-${phase_num}.txt\` instead of \`progress.txt\`.
If \`progress-phase-${phase_num}.txt\` does not exist, create it with a \`# Progress Log — Phase ${phase_num}\` header.
Read from BOTH \`progress.txt\` AND any \`progress-phase-*.txt\` files for prior learnings.

When ALL stories in your phase range are marked [x], output: <promise>PHASE_COMPLETE</promise>
Do NOT output <promise>COMPLETE</promise> — only use PHASE_COMPLETE."

    local prompt_text
    prompt_text=$(cat "$PROMPT_FILE")
    # Replace {PHASE_SCOPE} with the phase block
    echo "${prompt_text//\{PHASE_SCOPE\}/$phase_block}"
}

extract_tag() {
    local content="$1"
    local tag="$2"
    echo "$content" | sed -n "s/.*<${tag}>\(.*\)<\/${tag}>.*/\1/p" | head -1
}

# --- Build prompt ---

if [ "$PHASE" -gt 0 ]; then
    get_phase_stories "$PHASE"
    PROMPT_TEXT=$(build_phase_prompt "$PHASE" "$PHASE_TITLE" "${PHASE_STORIES[@]}")
else
    PROMPT_TEXT=$(cat "$PROMPT_FILE" | sed 's/{PHASE_SCOPE}[[:space:]]*//')
fi

# --- Setup banner ---

echo -e "${CYAN}==========================================="
echo -e "  Ralph Agent -- Streaming Mode"
if [ "$PHASE" -gt 0 ]; then
    echo -e "  Phase: $PHASE -- $PHASE_TITLE"
    stories_display=$(IFS=", "; echo "${PHASE_STORIES[*]}")
    echo -e "  Stories: $stories_display"
    echo -e "  Max cycles: $EFFECTIVE_MAX (safety cap)"
else
    echo -e "  Max cycles: $EFFECTIVE_MAX"
fi
echo -e "  Press Ctrl+C to stop"
echo -e "==========================================${NC}"
echo ""

for ((i=1; i<=EFFECTIVE_MAX; i++)); do

    # --- Task stats dashboard ---
    echo -e "${CYAN}==========================================="
    if [ "$PHASE" -gt 0 ]; then
        get_phase_task_stats "$PHASE"
        echo -e "  Phase $PHASE: $PHASE_TITLE  |  Cycle $i  |  Tasks: $PHASE_CHECKED/$PHASE_TASK_TOTAL complete, $PHASE_UNCHECKED remaining"
    else
        stats=$(get_task_stats)
        if [ -n "$stats" ]; then
            echo -e "  Cycle $i of $EFFECTIVE_MAX  |  Tasks: $stats"
        else
            echo -e "  Cycle $i of $EFFECTIVE_MAX"
        fi
    fi
    echo -e "==========================================${NC}"
    echo ""

    # --- Build claude arguments ---
    claude_args=(
        --dangerously-skip-permissions
        --output-format text
        --verbose
    )

    if [ -n "$CONTINUE_SESSION_ID" ]; then
        # Q&A follow-up: continue the session that asked the question
        claude_args+=(--session-id "$CONTINUE_SESSION_ID" -c -p "The human operator answered your question: $PENDING_ANSWER

Please continue with the current task using this information.")
        CONTINUE_SESSION_ID=""
        PENDING_ANSWER=""
    else
        # Normal cycle: fresh session
        CYCLE_SESSION_ID=$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid 2>/dev/null || date +%s%N)
        claude_args+=(--session-id "$CYCLE_SESSION_ID" -p "$PROMPT_TEXT")
    fi

    # --- Stream output to terminal + capture to file ---
    cycle_start=$(date +%s)

    rm -f "$OUTPUT_FILE"

    set +e
    claude "${claude_args[@]}" 2>&1 | tee "$OUTPUT_FILE"
    claude_exit=${PIPESTATUS[0]}
    set -e

    cycle_end=$(date +%s)
    elapsed=$((cycle_end - cycle_start))
    elapsed_min=$((elapsed / 60))
    elapsed_sec=$((elapsed % 60))
    elapsed_str=$(printf "%02d:%02d" $elapsed_min $elapsed_sec)

    echo ""

    # --- Check for claude errors ---
    if [ "$claude_exit" -ne 0 ]; then
        echo -e "${RED}  >> Claude exited with code $claude_exit -- $elapsed_str"
        echo -e "  >> Check error output above. Continuing to next cycle...${NC}"
        echo ""
        if [ $i -lt $EFFECTIVE_MAX ]; then sleep $PAUSE_SECONDS; fi
        continue
    fi

    # --- Read captured output for post-processing ---
    result=""
    if [ -f "$OUTPUT_FILE" ]; then
        result=$(cat "$OUTPUT_FILE")
    fi

    # --- Check for phase completion ---
    if [ "$PHASE" -gt 0 ]; then
        PHASE_DONE=0

        if echo "$result" | grep -q '<promise>PHASE_COMPLETE</promise>'; then
            PHASE_DONE=1
            echo ""
            echo -e "${GREEN}==========================================="
            echo -e "  PHASE $PHASE COMPLETE after $i cycles -- $elapsed_str this cycle"
            echo -e "==========================================${NC}"
        fi

        # Double-check by parsing PRD directly (in case Ralph forgot the tag)
        if [ "$PHASE_DONE" -eq 0 ] && is_phase_complete "$PHASE"; then
            PHASE_DONE=1
            echo ""
            echo -e "${GREEN}==========================================="
            echo -e "  PHASE $PHASE COMPLETE (detected from PRD) after $i cycles -- $elapsed_str this cycle"
            echo -e "==========================================${NC}"
        fi

        if [ "$PHASE_DONE" -eq 1 ]; then
            # Consolidate phase progress into main progress.txt
            phase_progress_file="$SCRIPT_DIR/progress-phase-$PHASE.txt"
            main_progress_file="$SCRIPT_DIR/progress.txt"
            if [ -f "$phase_progress_file" ]; then
                echo "" >> "$main_progress_file"
                echo "---" >> "$main_progress_file"
                echo "## Phase $PHASE Progress" >> "$main_progress_file"
                cat "$phase_progress_file" >> "$main_progress_file"
                echo -e "${CYAN}  >> Consolidated progress-phase-$PHASE.txt into progress.txt${NC}"
            fi
            exit 0
        fi
    fi

    # --- Check for full completion (all-tasks mode) ---
    if echo "$result" | grep -q '<promise>COMPLETE</promise>'; then
        echo ""
        echo -e "${GREEN}==========================================="
        echo -e "  ALL TASKS COMPLETE after $i cycles -- $elapsed_str this cycle"
        echo -e "==========================================${NC}"
        exit 0
    fi

    # --- Check for failure ---
    if echo "$result" | grep -q '<status>FAILED</status>'; then
        echo -e "${RED}  >> Cycle $i FAILED -- $elapsed_str"
        echo -e "  >> Task validation did not pass -- check output above${NC}"
        echo ""
    else
        echo -e "${CYAN}  >> Cycle $i finished -- $elapsed_str${NC}"
        echo ""
    fi

    # --- Check for question ---
    question=$(extract_tag "$result" "question")
    if [ -n "$question" ]; then
        echo ""
        echo -e "${YELLOW}==========================================="
        echo -e "  Ralph has a question:"
        echo -e "==========================================="
        echo -e "  $question"
        echo -e "==========================================${NC}"
        echo ""
        read -r -p "Your answer (or 'skip' to let Ralph decide): " PENDING_ANSWER
        if [ "$PENDING_ANSWER" = "skip" ]; then
            PENDING_ANSWER="Use your best judgment -- no preference from the operator."
        fi
        # Save session ID so next cycle continues this conversation
        CONTINUE_SESSION_ID="$CYCLE_SESSION_ID"
        echo ""
        continue
    fi

    # --- Pause between cycles ---
    if [ $i -lt $EFFECTIVE_MAX ]; then
        sleep $PAUSE_SECONDS
    fi
done

echo ""
echo -e "${RED}==========================================="
if [ "$PHASE" -gt 0 ]; then
    echo -e "  Phase $PHASE: Stopped after reaching limit -- $EFFECTIVE_MAX cycles"
else
    echo -e "  Stopped after reaching limit -- $EFFECTIVE_MAX cycles"
fi
echo -e "==========================================${NC}"
exit 1
