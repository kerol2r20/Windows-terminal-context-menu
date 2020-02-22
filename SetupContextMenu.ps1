#Requires -RunAsAdministrator

Param(
    [bool]$uninstall=$false
)

# Global definitions
$config = "$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\profiles.json"
$resourcePath = "$env:LOCALAPPDATA\WindowsTerminalContextIcons\"
$contextMenuIcoName = "terminal.ico"
$cmdIcoFileName = "cmd.ico"
$wslIcoFileName = "linux.ico"
$psIcoFileName = "powershell.ico"
$psCoreIcoFileName = "powershell-core.ico"
$azureCoreIcoFileName = "azure.ico"
$menuRegID = "WindowsTerminal"
$contextMenuLabel = "Open Windows Terminal here"
$contextMenuRegPath = "Registry::HKEY_CLASSES_ROOT\Directory\shell\$menuRegID"
$contextBGMenuRegPath = "Registry::HKEY_CLASSES_ROOT\Directory\background\shell\$menuRegID"
$subMenuRegRelativePath = "Directory\ContextMenus\$menuRegID"
$subMenuRegPath = "Registry::HKEY_CLASSES_ROOT\Directory\ContextMenus\$menuRegID\shell\"

# Setup icons

Copy-Item -Path "$PSScriptRoot\icons\*.ico" -Destination $resourcePath

# Get Windows terminal profile
$rawContent = (Get-Content $config -Raw) -replace '(?m)(?<=^([^"]|"[^"]*")*)//.*' -replace '(?ms)/\*.*?\*/'

$profiles = (ConvertFrom-Json -InputObject $rawContent).profiles.list

# Clear register

if((Test-Path -Path $contextMenuRegPath)) {
    # If reg has existed
    Remove-Item -Recurse -Force -Path $contextMenuRegPath
}

if((Test-Path -Path $contextBGMenuRegPath)) {
    Remove-Item -Recurse -Force -Path $contextBGMenuRegPath
}

if((Test-Path -Path $subMenuRegPath)) {
    Remove-Item -Recurse -Force -Path $subMenuRegPath
}

if($uninstall) {
    Exit
}

# Setup First layer context menu
New-Item -Path $contextMenuRegPath
New-ItemProperty -Path $contextMenuRegPath -Name ExtendedSubCommandsKey -PropertyType String -Value $subMenuRegRelativePath
New-ItemProperty -Path $contextMenuRegPath -Name Icon -PropertyType String -Value $resourcePath$contextMenuIcoName
New-ItemProperty -Path $contextMenuRegPath -Name MUIVerb -PropertyType String -Value $contextMenuLabel

New-Item -Path $contextBGMenuRegPath
New-ItemProperty -Path $contextBGMenuRegPath -Name ExtendedSubCommandsKey -PropertyType String -Value $subMenuRegRelativePath
New-ItemProperty -Path $contextBGMenuRegPath -Name Icon -PropertyType String -Value $resourcePath$contextMenuIcoName
New-ItemProperty -Path $contextBGMenuRegPath -Name MUIVerb -PropertyType String -Value $contextMenuLabel

# Setup each profile item
$profiles | ForEach-Object {
    $profileName = $_.name
    $leagaleName = $profileName -replace '[ \r\n\t]', '-'
    $subItemRegPath = "$subMenuRegPath$leagaleName"
    $subItemCMDPath = "$subItemRegPath\command"

    $isHidden = $_.hidden
    $commandLine = $_.commandline
    $source = $_.source
    $icoPath = ""

    if ($isHidden -eq $false) {
        New-Item -Force -Path $subItemRegPath
        New-Item -Force -Path $subItemCMDPath
        New-ItemProperty -Path $subItemRegPath -Name "MUIVerb" -PropertyType String -Value "$profileName"
        New-ItemProperty -Path $subItemCMDPath -Name "(default)" -PropertyType String -Value "$env:LOCALAPPDATA\Microsoft\WindowsApps\wt.exe -p `"$profileName`" -d %V"

        if($commandLine -eq "cmd.exe") {
            $icoPath = $cmdIcoFileName
        }
        elseif ($commandLine -eq "powershell.exe") {
            $icoPath = $psIcoFileName
        }
        elseif ($source -eq "Windows.Terminal.Wsl") {
            $icoPath = $wslIcoFileName
        }
        elseif ($source -eq "Windows.Terminal.PowershellCore") {
            $icoPath = $psCoreIcoFileName
        }
        elseif ($source -eq "Windows.Terminal.Azure") {
            $icoPath = $azureCoreIcoFileName
        }

        if($icoPath -ne "") {
            New-ItemProperty -Path $subItemRegPath -Name "Icon" -PropertyType String -Value "$resourcePath$icoPath"
        }
    }
}
