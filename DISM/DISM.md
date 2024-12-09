# DISM

## Starting Variables

WIM file location
```powershell
$WIMFile = read-host "WIM File Focation"
```

Get the index needed
```powershell
dism /Get-WimInfo /WimFile:$WIMFile
$WIMIndex = read-host "Select Index"
```
NTFS Mount Folder
```powershell
$MountPoint = read-host "NTFS Mount Point Location"
```
New WIM File

```powershell
$NewWIMFile = read-host "New WIM File"
```

## Mount to a folder
```powershell
DISM /Mount-image /imagefile:$WIMFile /index:$WIMIndex /MountDir:$MountPoint
```

## Inject updates

Add list of updates
```powershell
$UpdatePackages = @()
while ($input = read-host "Update Package Location (Blank if finish)"){
    if($input -eq "" -or $input -eq $null) {break}
    $UpdatePackages += $input
}

```

Install updates
```powershell
ForEach ($Update in $UpdatePackages){
    write-host -foregroundcolor yellow "Installing $Update"
    Dism /Image:$MountPoint /Add-Package /packagepath:$Update

}
```

## Unmount/Commit

Reset Base
```powershell
Dism /Image:$MountPoint /Cleanup-Image /StartComponentCleanup /ResetBase
```

Unmount Image

```powershell
Dism /Unmount-image /MountDir:$MountPoint /commit
```

Extract a Smaller Image

```powershell
Dism /Export-Image /SourceImageFile:$WIMFile /sourceindex:$WIMIndex /DestinationImageFile:$NewWIMFile /compress:max /checkintegrity
```
