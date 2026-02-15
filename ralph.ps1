param(
    [int]$Phase = 0,          # 0 = original mode (all tasks)
    [int]$MaxIterations = 0,  # 0 = auto (unlimited for phase mode, 10 for all-tasks mode)
    [int]$SleepSeconds = 2
)

# --- Helpers ---

function Write-Cyan    { param([string]$Text) Write-Host $Text -ForegroundColor Cyan }
function Write-Yellow  { param([string]$Text) Write-Host $Text -ForegroundColor Yellow }
function Write-Red     { param([string]$Text) Write-Host $Text -ForegroundColor Red }
function Write-Green   { param([string]$Text) Write-Host $Text -ForegroundColor Green }

function Get-PrdPath {
    $prdPath = Join-Path (Join-Path $PSScriptRoot "prd") "PRD.md"
    if (-not (Test-Path $prdPath)) {
        $prdPath = Join-Path $PSScriptRoot "PRD.md"
    }
    return $prdPath
}

function Get-TaskStats {
    $prdPath = Get-PrdPath
    if (-not (Test-Path $prdPath)) { return $null }

    $content = Get-Content $prdPath -Raw
    $checked   = ([regex]::Matches($content, '- \[x\]')).Count
    $unchecked = ([regex]::Matches($content, '- \[ \]')).Count
    $total = $checked + $unchecked
    return @{ Done = $checked; Remaining = $unchecked; Total = $total }
}

function Get-PhaseStories {
    param([int]$PhaseNum)

    $prdPath = Get-PrdPath
    if (-not (Test-Path $prdPath)) {
        Write-Red "  PRD.md not found"
        exit 1
    }

    $lines = Get-Content $prdPath
    $inPhase = $false
    $phaseTitle = ""
    $stories = @()

    foreach ($line in $lines) {
        # Match phase header: ### Phase N: Title
        if ($line -match "^### Phase\s+${PhaseNum}:\s*(.+)$") {
            $phaseTitle = $Matches[1].Trim()
            $inPhase = $true
            continue
        }

        # If we hit the next phase header, stop
        if ($inPhase -and $line -match "^### Phase\s+\d+:") {
            break
        }

        # Collect story IDs within this phase
        if ($inPhase -and $line -match "^### (US-\d+):") {
            $stories += $Matches[1]
        }
    }

    if (-not $phaseTitle) {
        Write-Red "  Phase $PhaseNum not found in PRD.md"
        exit 1
    }

    return @{ Title = $phaseTitle; Stories = $stories }
}

function Is-PhaseComplete {
    param([int]$PhaseNum)

    $phaseInfo = Get-PhaseStories $PhaseNum
    $prdPath = Get-PrdPath
    $content = Get-Content $prdPath -Raw

    foreach ($storyId in $phaseInfo.Stories) {
        # Find the story section and check if it has any unchecked tasks
        $pattern = "### ${storyId}:[\s\S]*?(?=### US-|### Phase|\z)"
        $storyMatch = [regex]::Match($content, $pattern)
        if ($storyMatch.Success) {
            $storyText = $storyMatch.Value
            if ($storyText -match '- \[ \]') {
                return $false
            }
        }
    }
    return $true
}

function Get-PhaseTaskStats {
    param([int]$PhaseNum)

    $phaseInfo = Get-PhaseStories $PhaseNum
    $prdPath = Get-PrdPath
    $content = Get-Content $prdPath -Raw

    $checked = 0
    $unchecked = 0

    foreach ($storyId in $phaseInfo.Stories) {
        $pattern = "### ${storyId}:[\s\S]*?(?=### US-|### Phase|\z)"
        $storyMatch = [regex]::Match($content, $pattern)
        if ($storyMatch.Success) {
            $storyText = $storyMatch.Value
            $checked   += ([regex]::Matches($storyText, '- \[x\]')).Count
            $unchecked += ([regex]::Matches($storyText, '- \[ \]')).Count
        }
    }

    $total = $checked + $unchecked
    return @{ Done = $checked; Remaining = $unchecked; Total = $total; StoriesTotal = $phaseInfo.Stories.Count }
}

