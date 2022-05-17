# pktmon

pktmon is a built in utility to capture network packets. By default the program saves the file with the name of Pktmon.etl. By default the program can only write up to 512 MB and will overwrite old entries once it reaches its max file size.

## My Useful Commands:

### To start a packet capture in current directory.:
```
pktmon start -c
```

### To start a packet capture to specific directory and filename.:
```
pktmon start -c -f c:\path\to\file.etl
```

### To stop a packet capture
```
pktmon stop
```

### To convert an etl file to pcapng file:
```
pktmon etl2pcap file.etl
```

### To write file without circular logging
```
pktmon start --capture --pkt-size 0 --log-mode multi-file
```
The Zero in --pkt-size means to log all packets no matter the size.

The Multi-File in --log-mode means to create a new file when the max file size has reached. By default it does in circular logging which means it'll overwrite old entries when the max file size has been reached (default is 512MB)
