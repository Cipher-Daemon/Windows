# Create and access shadow copy

## Creating and Accessing

### Create for the entire C:\ drive
```powershell
Invoke-CimMethod -ClassName Win32_ShadowCopy -MethodName Create -Arguments @{Volume = "C:\";Context = "ClientAccessible"}
```
A ReturnValue 0 means it was done successfully.

### List existing Shadow Copies
```powershell
Get-CimInstance -ClassName Win32_ShadowCopy | Select-Object ID, VolumeName, InstallDate, DeviceObject
```
### Access/Mount shadow copy

> [!Note]
> A trailing backslash at the end of `HarddiskVolumeShadowCopy` is required!

```batch
cmd /c mklink /d C:\temp\SC "\\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy4\"
```

## Cleanup

```
Get-CimInstance -ClassName Win32_ShadowCopy | Where-Object { $_.ID -eq "{YOUR-SHADOW-ID-HERE}"} | Remove-CimInstance
```

Remove Symbolic link

```batch
cmd /c rmdir c:\temp\SC
```
