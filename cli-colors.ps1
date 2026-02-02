# cli colors: directories red, errors pink, success green. source this from your profile or run install-colors.

# errors in pink
$Host.PrivateData.ErrorForegroundColor = "Magenta"
# warnings in yellow
$Host.PrivateData.WarningForegroundColor = "Yellow"
# verbose in gray
$Host.PrivateData.VerboseForegroundColor = "DarkGray"

# prompt: green when last command succeeded, red when failed
function global:Prompt {
  $ex = $?
  $path = (Get-Location).Path
  if ($path.Length -gt 40) { $path = "..." + $path.Substring($path.Length - 37) }
  if ($ex) { Write-Host "PS " -NoNewline -ForegroundColor Green }
  else    { Write-Host "PS " -NoNewline -ForegroundColor Red }
  Write-Host $path -NoNewline -ForegroundColor Cyan
  Write-Host "> " -NoNewline
  " "
}

# list with colors: directories red, files green, executables cyan
function global:lsc {
  param([string]$Path = ".", [string[]]$Filter = "*")
  Get-ChildItem -Path $Path -Filter ($Filter -join ",") -ErrorAction SilentlyContinue | ForEach-Object {
    $name = $_.Name
    if ($_.PSIsContainer) {
      Write-Host $name -ForegroundColor Red
    } else {
      $ext = [System.IO.Path]::GetExtension($name).ToLower()
      if ($ext -in ".exe", ".cmd", ".bat", ".ps1") { Write-Host $name -ForegroundColor Cyan }
      else { Write-Host $name -ForegroundColor Green }
    }
  }
}

# optional: alias 'dir' to lsc for colored listing (use Get-ChildItem for piping)
Set-Alias -Name dirc -Value lsc -Option AllScope -ErrorAction SilentlyContinue

Write-Host "cli colors loaded: prompt green/red, lsc/dirc for colored dirs (red=dir, green=file, cyan=exe), errors=pink" -ForegroundColor DarkGray
