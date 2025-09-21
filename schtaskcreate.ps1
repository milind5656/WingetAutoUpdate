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
try {
    Invoke-WebRequest -Uri $updateScriptUrl -OutFile (Join-Path $targetFolder "WingetUpdate.ps1") -UseBasicParsing
    Invoke-WebRequest -Uri $iconPendingUrl -OutFile (Join-Path $iconFolder "update_pending.png") -UseBasicParsing
    Invoke-WebRequest -Uri $iconDoneUrl -OutFile (Join-Path $iconFolder "update_done.png") -UseBasicParsing
    Write-Host "✅ Files downloaded to $targetFolder"
} catch {
    Write-Host "❌ Failed to download one or more files: $_"
    return
}

# === Create scheduled task ===
$taskName = "WingetAutoUpdate"
$taskDescription = "Runs daily to update installed apps via Winget and show toast notifications"
$scriptPath = Join-Path $targetFolder "WingetUpdate.ps1"

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -Daily -At 9:00AM
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -WakeToRun

try {
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger `
        -Settings $settings -User "$env:USERNAME" -RunLevel Highest -Description $taskDescription -Force
    Write-Host "✅ Scheduled task '$taskName' created successfully."
} catch {
    Write-Host "❌ Failed to create scheduled task: $_"
}
