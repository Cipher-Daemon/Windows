# Audit SMBv1

To activate auditing via powershell

```powershell
Set-SmbServerConfiguration –AuditSmb1Access $true
```

To enable via registry

```cmd
reg add HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters /v AuditSmb1Access /t REG_DWORD /d 1
```
