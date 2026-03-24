# WakeWell / 5D Smiles — New Machine Bootstrap (Windows)
# Source of truth: claude-skills-ecosystem repo
#
# Fresh machine (PowerShell as Admin):
#   irm https://raw.githubusercontent.com/Wakewell-Sleep-Solutions/claude-skills-ecosystem/main/scripts/bootstrap.ps1 | iex
# Existing clone:
#   & "$HOME\Documents\claude-skills-ecosystem\scripts\bootstrap.ps1"

$ErrorActionPreference = "Continue"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  WakeWell AI Command Center - Setup"     -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$Projects = "$HOME\Documents"
$SkillsRepo = "$Projects\claude-skills-ecosystem"

# --- 1. Package manager (winget) ---
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "winget not found. Install App Installer from the Microsoft Store first." -ForegroundColor Red
    Write-Host "https://apps.microsoft.com/detail/9NBLGGH4NNS1" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "  OK winget" -ForegroundColor Green
}

# --- 2. Core tools ---
$tools = @(
    @{ Name = "git";   Winget = "Git.Git" },
    @{ Name = "node";  Winget = "OpenJS.NodeJS.LTS" },
    @{ Name = "gh";    Winget = "GitHub.cli" }
)

foreach ($tool in $tools) {
    if (Get-Command $tool.Name -ErrorAction SilentlyContinue) {
        Write-Host "  OK $($tool.Name)" -ForegroundColor Green
    } else {
        Write-Host "  Installing $($tool.Name)..." -ForegroundColor Yellow
        winget install --id $tool.Winget --accept-source-agreements --accept-package-agreements -e
    }
}

# Refresh PATH after installs
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# --- 3. Claude Code ---
if (Get-Command claude -ErrorAction SilentlyContinue) {
    $ver = claude --version 2>$null
    Write-Host "  OK claude ($ver)" -ForegroundColor Green
} else {
    Write-Host "  Installing Claude Code..." -ForegroundColor Yellow
    npm install -g @anthropic-ai/claude-code
}

# --- 4. Ruflo ---
if (Get-Command ruflo -ErrorAction SilentlyContinue) {
    Write-Host "  OK ruflo" -ForegroundColor Green
} else {
    Write-Host "  Installing Ruflo..." -ForegroundColor Yellow
    npm install -g ruflo 2>$null
    if (-not $?) { Write-Host "  Ruflo install failed - run: npm install -g ruflo" -ForegroundColor Red }
}

Write-Host ""
Write-Host "All tools installed" -ForegroundColor Green

# --- 5. GitHub auth ---
Write-Host ""
$ghAuth = gh auth status 2>&1
if ($LASTEXITCODE -eq 0) {
    $ghUser = gh api user -q .login 2>$null
    Write-Host "OK GitHub: logged in as $ghUser" -ForegroundColor Green
} else {
    Write-Host "Log in to GitHub (this gives access to the private repos):" -ForegroundColor Yellow
    gh auth login
}

# --- 6. Infisical ---
if (-not (Get-Command infisical -ErrorAction SilentlyContinue)) {
    Write-Host "  Installing Infisical..." -ForegroundColor Yellow
    winget install --id Infisical.CLI --accept-source-agreements --accept-package-agreements -e 2>$null
    if (-not $?) {
        Write-Host "  Infisical install failed - install manually from https://infisical.com/docs/cli/overview" -ForegroundColor Red
    }
} else {
    Write-Host "  OK infisical" -ForegroundColor Green
}

# Refresh PATH again
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

if (Get-Command infisical -ErrorAction SilentlyContinue) {
    # Check auth
    $authOk = $false
    infisical whoami 2>$null
    if ($LASTEXITCODE -eq 0) { $authOk = $true }

    if ($authOk) {
        Write-Host "  OK Infisical: already authenticated" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "Paste your one-time Infisical token (get this from your admin - expires after one use):" -ForegroundColor Yellow
        Write-Host "Type 'skip' to set up later."
        $token = Read-Host "Token"
        if ($token -and $token -ne "skip") {
            $env:INFISICAL_TOKEN = $token
            infisical login 2>$null
            if (-not $?) {
                Write-Host "  Token didn't work - ask your admin for a new one" -ForegroundColor Red
            }
        } else {
            Write-Host "  Skipped - run 'infisical login' when you have your token" -ForegroundColor Yellow
        }
    }

    # Verify secrets (count only - NEVER show values)
    $secretCount = (infisical secrets --env=prod --path=/shared --silent 2>$null | Select-String "│" | Measure-Object).Count
    if ($secretCount -gt 1) {
        Write-Host "  OK Infisical: $secretCount secrets accessible in /shared" -ForegroundColor Green
    } else {
        Write-Host "  Infisical: can't read /shared secrets - check auth or ask admin" -ForegroundColor Red
    }
}

