## Speed up downloads for WSUS

To increase the download speed for WSUS you will have to set the BITS service priority, to do so configure with the following:

### Check to see if BITS download priority foreground is set to True or False (Default is False)

```powershell
(get-wsusserver).GetConfiguration().BitsDownloadPriorityForeground
```

### Set and save the configuration to True

```powershell
$Configuration=(Get-WSUSServer).GetConfiguration()
$Configuration.BitsDownloadPriorityForeground=$True
$Configuration.Save()
```

### To change it back to normal just set it back to False

```powershell
$Configuration=(Get-WSUSServer).GetConfiguration()
$Configuration.BitsDownloadPriorityForeground=$False
$Configuration.Save()
```
