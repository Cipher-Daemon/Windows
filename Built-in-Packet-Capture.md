# pktmon

pktmon is a built in utility to capture network packets. By default the program saves the file with the name of Pktmon.etl. Also the program can only write 

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

### To convert an etl file to pcap file:
```
pktmon pcapnt file.etl
```

### To write file without circular logging
```
pktmon start --capture --pkt-size 0 --log-mode multi-file
```
The Zero in -p means to log all packets no matter the size.

The Multi-File in -l means to create a new file when the max file size has reached. By default it does in circular logging which means it'll overwrite old entries when the max file size has been reached (default is 512MB)