# --- 7. Clone/sync org repos ---
Write-Host ""
Write-Host "Setting up projects..."

if (-not (Test-Path $Projects)) { New-Item -ItemType Directory -Path $Projects | Out-Null }

# Build map of org repos already cloned locally (find by git remote URL)
$repoMap = @{}
Get-ChildItem -Path $Projects -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $gitDir = Join-Path $_.FullName ".git"
    if (Test-Path $gitDir) {
        $remote = git -C $_.FullName remote get-url origin 2>$null
        if ($remote -and $remote -match "Wakewell-Sleep-Solutions") {
            $repoName = ($remote -split "/" | Select-Object -Last 1) -replace "\.git$", ""
            $repoMap[$repoName] = $_.FullName
        }
    }
}

# Get all org repos from GitHub
$repoList = gh repo list Wakewell-Sleep-Solutions --limit 50 --json name -q ".[].name" 2>$null

foreach ($repo in ($repoList -split "`n")) {
    if ([string]::IsNullOrWhiteSpace($repo)) { continue }

    if ($repoMap.ContainsKey($repo)) {
        $existing = $repoMap[$repo]
        $basename = Split-Path $existing -Leaf
        Write-Host "  OK $basename/ (pulling latest)" -ForegroundColor Green
        git -C $existing pull --ff-only 2>$null
        if (-not $?) { Write-Host "    Pull skipped (local changes or worktree)" -ForegroundColor Yellow }
    } else {
        $target = Join-Path $Projects $repo
        if ($repo -eq "aria-slack-bot") { $target = Join-Path $Projects "Claude" }

        if (Test-Path $target) {
            $basename = Split-Path $target -Leaf
            Write-Host "  SKIP $basename/ (exists, not this repo)" -ForegroundColor Yellow
        } else {
            gh repo clone "Wakewell-Sleep-Solutions/$repo" $target 2>$null
            if ($?) {
                $basename = Split-Path $target -Leaf
                Write-Host "  OK $basename/ (cloned)" -ForegroundColor Green
            }
        }
    }
}

# --- 8. Global config from skills repo ---
Write-Host ""

if (-not (Test-Path $SkillsRepo)) {
    $altPaths = @("$HOME\.claude-skills", "$Projects\claude-skills-ecosystem")
    foreach ($p in $altPaths) {
        if (Test-Path $p) { $SkillsRepo = $p; break }
    }
}

$claudeDir = "$HOME\.claude"
$rulesDir = "$claudeDir\rules"
if (-not (Test-Path $claudeDir)) { New-Item -ItemType Directory -Path $claudeDir | Out-Null }
if (-not (Test-Path $rulesDir)) { New-Item -ItemType Directory -Path $rulesDir | Out-Null }

# Global CLAUDE.md (repo is source of truth - always overwrite)
$globalMd = Join-Path $SkillsRepo "config\global-claude.md"
if (Test-Path $globalMd) {
    Copy-Item $globalMd "$claudeDir\CLAUDE.md" -Force
    Write-Host "OK Global CLAUDE.md installed" -ForegroundColor Green
} else {
    Write-Host "Global CLAUDE.md not found in skills repo" -ForegroundColor Red
}

# Rules
$rulesSource = Join-Path $SkillsRepo "config\rules"
if (Test-Path $rulesSource) {
    Get-ChildItem "$rulesSource\*.md" | ForEach-Object {
        Copy-Item $_.FullName "$rulesDir\$($_.Name)" -Force
    }
    Write-Host "OK Global rules synced" -ForegroundColor Green
}