function Build-PhasePrompt {
    param([int]$PhaseNum, [string[]]$Stories, [string]$PhaseTitle)

    $promptFile = Join-Path $PSScriptRoot "ralph-prompt.txt"
    $promptText = Get-Content $promptFile -Raw

    $storiesList = ($Stories -join ", ")
    $phaseBlock = @"
## Phase Assignment
You are assigned to **Phase ${PhaseNum}: ${PhaseTitle}**.
Your stories: ${storiesList}.
ONLY work on unchecked tasks ([ ]) within this range. Ignore all other phases.

## Progress File
Write your progress entries to ``progress-phase-${PhaseNum}.txt`` instead of ``progress.txt``.
If ``progress-phase-${PhaseNum}.txt`` does not exist, create it with a ``# Progress Log — Phase ${PhaseNum}`` header.
Read from BOTH ``progress.txt`` AND any ``progress-phase-*.txt`` files for prior learnings.

When ALL stories in your phase range are marked [x], output: <promise>PHASE_COMPLETE</promise>
Do NOT output <promise>COMPLETE</promise> — only use PHASE_COMPLETE.
"@

    $promptText = $promptText -replace '\{PHASE_SCOPE\}', $phaseBlock
    return $promptText
}

function Extract-Tag {
    param([string]$Content, [string]$Tag)
    if ($Content -match "<$Tag>([\s\S]*?)</$Tag>") {
        return $Matches[1].Trim()
    }
    return $null
}

# --- Setup ---

$scriptDir   = $PSScriptRoot
$promptFile  = Join-Path $scriptDir "ralph-prompt.txt"
$outputFile  = Join-Path $scriptDir ".ralph-output.tmp"

# Determine effective max iterations
if ($MaxIterations -eq 0) {
    $effectiveMax = if ($Phase -gt 0) { 100 } else { 10 }
} else {
    $effectiveMax = $MaxIterations
}

# Build prompt
if ($Phase -gt 0) {
    $phaseInfo = Get-PhaseStories $Phase
    $promptText = Build-PhasePrompt $Phase $phaseInfo.Stories $phaseInfo.Title
} else {
    $promptText = (Get-Content $promptFile -Raw) -replace '\{PHASE_SCOPE\}\s*', ''
}

# Session tracking: fresh ID per cycle, reuse only for Q&A continuation
$continueSessionId = $null
$pendingAnswer = $null

Write-Cyan "==========================================="
Write-Cyan "  Ralph Agent -- Streaming Mode"
if ($Phase -gt 0) {
    Write-Cyan "  Phase: $Phase -- $($phaseInfo.Title)"
    Write-Cyan "  Stories: $($phaseInfo.Stories -join ', ')"
    Write-Cyan "  Max cycles: $effectiveMax (safety cap)"
} else {
    Write-Cyan "  Max cycles: $effectiveMax"
}
Write-Cyan "  Press Ctrl+C to stop"
Write-Cyan "==========================================="
Write-Host ""

