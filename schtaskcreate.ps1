# === Define source and target folders ===
$sourceFolder = "$PSScriptRoot"  # Assumes script is run from same folder as files
$targetFolder = "C:\Program Files\Winget Logs"
$iconFolder = Join-Path $targetFolder "Icons"

# === Create folders ===
New-Item -Path $targetFolder -ItemType Directory -Force | Out-Null
New-Item -Path $iconFolder -ItemType Directory -Force | Out-Null

# === Define source files ===
$updateScript = Join-Path $sourceFolder "WingetUpdate.ps1"
$iconPending = Join-Path $sourceFolder "update_pending.png"
$iconDone = Join-Path $sourceFolder "update_done.png"

# === Validate and copy files ===
if (Test-Path $updateScript) {
    Copy-Item -Path $updateScript -Destination $targetFolder -Force
} else {
    Write-Host "❌ WingetUpdate.ps1 not found in $sourceFolder"
}

if (Test-Path $iconPending) {
    Copy-Item -Path $iconPending -Destination $iconFolder -Force
} else {
    Write-Host "❌ update_pending.png not found in $sourceFolder"
}

if (Test-Path $iconDone) {
    Copy-Item -Path $iconDone -Destination $iconFolder -Force
} else {
    Write-Host "❌ update_done.png not found in $sourceFolder"
}

Write-Host "✅ Files copied to $targetFolder"

# === Create scheduled task ===
$taskName = "WingetAutoUpdate"
$scriptPath = Join-Path $targetFolder "WingetUpdate.ps1"

if (Test-Path $scriptPath) {
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
    $trigger = New-ScheduledTaskTrigger -Daily -At 9:00AM
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
        -StartWhenAvailable -WakeToRun -AllowHardTerminate
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger `
        -Settings $settings -User "$env:USERNAME" -RunLevel Highest -Force

    Write-Host "✅ Scheduled task '$taskName' created successfully."
} else {
    Write-Host "❌ Cannot create task. Script not found at $scriptPath"
}

