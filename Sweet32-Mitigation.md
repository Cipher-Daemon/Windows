# Sweet32 Mitigation

```powershell
$Ciphers = (Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Cryptography\Configuration\Local\SSL\00010002 -Name Functions).Functions

$DESCheck = $Ciphers |?{$_ -like "*DES*" -or $_ -like "*RC4*"}

if ($DESCheck.count -eq 0){
    write-host "No DES Cipher Variants Found! Exiting!"
}else{
    $Ciphers = $Ciphers |?{$_ -notlike "*DES*" -and $_ -notlike "*RC4*"}
    set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Cryptography\Configuration\Local\SSL\00010002 -Name Functions -Value $Ciphers
    write-host "Cipher settings for the registry have been changed, a reboot is required to be applied!"
}
```
