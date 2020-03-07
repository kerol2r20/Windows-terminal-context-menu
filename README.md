# 🧾 Windows-terminal-context-menu 

![](https://i.imgur.com/gDG1nJs.png)

Inspire from Windows terminal issue [Add "open Windows terminal here" into right-click context menu #1060](https://github.com/microsoft/terminal/issues/1060). Thanks you all giants ❤

Windows terminal is an excellent terminal. But it no offer a basic function which is **right click context menu**!  
Without it, I have to `cd` to my working directory everytime. It's inefficient.  

So I write this script to deal with it.

# Feature
* Two layers context menu
* Auto parse profiles.json to contruct menu
* With uninstaller

# Todo
- [x] Custom icon for profile

# Install
1. Clone this repo
`git clone https://github.com/kerol2r20/Windows-terminal-context-menu`

2. Run powershell (no need to get admin access right)
3. Change the execution policy `Set-ExecutionPolicy RemoteSigned -scope CurrentUser`
4. Run `SetupContextMenu.ps1` script

⚠️ If you found there are no any item in your context menu, it may cause by the old style profiles.json. You can delete `%LocalAppData%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\profiles.json` and restart Windows terminal, it will generate a new one. Ref to [microsoft/terminal#4556](https://github.com/microsoft/terminal/pull/4556) 

# Uninstall
1. Run `SetupContextMenu.ps1 -uninstall:$true`

# Config
This script will parse the `profiles.json` file to generate menu items. However you can customize it.  
Put any icon file into `icon` folder and modify the `config.json` like the following.

```json
{
    "global": {
        "extended": false
    },
    "profiles": {
        "{a5a97cb8-8961-5535-816d-772efe0c6a3f}": {
            "icon": "arch.ico",
            "label": "Arch Linux"
        }
    }
}
```

**Config reference**
- global
  - extended[bool]: if set this to true, context menu will only show up when right click with `shift`
- profiles
  - guid[string]: this GUID of your profile defined in `profiles.json`
    - icon[string]: filename of your ico file, **you must put this file in icon folder**
    - label[string]: context menu label

# Misc
I'm not sure that icons file are legal or not. If you feel not ok, please tell me. Thanks.
