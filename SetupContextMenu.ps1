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
$subMenuRegRoot = "Registry::HKEY_CLASSES_ROOT\Directory\ContextMenus\$menuRegID"
$subMenuRegPath = "$subMenuRegRoot\shell\"

# Get Windows terminal profile
$rawContent = (Get-Content $config) -replace '^\s*\/\/.*' | Out-String
$profiles = (ConvertFrom-Json -InputObject $rawContent).profiles.list

# Clear register

if((Test-Path -Path $contextMenuRegPath)) {
    # If reg has existed
    Remove-Item -Recurse -Force -Path $contextMenuRegPath
    Write-Host "Clear reg $contextMenuRegPath"
}

if((Test-Path -Path $contextBGMenuRegPath)) {
    Remove-Item -Recurse -Force -Path $contextBGMenuRegPath
    Write-Host "Clear reg $contextBGMenuRegPath"
}

if((Test-Path -Path $subMenuRegRoot)) {
    Remove-Item -Recurse -Force -Path $subMenuRegRoot
    Write-Host "Clear reg $subMenuRegRoot"
}

if((Test-Path -Path $resourcePath)) {
    Remove-Item -Recurse -Force -Path $resourcePath
    Write-Host "Clear icon content folder $resourcePath"
}

if($uninstall) {
    Exit
}

# Setup icons
[void](New-Item -Path $resourcePath -ItemType Directory)
[void](Copy-Item -Path "$PSScriptRoot\icons\*.ico" -Destination $resourcePath)
Write-Output "Copy icons => $resourcePath"

# Setup First layer context menu
[void](New-Item -Path $contextMenuRegPath)
[void](New-ItemProperty -Path $contextMenuRegPath -Name ExtendedSubCommandsKey -PropertyType String -Value $subMenuRegRelativePath)
[void](New-ItemProperty -Path $contextMenuRegPath -Name Icon -PropertyType String -Value $resourcePath$contextMenuIcoName)
[void](New-ItemProperty -Path $contextMenuRegPath -Name MUIVerb -PropertyType String -Value $contextMenuLabel)
Write-Host "Add top layer menu (shell) => $contextMenuRegPath"

[void](New-Item -Path $contextBGMenuRegPath)
[void](New-ItemProperty -Path $contextBGMenuRegPath -Name ExtendedSubCommandsKey -PropertyType String -Value $subMenuRegRelativePath)
[void](New-ItemProperty -Path $contextBGMenuRegPath -Name Icon -PropertyType String -Value $resourcePath$contextMenuIcoName)
[void](New-ItemProperty -Path $contextBGMenuRegPath -Name MUIVerb -PropertyType String -Value $contextMenuLabel)
Write-Host "Add top layer menu (background) => $contextMenuRegPath"

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
        [void](New-Item -Force -Path $subItemRegPath)
        [void](New-Item -Force -Path $subItemCMDPath)
        [void](New-ItemProperty -Path $subItemRegPath -Name "MUIVerb" -PropertyType String -Value "$profileName")
        [void](New-ItemProperty -Path $subItemCMDPath -Name "(default)" -PropertyType String -Value "$env:LOCALAPPDATA\Microsoft\WindowsApps\wt.exe -p `"$profileName`" -d %V")

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
            [void](New-ItemProperty -Path $subItemRegPath -Name "Icon" -PropertyType String -Value "$resourcePath$icoPath")
        }
    }
    Write-Host "Add new entry $profileName"
}