for ($i = 1; $i -le $effectiveMax; $i++) {

    # --- Task stats dashboard ---
    Write-Cyan "==========================================="
    if ($Phase -gt 0) {
        $phaseStats = Get-PhaseTaskStats $Phase
        $statsLine = "  Phase $Phase`: $($phaseInfo.Title)  |  Cycle $i  |  Tasks: $($phaseStats.Done)/$($phaseStats.Total) complete, $($phaseStats.Remaining) remaining"
        Write-Cyan $statsLine
    } else {
        $stats = Get-TaskStats
        if ($stats) {
            $statsLine = "  Cycle $i of $effectiveMax  |  Tasks: $($stats.Done)/$($stats.Total) complete, $($stats.Remaining) remaining"
            Write-Cyan $statsLine
        } else {
            Write-Cyan "  Cycle $i of $effectiveMax"
        }
    }
    Write-Cyan "==========================================="
    Write-Host ""

    # --- Build claude arguments ---
    $claudeArgs = @(
        "--dangerously-skip-permissions"
        "--output-format", "text"
        "--verbose"
    )

    if ($continueSessionId) {
        # Q&A follow-up: continue the session that asked the question
        $claudeArgs += @("--session-id", $continueSessionId, "-c", "-p",
            "The human operator answered your question: $pendingAnswer`n`nPlease continue with the current task using this information.")
        $continueSessionId = $null
        $pendingAnswer = $null
    } else {
        # Normal cycle: fresh session
        $cycleSessionId = [guid]::NewGuid().ToString()
        $claudeArgs += @("--session-id", $cycleSessionId, "-p", $promptText)
    }

    # --- Stream output to terminal + capture to file ---
    $cycleStart = Get-Date

    if (Test-Path $outputFile) { Remove-Item $outputFile -Force }

    claude @claudeArgs 2>&1 | Tee-Object -FilePath $outputFile
    $claudeExit = $LASTEXITCODE

    $cycleEnd = Get-Date
    $elapsed = $cycleEnd - $cycleStart
    $elapsedStr = "{0:mm\:ss}" -f $elapsed

    Write-Host ""

    # --- Check for claude errors ---
    if ($claudeExit -ne 0) {
        Write-Red "  >> Claude exited with code $claudeExit -- $elapsedStr"
        Write-Red "  >> Check error output above. Continuing to next cycle..."
        Write-Host ""
        if ($i -lt $effectiveMax) { Start-Sleep -Seconds $SleepSeconds }
        continue
    }

    # --- Read captured output for post-processing ---
    $result = ""
    if (Test-Path $outputFile) {
        $result = Get-Content $outputFile -Raw
        if (-not $result) { $result = "" }
    }

    # --- Check for phase completion ---
    if ($Phase -gt 0) {
        $phaseComplete = $false

        if ($result -like "*<promise>PHASE_COMPLETE</promise>*") {
            $phaseComplete = $true
            Write-Host ""
            Write-Green "==========================================="
            Write-Green "  PHASE $Phase COMPLETE after $i cycles -- $elapsedStr this cycle"
            Write-Green "==========================================="
        }

        # Double-check by parsing PRD directly (in case Ralph forgot the tag)
        if (-not $phaseComplete -and (Is-PhaseComplete $Phase)) {
            $phaseComplete = $true
            Write-Host ""
            Write-Green "==========================================="
            Write-Green "  PHASE $Phase COMPLETE (detected from PRD) after $i cycles -- $elapsedStr this cycle"
            Write-Green "==========================================="
        }

        if ($phaseComplete) {
            # Consolidate phase progress into main progress.txt
            $phaseProgressFile = Join-Path $scriptDir "progress-phase-$Phase.txt"
            $mainProgressFile  = Join-Path $scriptDir "progress.txt"
            if (Test-Path $phaseProgressFile) {
                $phaseContent = Get-Content $phaseProgressFile -Raw
                if ($phaseContent) {
                    Add-Content -Path $mainProgressFile -Value "`n---`n## Phase $Phase Progress`n$phaseContent"
                    Write-Cyan "  >> Consolidated progress-phase-$Phase.txt into progress.txt"
                }
            }
            exit 0
        }
    }

    # --- Check for full completion (all-tasks mode) ---
    if ($result -like "*<promise>COMPLETE</promise>*") {
        Write-Host ""
        Write-Green "==========================================="
        Write-Green "  ALL TASKS COMPLETE after $i cycles -- $elapsedStr this cycle"
        Write-Green "==========================================="
        exit 0
    }

    # --- Check for failure ---
    if ($result -like "*<status>FAILED</status>*") {
        Write-Red "  >> Cycle $i FAILED -- $elapsedStr"
        Write-Red "  >> Task validation did not pass -- check output above"
        Write-Host ""
    } else {
        Write-Cyan "  >> Cycle $i finished -- $elapsedStr"
        Write-Host ""
    }

    # --- Check for question ---
    $question = Extract-Tag -Content $result -Tag "question"
    if ($question) {
        Write-Host ""
        Write-Yellow "==========================================="
        Write-Yellow "  Ralph has a question:"
        Write-Yellow "==========================================="
        Write-Yellow "  $question"
        Write-Yellow "==========================================="
        Write-Host ""
        $pendingAnswer = Read-Host "Your answer (or 'skip' to let Ralph decide)"
        if ($pendingAnswer -eq "skip") {
            $pendingAnswer = "Use your best judgment -- no preference from the operator."
        }
        # Save session ID so next cycle continues this conversation
        $continueSessionId = $cycleSessionId
        Write-Host ""
        continue
    }

    # --- Pause between cycles ---
    if ($i -lt $effectiveMax) {
        Start-Sleep -Seconds $SleepSeconds
    }
}

Write-Host ""
Write-Red "==========================================="
if ($Phase -gt 0) {
    Write-Red "  Phase ${Phase}: Stopped after reaching limit -- $effectiveMax cycles"
} else {
    Write-Red "  Stopped after reaching limit -- $effectiveMax cycles"
}
Write-Red "==========================================="
exit 1