# --- 9. MCP servers ---
if (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Host ""
    Write-Host "Setting up MCP servers..."

    $mcpList = claude mcp list 2>$null

    if ($mcpList -match "ruflo") {
        Write-Host "  OK ruflo MCP" -ForegroundColor Green
    } else {
        Write-Host "  Adding ruflo MCP..." -ForegroundColor Yellow
        claude mcp add ruflo -s user -- ruflo mcp start 2>$null
    }

    if ($mcpList -match "context7") {
        Write-Host "  OK context7 MCP" -ForegroundColor Green
    } else {
        Write-Host "  Adding context7 MCP..." -ForegroundColor Yellow
        claude mcp add context7 -s user -- npx -y "@upstash/context7-mcp@latest" 2>$null
    }

    if ($mcpList -match "github") {
        Write-Host "  OK github MCP" -ForegroundColor Green
    } else {
        Write-Host "  Adding github MCP..." -ForegroundColor Yellow
        claude mcp add github -s user -- npx -y "@modelcontextprotocol/server-github" 2>$null
    }
}

# --- 10. Skills & plugins (git clone - not interactive commands) ---
Write-Host ""
Write-Host "Setting up skills & plugins..."

$SkillsDir = "$HOME\.claude\skills"
$PluginsDir = "$HOME\.claude\plugins\marketplaces"
if (-not (Test-Path $SkillsDir)) { New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null }
if (-not (Test-Path $PluginsDir)) { New-Item -ItemType Directory -Path $PluginsDir -Force | Out-Null }

# gstack + all org skills
if (Test-Path "$SkillsDir\.git") {
    Write-Host "  OK skills (pulling latest)" -ForegroundColor Green
    git -C $SkillsDir pull --ff-only 2>$null
} elseif (Test-Path "$SkillsDir\gstack") {
    Write-Host "  OK gstack (already present)" -ForegroundColor Green
} else {
    Write-Host "  Installing skills (gstack + all org skills)..." -ForegroundColor Yellow
    git clone https://github.com/Wakewell-Sleep-Solutions/claude-skills-ecosystem.git "$SkillsDir" 2>$null
    if ($?) { Write-Host "  OK skills installed" -ForegroundColor Green }
    else { Write-Host "  Skills clone failed - need GitHub access" -ForegroundColor Red }
}

# claude-mem
if (Test-Path "$PluginsDir\thedotmack") {
    Write-Host "  OK claude-mem (pulling latest)" -ForegroundColor Green
    git -C "$PluginsDir\thedotmack" pull --ff-only 2>$null
} else {
    Write-Host "  Installing claude-mem..." -ForegroundColor Yellow
    git clone https://github.com/thedotmack/claude-mem.git "$PluginsDir\thedotmack" 2>$null
    if ($?) { Write-Host "  OK claude-mem installed" -ForegroundColor Green }
    else { Write-Host "  claude-mem clone failed" -ForegroundColor Red }
}

# ralph-loop
if (Test-Path "$PluginsDir\claude-plugins-official") {
    Write-Host "  OK ralph-loop (pulling latest)" -ForegroundColor Green
    git -C "$PluginsDir\claude-plugins-official" pull --ff-only 2>$null
} else {
    Write-Host "  Installing ralph-loop..." -ForegroundColor Yellow
    git clone https://github.com/claude-plugins-official/ralph-loop.git "$PluginsDir\claude-plugins-official" 2>$null
    if ($?) { Write-Host "  OK ralph-loop installed" -ForegroundColor Green }
    else { Write-Host "  ralph-loop clone failed" -ForegroundColor Red }
}

# --- 11. Clean stale worktrees ---
$repoDirs = @("$Projects\Claude", "$Projects\super-rcm", "$Projects\5dsmiles-landing", "$Projects\WakewellWeb", "$Projects\claude-skills-ecosystem")
foreach ($d in $repoDirs) {
    if (Test-Path "$d\.git") {
        git -C $d worktree prune 2>$null
    }
}

# --- Done ---
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  Setup Complete!"                        -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Your projects:"
Write-Host "  aria (org hub)     -> cd ~\Documents\Claude; claude"
Write-Host "  rcm (data server)  -> cd ~\Documents\super-rcm; claude"
Write-Host "  dashboard          -> cd ~\Documents\5dsmiles-landing; claude"
Write-Host "  wakewellweb        -> cd ~\Documents\WakewellWeb; claude"
Write-Host "  skills             -> cd ~\Documents\claude-skills-ecosystem; claude"
Write-Host ""
Write-Host "Start:     cd ~\Documents\Claude; claude"
Write-Host ""
