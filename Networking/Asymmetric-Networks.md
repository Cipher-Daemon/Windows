# Dealing with Asymmetric Network Timings

If you have 2 machines over a network (Like a WAN) and the sending time is 10 ms but the responding time is 40 ms this may impact file transfers, to help with that run the following command on both Windows machines/servers to get better performance

(Note: Default value is disabled)

```cmd
netsh int tcp set global timestamps=enabled
```
