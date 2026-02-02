# install cli colors for both powershell and cmd (clink). run once from d:\dev\cli.

$ErrorActionPreference = "SilentlyContinue"
$scriptRoot = $PSScriptRoot

# --- powershell: profile + cli-colors.ps1 ---
$profileDir = Split-Path -Parent $PROFILE
if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
$line = '. "' + (Join-Path $scriptRoot "cli-colors.ps1") + '"'
$content = $null
if (Test-Path $PROFILE) { $content = Get-Content $PROFILE -Raw }
if ($content -and $content.Trim().Contains("cli-colors.ps1")) {
  Write-Host "PowerShell: cli-colors.ps1 already in profile." -ForegroundColor Yellow
} else {
  Add-Content -Path $PROFILE -Value "`n# cli sphere colors`n$line"
  Write-Host "PowerShell: installed cli-colors.ps1 into profile." -ForegroundColor Green
}

# --- windows terminal: default profile = powershell ---
$wtScript = Join-Path $scriptRoot "wt-sphere.js"
if (Test-Path $wtScript) {
  try {
    $null = node $wtScript --set-powershell-default 2>&1
    if ($LASTEXITCODE -eq 0) { Write-Host "Windows Terminal: default profile set to PowerShell." -ForegroundColor Green }
  } catch { }
}

# --- cmd (clink): copy prompt + completions (colored prompt, git branch, tab completions, autosuggestions) ---
$clinkDirs = @("$env:LOCALAPPDATA\clink", "$env:USERPROFILE\.clink")
$clinkScripts = @("clink_prompt.lua", "clink_completions.lua")
$installedClink = $false
foreach ($dir in $clinkDirs) {
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  try {
    foreach ($name in $clinkScripts) {
      $src = Join-Path $scriptRoot $name
      if (Test-Path $src) { Copy-Item -Path $src -Destination (Join-Path $dir $name) -Force }
    }
    Write-Host "CMD (Clink): installed prompt + completions to $dir" -ForegroundColor Green
    $installedClink = $true
    break
  } catch { }
}
if (-not $installedClink) {
  foreach ($name in $clinkScripts) {
    $src = Join-Path $scriptRoot $name
    if (Test-Path $src) { Copy-Item -Path $src -Destination (Join-Path $clinkDirs[0] $name) -Force }
  }
  Write-Host "CMD (Clink): copied scripts to $($clinkDirs[0]) (install Clink: https://chrisant996.github.io/clink/)" -ForegroundColor Cyan
}

Write-Host "`nProfile: $PROFILE" -ForegroundColor Cyan
Write-Host "PowerShell / WT: full colors. CMD (Clink): colored prompt, git branch, tab completions (npm/git/node), autosuggestions." -ForegroundColor Gray
Write-Host "Restart PowerShell or run: . `$PROFILE" -ForegroundColor Cyan
