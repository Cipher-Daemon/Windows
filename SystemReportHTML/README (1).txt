WINDOWS SYSTEM REPORT - EXPANDABLE TEMPLATE
===========================================

FILES
-----
Windows-System-Report.ps1  PowerShell 5.1-compatible collector and HTML builder
report-template.html       HTML template with automatic section rendering
Output\                   Generated HTML and optional JSON output

QUICK START
-----------
1. Keep Windows-System-Report.ps1 and report-template.html in the same folder.
2. Open Windows PowerShell 5.1 in that folder.
3. Run:

   .\Windows-System-Report.ps1

4. The script creates Output\Windows-System-Report.html and opens it.

Optional JSON export:

   .\Windows-System-Report.ps1 -ExportJson

Create the HTML without opening it:

   .\Windows-System-Report.ps1 -NoOpen

HOW TO ADD A NEW SECTION
------------------------
A. Add a collector function in the COLLECTORS section of the PS1 file.

   function Get-MyExampleData {
       Get-CimInstance -ClassName Win32_OperatingSystem |
           Select-Object Caption, Version, BuildNumber, LastBootUpTime
   }

B. Add a section definition to $sectionDefinitions:

   [pscustomobject]@{
       Key = 'OperatingSystem'
       Title = 'Operating System'
       Description = 'Windows version and build information.'
       Type = 'table'
       Enabled = $true
       Collector = { Get-MyExampleData }
       Columns = @(
           [pscustomobject]@{ Key = 'Caption'; Label = 'Windows Edition' },
           [pscustomobject]@{ Key = 'Version'; Label = 'Version' },
           [pscustomobject]@{ Key = 'BuildNumber'; Label = 'Build' },
           [pscustomobject]@{ Key = 'LastBootUpTime'; Label = 'Last Boot' }
       )
   }

C. Run the PS1 file again. No HTML edits are needed for Type='table'.

SECTION TYPES
-------------
Type = 'table'
  Automatically creates a searchable HTML table. Provide Columns to control
  column order and friendly headings. If Columns is empty, headings are inferred
  from the properties in the returned objects.

Type = 'text'
  Displays searchable preformatted text. Useful for netstat, ipconfig, route
  print, wevtutil output, and other command-line text.

Type = 'processTree'
  Uses the built-in custom expandable process-tree visualization.

Type = 'error'
  Generated automatically if a collector throws an error. Other sections still
  continue collecting.

BUILT-IN EXAMPLES
-----------------
Enabled by default:
  - Process Tree
  - Netstat
  - Windows Services (demonstrates generic table rendering)

Included but disabled by default:
  - Network Adapters
  - Scheduled Tasks

To enable either example, find its definition in $sectionDefinitions and set:

   Enabled = $true

To disable an enabled section, set Enabled = $false.

IMPORTANT
---------
- Run the script from a Windows machine. It uses Windows CIM classes and tools.
- Run elevated when you need access to process owners, command lines, or other
  protected system information. Some information may remain unavailable without
  elevated rights.
- The HTML report contains process command lines and other system details. Treat
  it as sensitive information and store/share it accordingly.
- Do not open report-template.html expecting data: it is the blank template.
  Open Output\Windows-System-Report.html, which the PowerShell script generates.
