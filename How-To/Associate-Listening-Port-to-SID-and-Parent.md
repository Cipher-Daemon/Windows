# Listening port to Process

This is how you get info on programs listening on specific ports.

```powershell
$Port = read-host "Listening port (TCP)"
 
$Connection = Get-NetTCPConnection -LocalPort $Port -State Listen
$PIDFound = $Connection.OwningProcess
 
Get-CimInstance Win32_Process -Filter "ProcessId = $PIDFound" |Select-Object ProcessId, ParentProcessId, ExecutablePath, CommandLine |fl
```
