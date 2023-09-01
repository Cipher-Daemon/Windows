# Dealing with Asymmetric Network Timings

If you have 2 machines over a network (Like a WAN) and the transmitting time is 10 ms but the responding time is 40 ms this may impact file transfers, to help with that run the following command on both Windows machines/servers to help reduce some issues that may cause due to this.

(Note: Default value is disabled)

```cmd
netsh int tcp set global timestamps=enabled
```
When its completed successfully you should see this result:

```
C:\Users\Administrator>netsh int tcp show global
Querying active state...

TCP Global Parameters
----------------------------------------------
Receive-Side Scaling State          : enabled
Receive Window Auto-Tuning Level    : normal
Add-On Congestion Control Provider  : default
ECN Capability                      : enabled
RFC 1323 Timestamps                 : enabled  <---
Initial RTO                         : 3000
Receive Segment Coalescing State    : enabled
Non Sack Rtt Resiliency             : disabled
Max SYN Retransmissions             : 2
Fast Open                           : disabled
Fast Open Fallback                  : enabled
HyStart                             : enabled
Pacing Profile                      : off
```
