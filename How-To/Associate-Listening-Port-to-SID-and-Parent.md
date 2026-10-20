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

Continuous
```powershell
while ($True){$Port = read-host "Listening port (TCP)";if ($port.length -eq 0) {return};$Connection = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorVariable Notfound -ErrorAction SilentlyContinue ;if($NotFound){write-host "Nothing found";continue}else{$PIDFound = $Connection.OwningProcess;Get-CimInstance Win32_Process -Filter "ProcessId = $PIDFound" |Select-Object Name, ProcessId, ParentProcessId, ExecutablePath, CommandLine |fl}}
```
# To Do :hammer_and_wrench:
- [ ] \(Required) Fix or add logic to only use the first index object in an array to prevent syntax errors when its using the `Get-NetTCPConnection` command.
  - [ ] Additionally add a error variable and error action to `silentlycontinue` if `Get-NetTCPConnection` comes back with nothing.
- [ ] \(Optional but nice to have) when above is added, add logic if `Get-NetTCPConnection` comes back with multiple results to display and select.
