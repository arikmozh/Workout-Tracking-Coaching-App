param(
    [string]$StartWave = "A",
    [switch]$DryRun,
    [int]$SleepSeconds = 5
)

# --- Helpers ---

function Write-Cyan    { param([string]$Text) Write-Host $Text -ForegroundColor Cyan }
function Write-Yellow  { param([string]$Text) Write-Host $Text -ForegroundColor Yellow }
function Write-Red     { param([string]$Text) Write-Host $Text -ForegroundColor Red }
function Write-Green   { param([string]$Text) Write-Host $Text -ForegroundColor Green }

# --- Wave Definitions ---
# Based on PRD.md Phase Dependencies table

$waveOrder = @("A", "B", "C", "D", "E", "F")

$waves = [ordered]@{
    A = @{ Phases = @(1,2,3,4,5,6,7); Mode = "sequential"; Description = "Foundation (setup, types, auth, i18n, nav, CRUD, clients)" }
    B = @{ Phases = @(8,9,14);         Mode = "parallel";   Description = "Monitoring + Trainee Programs + Settings" }
    C = @{ Phases = @(10,13);          Mode = "parallel";   Description = "Trainee Logging + Push Notifications" }
    D = @{ Phases = @(11);             Mode = "sequential"; Description = "Trainee History" }
    E = @{ Phases = @(12);             Mode = "sequential"; Description = "Progress Charts" }
    F = @{ Phases = @(15);             Mode = "sequential"; Description = "Polish & Hardening" }
}

$scriptDir = $PSScriptRoot
$repoRoot  = $scriptDir  # Assumes script is at repo root

# Files to copy into each worktree
$filesToCopy = @(
    "ralph.ps1",
    "ralph.sh",
    "ralph-prompt.txt",
    "PRD.md",
    "progress.txt"
)

# --- Functions ---

function Show-WavePlan {
    Write-Cyan "==========================================="
    Write-Cyan "  Ralph Parallel Orchestrator -- Wave Plan"
    Write-Cyan "==========================================="
    Write-Host ""

    foreach ($waveName in $waveOrder) {
        $wave = $waves[$waveName]
        $phases = $wave.Phases -join ", "
        $marker = ""
        $skip = ""
        if ($waveName -eq $StartWave) { $marker = " <-- START" }
        if ($waveOrder.IndexOf($waveName) -lt $waveOrder.IndexOf($StartWave)) { $skip = " (skip)" }

        Write-Cyan "  Wave $waveName [$($wave.Mode)]: Phases $phases$marker$skip"
        Write-Host "    $($wave.Description)"
    }
    Write-Host ""
}

function New-Worktree {
    param([int]$PhaseNum)

    $worktreePath = Join-Path (Split-Path $repoRoot -Parent) "Workout-phase-$PhaseNum"
    $branchName   = "phase-$PhaseNum"

    Write-Cyan "  >> Creating worktree: $worktreePath (branch: $branchName)"

    # Create worktree with new branch from current HEAD
    $output = & git -C $repoRoot worktree add $worktreePath -b $branchName 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Red "  >> Failed to create worktree for phase $PhaseNum"
        Write-Red "  >> $output"
        return $null
    }

    # Copy ralph files into the worktree
    foreach ($file in $filesToCopy) {
        $src = Join-Path $repoRoot $file
        if (Test-Path $src) {
            Copy-Item $src (Join-Path $worktreePath $file) -Force
        }
    }

    # Also copy progress-phase files if they exist (for cross-phase learnings)
    Get-ChildItem -Path $repoRoot -Filter "progress-phase-*.txt" -ErrorAction SilentlyContinue | ForEach-Object {
        Copy-Item $_.FullName (Join-Path $worktreePath $_.Name) -Force
    }

    return $worktreePath
}

function Remove-Worktree {
    param([int]$PhaseNum)

    $worktreePath = Join-Path (Split-Path $repoRoot -Parent) "Workout-phase-$PhaseNum"
    $branchName   = "phase-$PhaseNum"

    Write-Cyan "  >> Removing worktree: $worktreePath"

    if (Test-Path $worktreePath) {
        & git -C $repoRoot worktree remove $worktreePath --force 2>&1 | Out-Null
    }

    # Clean up branch
    & git -C $repoRoot branch -d $branchName 2>&1 | Out-Null
}

