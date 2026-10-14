# Listening port to Process

This is how you get info on programs listening on specific ports.

```powershell
$Port = read-host "Listening port (TCP)"
 
$Connection = Get-NetTCPConnection -LocalPort $Port -State Listen
$PIDFound = $Connection.OwningProcess
 
Get-CimInstance Win32_Process -Filter "ProcessId = $PIDFound" |Select-Object Name, ProcessId, ParentProcessId, ExecutablePath, CommandLine |fl
```

One Liner
```powershell
$Port = read-host "Listening port (TCP)";$Connection = Get-NetTCPConnection -LocalPort $Port -State Listen;$PIDFound = $Connection.OwningProcess;Get-CimInstance Win32_Process -Filter "ProcessId = $PIDFound" |Select-Object Name, ProcessId, ParentProcessId, ExecutablePath, CommandLine |fl
```

another one liner
```powershell
cls;$Port = read-host "Port number?" ; $PortNumber = ":" + $port;netstat -aon|findstr $PortNumber;$FoundPID = read-host "PID? ";Get-CimInstance Win32_Process -Filter "ProcessId = $FoundPID" |Select-Object Name, ProcessId, ParentProcessId, ExecutablePath, CommandLine |fl
```
