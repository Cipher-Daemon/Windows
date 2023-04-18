# Robocopy Commands

## To exclude existing files

```cmd
robocopy c:\Sourcepath c:\Destpath /E /XC /XN /XO
```
- /E copies recursively including empty directories
- /XC excludes existing files with same timestamp but diff file size
- /XN excludes existing files newer than the copy in the source directory
- /XO excludes existing files older than the copy in the source directory
