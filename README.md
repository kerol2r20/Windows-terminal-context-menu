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
- [ ] Easy uninstall method

# Install
1. Clone this repo
`git clone https://github.com/kerol2r20/Windows-terminal-context-menu`

2. Run powershell (no need to get admin access right)
3. Run `SetupContextMenu.ps1` script

# Uninstall
1. Run `SetupContextMenu.ps1 -uninstall:$true`

# Config
This script will parse the `profiles.json` file to generate menu items. However you can customize it.  
Put any icon file into `icon` folder and modify the `config.json` like the following.

```json
{
    "profiles": {
        "{a5a97cb8-8961-5535-816d-772efe0c6a3f}": {
            "icon": "arch.ico",
            "label": "Arch Linux"
        }
    }
}
```

1. Profile key is the guid of windows terminal profile
2. `icon` is the icon file name. **You have to put .ico file info icon folder**
3. `label` is label of the menu item

# Misc
I'm not sure that icons file are legal or not. If you feel not ok, please tell me. Thanks.