function Merge-WorktreeBranch {
    param([int]$PhaseNum)

    $branchName   = "phase-$PhaseNum"
    $worktreePath = Join-Path (Split-Path $repoRoot -Parent) "Workout-phase-$PhaseNum"

    Write-Cyan "  >> Merging $branchName into main..."

    # Copy back any progress and PRD changes before merge
    $worktreePrd = Join-Path $worktreePath "PRD.md"
    if (Test-Path $worktreePrd) {
        Copy-Item $worktreePrd (Join-Path $repoRoot "PRD.md") -Force
    }

    $worktreeProgress = Join-Path $worktreePath "progress-phase-$PhaseNum.txt"
    if (Test-Path $worktreeProgress) {
        Copy-Item $worktreeProgress (Join-Path $repoRoot "progress-phase-$PhaseNum.txt") -Force
    }

    # Stage and commit any file changes on main that came from worktree copy
    Push-Location $repoRoot
    try {
        & git add -A 2>&1 | Out-Null
        & git diff --cached --quiet 2>&1
        $changed = ($LASTEXITCODE -ne 0)
        if ($changed) {
            & git commit -m "merge: incorporate phase $PhaseNum changes" 2>&1 | Out-Null
        }

        # Now merge the branch
        & git merge $branchName --no-ff -m "merge: phase $PhaseNum complete" 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Red "  >> Merge conflict on $branchName! Resolve manually."
            Write-Red "  >> After resolving, rerun with -StartWave for the next wave."
            return $false
        }
    } finally {
        Pop-Location
    }

    # Consolidate phase progress
    $phaseProgressFile = Join-Path $repoRoot "progress-phase-$PhaseNum.txt"
    $mainProgressFile  = Join-Path $repoRoot "progress.txt"
    if (Test-Path $phaseProgressFile) {
        $content = Get-Content $phaseProgressFile -Raw
        if ($content) {
            Add-Content -Path $mainProgressFile -Value "`n---`n## Phase $PhaseNum Progress`n$content"
            Write-Cyan "  >> Consolidated progress-phase-$PhaseNum.txt into progress.txt"
        }
    }

    return $true
}

function Run-SequentialWave {
    param([int[]]$Phases)

    foreach ($phase in $Phases) {
        Write-Cyan ""
        Write-Cyan "==========================================="
        Write-Cyan "  Running Phase $phase (sequential)"
        Write-Cyan "==========================================="
        Write-Host ""

        $ralphScript = Join-Path $repoRoot "ralph.ps1"
        & $ralphScript -Phase $phase
        $exitCode = $LASTEXITCODE

        if ($exitCode -ne 0) {
            Write-Red "  >> Phase $phase did not complete successfully (exit code: $exitCode)"
            Write-Red "  >> Fix issues and rerun with -StartWave for the appropriate wave."
            exit 1
        }

        Write-Green "  >> Phase $phase complete"
        Start-Sleep -Seconds $SleepSeconds
    }
}

