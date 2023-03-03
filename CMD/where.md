# Where

##Useful for finding files, better alternative than piping the recursive command to the find string

## Syntax

where [Switches] [File pattern(s)]

## Switches
```
/R = Recursively searches

/Q = Quiet mode, only returns an exit code
  0 = Success
  1 = Search Unsuccessful
  2 = Failure or Errors
  (Get the error code by typing "echo %errorcode%")

/F = Displays files in double quotes

/T = Displays the file size and last modified time for the matching file(s)
```

## Examples

To find all .docx files in the C:\Users folder recursively:

```
where /r c:\users *.docx
```
