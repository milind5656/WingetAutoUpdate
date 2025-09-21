# Import BurntToast for notifications
Import-Module BurntToast -ErrorAction SilentlyContinue

# === Setup paths ===
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logDir = "C:\Program Files\Winget Logs"
$logPath = Join-Path $logDir "UpdateLog_$timestamp.txt"

# === Icons ===
$iconPending = Join-Path $logDir "Icons\update_pending.png"
$iconDone = Join-Path $logDir "Icons\update_done.png"
if (-not (Test-Path $iconPending)) { $iconPending = $null }
if (-not (Test-Path $iconDone)) { $iconDone = $null }

# === Check for updates ===
$updates = winget upgrade | Select-String "^\S" | ForEach-Object { $_.Line }
$updateCount = $updates.Count

# === No updates ===
if ($updateCount -eq 0 -or ($updates -join "`n") -match "No applicable update") {
    New-BurntToastNotification -Text "Winget Updates", "No updates available." -AppLogo $iconDone
    return
}

# === Notify start ===
New-BurntToastNotification -Text "Winget Updates", "$updateCount updates found. Installing..." -AppLogo $iconPending

# === Install updates one by one ===
foreach ($line in $updates) {
    $packageId = ($line -split '\s{2,}')[0]
    if ($packageId) {
        New-BurntToastNotification -Text "Installing", "$packageId..." -AppLogo $iconPending
        try {
            winget upgrade --id "$packageId" --accept-source-agreements --accept-package-agreements | Out-File -FilePath $logPath -Append
        } catch {
            Add-Content -Path $logPath -Value "❌ Failed to update $packageId: $_"
        }
    }
}

# === Notify completion ===
New-BurntToastNotification -Text "Winget Updates", "All updates installed successfully!" -AppLogo $iconDone