function Run-ParallelWave {
    param([int[]]$Phases)

    $jobs = @{}
    $worktrees = @{}

    # Create worktrees and start jobs
    foreach ($phase in $Phases) {
        Write-Cyan ""
        Write-Cyan "  Setting up parallel Phase $phase..."

        $worktreePath = New-Worktree -PhaseNum $phase
        if (-not $worktreePath) {
            Write-Red "  >> Failed to create worktree for phase $phase. Aborting wave."
            # Clean up any created worktrees
            foreach ($p in $worktrees.Keys) {
                Remove-Worktree -PhaseNum $p
            }
            exit 1
        }
        $worktrees[$phase] = $worktreePath

        # Start Ralph as a background job in the worktree
        $ralphScript = Join-Path $worktreePath "ralph.ps1"
        $job = Start-Job -ScriptBlock {
            param($script, $phaseNum, $workDir)
            Set-Location $workDir
            & $script -Phase $phaseNum
            return $LASTEXITCODE
        } -ArgumentList $ralphScript, $phase, $worktreePath

        $jobs[$phase] = $job
        Write-Cyan "  >> Phase $phase started (Job ID: $($job.Id))"
    }

    Write-Host ""
    Write-Cyan "==========================================="
    Write-Cyan "  All parallel phases launched. Waiting..."
    Write-Cyan "  Phases: $($Phases -join ', ')"
    Write-Cyan "==========================================="

    # Wait for all jobs, showing periodic status
    $allDone = $false
    while (-not $allDone) {
        Start-Sleep -Seconds 15
        $allDone = $true
        foreach ($phase in $Phases) {
            $job = $jobs[$phase]
            if ($job.State -eq "Running") {
                $allDone = $false
                Write-Yellow "  Phase ${phase}: still running..."
            } elseif ($job.State -eq "Completed") {
                Write-Green "  Phase ${phase}: completed"
            } else {
                Write-Red "  Phase ${phase}: $($job.State)"
            }
        }
        if (-not $allDone) {
            Write-Host ""
        }
    }

    # Collect results
    foreach ($phase in $Phases) {
        $job = $jobs[$phase]
        $output = Receive-Job -Job $job
        Remove-Job -Job $job -Force
        Write-Cyan "  Phase ${phase} job finished"
    }

    Write-Host ""
    Write-Cyan "==========================================="
    Write-Cyan "  Merging parallel phases back to main..."
    Write-Cyan "==========================================="

    # Merge each worktree branch back
    foreach ($phase in $Phases) {
        $success = Merge-WorktreeBranch -PhaseNum $phase
        if (-not $success) {
            Write-Red "  >> Merge failed for phase $phase. Resolve and restart."
            exit 1
        }
        Remove-Worktree -PhaseNum $phase
        Write-Green "  >> Phase $phase merged and cleaned up"
    }
}

# --- Main ---

Write-Host ""
Show-WavePlan

if ($DryRun) {
    Write-Yellow "  DRY RUN -- no execution. Use without -DryRun to start."
    exit 0
}

# Validate we're on main branch
$currentBranch = & git -C $repoRoot rev-parse --abbrev-ref HEAD 2>&1
if ($currentBranch -ne "main") {
    Write-Red "  >> Must be on 'main' branch to run parallel orchestrator."
    Write-Red "  >> Current branch: $currentBranch"
    exit 1
}

# Validate clean working tree
$gitStatus = & git -C $repoRoot status --porcelain 2>&1
if ($gitStatus) {
    Write-Yellow "  >> Warning: working tree has uncommitted changes."
    Write-Yellow "  >> Consider committing before running parallel waves."
    Write-Host ""
}

$startIndex = $waveOrder.IndexOf($StartWave)
if ($startIndex -lt 0) {
    Write-Red "  >> Invalid start wave: $StartWave. Use A-F."
    exit 1
}

$totalStart = Get-Date

for ($w = $startIndex; $w -lt $waveOrder.Count; $w++) {
    $waveName = $waveOrder[$w]
    $wave = $waves[$waveName]

    Write-Host ""
    Write-Cyan "==========================================="
    Write-Cyan "  WAVE ${waveName}: $($wave.Description)"
    Write-Cyan "  Mode: $($wave.Mode) | Phases: $($wave.Phases -join ', ')"
    Write-Cyan "==========================================="

    if ($wave.Mode -eq "sequential") {
        Run-SequentialWave -Phases $wave.Phases
    } else {
        Run-ParallelWave -Phases $wave.Phases
    }

    Write-Green ""
    Write-Green "  Wave $waveName complete!"
    Write-Host ""
}

$totalEnd = Get-Date
$totalElapsed = $totalEnd - $totalStart
$totalMin = [math]::Floor($totalElapsed.TotalMinutes)
$totalSec = $totalElapsed.Seconds
$totalStr = "${totalMin}m ${totalSec}s"

Write-Host ""
Write-Green "==========================================="
Write-Green "  ALL WAVES COMPLETE -- Total time: $totalStr"
Write-Green "==========================================="
exit 0
