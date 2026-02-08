# install.ps1
$repo = "Shaifhassan/open-report-cli-release"
$file = "open_report.exe"
$url = "https://github.com/$repo/releases/latest/download/$file"
$dest = "$env:USERPROFILE\AppData\Local\OpenReport\open_report.exe"

# 1. Create directory
if (!(Test-Path (Split-Path $dest))) { New-Item -ItemType Directory -Path (Split-Path $dest) }

# 2. Download
Write-Host "Downloading latest release from $repo..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $url -OutFile $dest
Write-Host "Successfully installed $file" -ForegroundColor Green

# 3. Add to User Path (so 'open_report' works in cmd/powershell)
$oldPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
if ($oldPath -notlike "*OpenReport*") {
    $newPath = "$oldPath;$(Split-Path $dest)"
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "✅ Installation complete. Restart your shell."
}