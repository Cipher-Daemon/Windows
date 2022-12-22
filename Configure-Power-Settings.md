# Configure Power Settings via CLI

Configuring power settings with CMD can be helpful if you are doing windows deployment or making a script to machines that have the same hardware. This really saves time especially if the tasks are repetitive.

## Heres what you need to do:

To get the power scheme and all of its settings you run this:
```
powercfg /q
```
Well use the hard disk as an example
```
PS C:\Users\Administrator> powercfg /q
Power Scheme GUID: 381b4222-f694-41f0-9685-ff5bb260df2e  (Balanced)
  GUID Alias: SCHEME_BALANCED
  Subgroup GUID: 0012ee47-9041-4b5d-9b77-535fba8b1442  (Hard disk)
    GUID Alias: SUB_DISK
    Power Setting GUID: 6738e2c4-e8a5-4a42-b16a-e040e769756e  (Turn off hard disk after)
      GUID Alias: DISKIDLE
      Minimum Possible Setting: 0x00000000
      Maximum Possible Setting: 0xffffffff
      Possible Settings increment: 0x00000001
      Possible Settings units: Seconds
    Current AC Power Setting Index: 0x0000001e
    Current DC Power Setting Index: 0x0000001e
```
## Syntax

For AC (plugged into a wall outlet) you will use the /SETACVALUEINDEX flag swithc (for DC/Battery settings you just replace AC with DC for that switch)

```
powercfg /SETACVALUEINDEX [Power scheme GUID/Alias] [Sub GUID/Alias] [Power setting GUID/Alias}
```

## For example the following two are valid on setting the hard disk to never sleep 

GUID way:
```
powercfg /SETACVALUEINDEX 381b4222-f694-41f0-9685-ff5bb260df2e 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0
```

Alias way:
```
powercfg /SETACVALUEINDEX SCHEME_BALANCED SUB_DISK DISKIDLE 0
```
