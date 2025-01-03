Set Security log to:

1GB
```cmd
wevtutil sl "Security" /ms:1073741824
```

4GB:
```cmd
wevtutil sl "Security" /ms:4294967296
```

Default:
```cmd
wevtutil sl "Security" /ms:20971520
```
