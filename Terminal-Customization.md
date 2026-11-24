You can customize you terminal how you want

`C:\Users\USERNAME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`


```json
"profiles": 
    {
        "defaults": {},
        "list": 
        [
            {
                "commandline": "%SystemRoot%\\System32\\WindowsPowerShell\\v1.0\\powershell.exe",
                "guid": "{********-****-****-****-************}",
                "hidden": false,
                "name": "Windows PowerShell",
                "opacity": 80,
                "backgroundImage": "C:\\Users\\USER\\Pictures\\ANY-IMAGE.jpeg",
                "backgroundImageAlignment": "center",
                "backgroundImageOpacity": 0.3,
                "backgroundImageStretchMode": "uniformToFill"
            },
            {
                "commandline": "%SystemRoot%\\System32\\cmd.exe",
                "guid": "{********-****-****-****-************}",
                "hidden": false,
                "name": "Command Prompt"
            },
            {
                "guid": "{********-****-****-****-************}",
                "hidden": false,
                "name": "Azure Cloud Shell",
                "source": "Windows.Terminal.Azure"
            }
        ]
    },
```

Optional Colors (To distinguish profiles)
- Administrator `#6B0002`
