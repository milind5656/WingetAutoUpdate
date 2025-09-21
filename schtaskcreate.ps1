# === Setup target folder ===
$targetFolder = "C:\Program Files\Winget Logs"
$iconFolder = Join-Path $targetFolder "Icons"
$sourceFolder = "$PSScriptRoot"  # Assumes files are in the same folder as this script

# Create folders if missing
if (-not (Test-Path $targetFolder)) { New-Item -Path $targetFolder -ItemType Directory -Force }
if (-not (Test-Path $iconFolder)) { New-Item -Path $iconFolder -ItemType Directory -Force }

# === Copy files ===
Copy-Item -Path (Join-Path $sourceFolder "WingetUpdate.ps1") -Destination $targetFolder -Force
Copy-Item -Path (Join-Path $sourceFolder "update_pending.png") -Destination $iconFolder -Force
Copy-Item -Path (Join-Path $sourceFolder "update_done.png") -Destination $iconFolder -Force

# === Create scheduled task ===
$taskName = "WingetAutoUpdate"
$scriptPath = Join-Path $targetFolder "WingetUpdate.ps1"

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -Daily -At 9:00AM
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
    -StartWhenAvailable -WakeToRun -AllowHardTerminate
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger `
    -Settings $settings -User "$env:USERNAME" -RunLevel Highest -Force

Write-Host "✅ WingetAutoUpdate task created successfully."
Write-Host "📁 Files copied to: $targetFolder"
