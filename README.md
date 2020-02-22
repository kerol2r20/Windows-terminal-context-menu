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
* Custom icon for profile

# Install
1. Clone this repo
`git clone https://github.com/kerol2r20/Windows-terminal-context-menu`

2. Run powershell as adminstrator
3. Run `SetupContextMenu.ps1` script

# Uninstall
1. Run `SetupContextMenu.ps1 -uninstall:$true`

# Misc
I'm not sure that icons file are legal or not. If you feel not ok, please tell me. Thanks.
