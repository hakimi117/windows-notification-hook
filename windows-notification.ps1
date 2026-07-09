# Windows Notification for Claude Code
# Compatible with Windows 10/11 using multiple fallback methods

param(
    [string]$Title = "Claude Code",
    [string]$Message = "Task Completed"
)

# Method 1: Toast Notification using PowerShell's registered AUMID (always works on Win10/11)
function Send-ToastNotification {
    try {
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
        # Use PowerShell's own AUMID - it is always registered in Windows
        $aumid = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B5}\WindowsPowerShell\v1.0\powershell.exe'
        $template = '<toast><visual><binding template="ToastText02"><text id="1">' + $Title + '</text><text id="2">' + $Message + '</text></binding></visual><audio src="ms-winsoundevent:Notification.Default"/></toast>'

        $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
        $xml.LoadXml($template)
        $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($aumid).Show($toast)
        return $true
    } catch {
        return $false
    }
}

# Method 2: Windows Forms Balloon Notification (Fallback) - no blocking sleep
function Send-BalloonNotification {
    try {
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing

        $notification = New-Object System.Windows.Forms.NotifyIcon
        $notification.Icon = [System.Drawing.SystemIcons]::Information
        $notification.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
        $notification.BalloonTipTitle = $Title
        $notification.BalloonTipText = $Message
        $notification.Visible = $true

        # Show the tray balloon for about 8 seconds
        $notification.ShowBalloonTip(8000)

        # Keep the object alive so the balloon renders before disposal
        Start-Sleep -Milliseconds 8500

        $notification.Visible = $false
        $notification.Dispose()

        return $true
    } catch {
        return $false
    }
}

$success = Send-ToastNotification
if (-not $success) {
    $success = Send-BalloonNotification
}

if ($success) {
    exit 0
} else {
    exit 1
}
