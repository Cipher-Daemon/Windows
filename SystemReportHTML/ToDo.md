# To Do

## Comment the following out

<img width="1318" height="882" alt="image" src="https://github.com/user-attachments/assets/e62ed59e-8687-4af5-8216-22d850ad8051" />
<img width="1525" height="421" alt="image" src="https://github.com/user-attachments/assets/da5c2806-ff01-49a5-aa3f-2d10ad836393" />


## Add some registry forensics

Example

```powershell
function Get-RegistryTreeData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    function Get-RegistryNode {
        param(
            [Microsoft.Win32.RegistryKey]$Key
        )

        $values = @{}

        foreach ($valueName in $Key.GetValueNames()) {
            try {
                $values[$valueName] = $Key.GetValue($valueName)
            }
            catch {
                $values[$valueName] = "<Error Reading Value>"
            }
        }

        $children = [System.Collections.Generic.List[object]]::new()

        foreach ($subKeyName in $Key.GetSubKeyNames()) {
            try {
                $subKey = $Key.OpenSubKey($subKeyName)

                if ($subKey) {
                    $children.Add(
                        (Get-RegistryNode -Key $subKey)
                    )
                }
            }
            catch {
                # Ignore inaccessible keys
            }
        }

        [pscustomobject]@{
            Name     = $Key.Name
            Values   = $values
            Children = $children
        }
    }

    $regKey = Get-Item -Path $Path

    Get-RegistryNode -Key $regKey
}

$RegTree = Get-RegistryTreeData -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
```
