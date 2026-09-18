Spongebob me boi, PID 4 is the Windows **System** process. It usually means a kernel-mode component, most commonly **HTTP.sys**, owns the listening socket on behalf of another service. netstat alone cannot identify the actual service behind it.
## If it is an HTTP/HTTPS port
Run an elevated Command Prompt:

| 1     `netsh http show servicestate view``=``requestq verbose``=``yes` |
| --- |
Search the output for the port, URL, or IP address. Look for:

- **Registered URLs**

- **Request queue name**

- **Process IDs**

- **Controller process ID**

The process ID under the request queue often identifies the actual application using HTTP.sys. Microsoft documents this command as showing the current HTTP service state, including sessions and request queues. [[learn.microsoft.com]](https://learn.microsoft.com/en-us/windows/win32/http/show-servicestate), [[learn.microsoft.com]](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/netsh-http)

Also check URL registrations:

| 1     `netsh http show urlacl` |
| --- |
For HTTPS, inspect the certificate binding and its application GUID:

| 1     `netsh http show sslcert` |
| --- |
Or inspect one specific binding:

| 1     `netsh http show sslcert ipport``=``0.0.0.0``:``443` |
| --- |
The Application ID can help identify which application created the binding. These commands query and manage HTTP.sys configuration. [[learn.microsoft.com]](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/netsh-http), [[learn.microsoft.com]](https://learn.microsoft.com/en-us/windows/win32/http/netsh-commands-for-http)
## Map the resulting PID to a service
Replace 1234 with the process ID from servicestate:

| 1     ` tasklist /svc /fi  ``"PID eq 1234"` |
| --- |
PowerShell alternative:

| 1     `Get-CimInstance``  Win32_Service  ``|`2     `      ``Where-Object``  ProcessId  ``-eq``   ``1234``   ``|`3     `      ``Select-Object``  Name ``,``  DisplayName ``,``  State ``,``  StartName ``,``  PathName ` |
| --- |
For an svchost.exe PID:

| 1     ` tasklist /svc /fi  ``"PID eq 1234"` |
| --- |
This displays the Windows services hosted inside that specific svchost.exe.
## Quick port-specific workflow
For example, if port 5985 shows PID 4:

| 1     ` netstat  ``-`` ano | findstr  ``":5985"`2     `netsh http show servicestate view``=``requestq verbose``=``yes`3     ` netsh http show urlacl | findstr /i  ``"5985"` |
| --- |
PowerShell makes the initial lookup cleaner:

| 1     `Get-NetTCPConnection``   ``-`` LocalPort  ``5985``   ``-`` State Listen  ``|`2     `      ``Select-Object``  LocalAddress ``,``  LocalPort ``,``  OwningProcess ` |
| --- |
## If netsh http does not show the port
It may be owned directly by:

- A kernel-mode driver

- SMB/System networking

- RPC

- Another Windows kernel service

Check the common System-owned ports:

| 1     `Get-NetTCPConnection``   ``-`` OwningProcess  ``4``   ``-`` State Listen  ``|`2     `      ``Sort-Object``  LocalPort  ``|`3     `      ``Format-Table``  LocalAddress ``,``  LocalPort ` |
| --- |
Then examine relevant services and drivers:

| 1     `sc queryex type``=``  service state ``=``  all `2     `sc query type``=``  driver state ``=``  all ` |
| --- |
For the clearest GUI view, use **Sysinternals TCPView** and **Process Explorer**, run as administrator. However, even these may still show System when the endpoint is genuinely owned in kernel mode.

**Best starting command:**

| 1     `netsh http show servicestate view``=``requestq verbose``=``yes` |
| --- |
That is usually the command that reveals what is sitting behind PID 4.
