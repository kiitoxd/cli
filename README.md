Black hole background for CLI
*run from project folder (e.g. `cd d:\dev\cli`). cli output uses picocolors (color highlighting) by default.

CLI colors (directories red, errors pink, success green) – applies to both PowerShell and CMD
*install once: from project folder run `powershell -ExecutionPolicy Bypass -File install-colors.ps1`
*installer does: (1) PowerShell profile = full colors, (2) Windows Terminal default = PowerShell, (3) copies Clink scripts for CMD: colored prompt (path red, status green/red), git branch in prompt, tab completions (npm/git/node), and Clink’s built-in autosuggestions (Right/End to accept). Install Clink first: https://chrisant996.github.io/clink/ (e.g. `winget install clink`); then `clink autorun install` so CMD loads Clink automatically.
*optional: run `cli.bat` (or pin to taskbar) to open PowerShell with colors in one click.
