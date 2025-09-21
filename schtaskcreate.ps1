# === Setup target folders ===
$targetFolder = "C:\Program Files\Winget Logs"
$iconFolder = Join-Path $targetFolder "Icons"
New-Item -Path $targetFolder -ItemType Directory -Force | Out-Null
New-Item -Path $iconFolder -ItemType Directory -Force | Out-Null

# === GitHub raw URLs ===
$repoBase = "https://raw.githubusercontent.com/milind5656/WingetAutoUpdate/main"
$updateScriptUrl = "$repoBase/WingetUpdate.ps1"
$iconPendingUrl = "$repoBase/update_pending.png"
$iconDoneUrl = "$repoBase/update_done.png"

# === Download files ===
Invoke-WebRequest -Uri $updateScriptUrl -OutFile (Join-Path $targetFolder "WingetUpdate.ps1") -UseBasicParsing
Invoke-WebRequest -Uri $iconPendingUrl -OutFile (Join-Path $iconFolder "update_pending.png") -UseBasicParsing
Invoke-WebRequest -Uri $iconDoneUrl -OutFile (Join-Path $iconFolder "update_done.png") -UseBasicParsing

Write-Host "✅ Files downloaded to $targetFolder"

# === Create scheduled task ===
$taskName = "WingetAutoUpdate"
$scriptPath = Join-Path $targetFolder "WingetUpdate.ps1"

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -Daily -At 9:00AM
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
    -StartWhenAvailable -WakeToRun -AllowHardTerminate
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger `
    -Settings $settings -User "$env:USERNAME" -RunLevel Highest -Force

Write-Host "✅ Scheduled task '$taskName' created successfully."
