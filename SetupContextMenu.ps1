Param(
    [bool]$uninstall=$false
)

# Global definitions
$config = "$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\profiles.json"
$resourcePath = "$env:LOCALAPPDATA\WindowsTerminalContextIcons\"
$resourcePathValue = "%LOCALAPPDATA%\WindowsTerminalContextIcons\"
$contextMenuIcoName = "terminal.ico"
$cmdIcoFileName = "cmd.ico"
$wslIcoFileName = "linux.ico"
$psIcoFileName = "powershell.ico"
$psCoreIcoFileName = "powershell-core.ico"
$azureCoreIcoFileName = "azure.ico"
$menuRegID = "WindowsTerminal"
$contextMenuLabel = "Open Windows Terminal here"
$contextMenuRoot = "Registry::HKEY_CURRENT_USER\Software\Classes\Directory"
$contextMenuRegPath = "$contextMenuRoot\shell\$menuRegID"
$contextBGMenuRegPath = "$contextMenuRoot\Background\shell\$menuRegID"
$subMenuRegPath = "$contextMenuRoot\ContextMenus\$menuRegID"
$subMenuRegRelativePath = "Directory\ContextMenus\$menuRegID"

# Setup icons

if($uninstall) {
  if((Test-Path -Path $resourcePath)) {
      Remove-Item -Recurse -Path $resourcePath
      Write-Host "Remove $resourcePath"
  } 
}
else {
  if(-Not (Test-Path -Path $resourcePath)) {
      New-Item -ItemType directory -Path $resourcePath | Out-Null
      Write-Host "Create path $resourcePath"
  }
  Copy-Item -Path "$PSScriptRoot\icons\*.ico" -Destination $resourcePath
  Write-Host "Copy $PSScriptRoot\icons\*.ico -> $resourcePath"
}

# Get Windows terminal profile
$rawContent = (Get-Content $config -Raw) -replace '(?m)(?<=^([^"]|"[^"]*")*)//.*' -replace '(?ms)/\*.*?\*/'

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

if((Test-Path -Path $subMenuRegPath)) {
    Remove-Item -Recurse -Force -Path $subMenuRegPath
    Write-Host "Clear reg $subMenuRegPath"
}

if($uninstall) {
    Exit
}

# Setup First layer context menu
[void](New-Item -Force -Path $contextMenuRegPath)
[void](New-ItemProperty -Path $contextMenuRegPath -Name ExtendedSubCommandsKey -PropertyType String -Value $subMenuRegRelativePath)
[void](New-ItemProperty -Path $contextMenuRegPath -Name Icon -PropertyType String -Value $resourcePathValue$contextMenuIcoName)
[void](New-ItemProperty -Path $contextMenuRegPath -Name MUIVerb -PropertyType String -Value $contextMenuLabel)
Write-Host "Add top layer menu (shell) => $contextMenuRegPath"

[void](New-Item -Force -Path $contextBGMenuRegPath)
[void](New-ItemProperty -Path $contextBGMenuRegPath -Name ExtendedSubCommandsKey -PropertyType String -Value $subMenuRegRelativePath)
[void](New-ItemProperty -Path $contextBGMenuRegPath -Name Icon -PropertyType String -Value $resourcePathValue$contextMenuIcoName)
[void](New-ItemProperty -Path $contextBGMenuRegPath -Name MUIVerb -PropertyType String -Value $contextMenuLabel)
Write-Host "Add top layer menu (background) => $contextMenuRegPath"

# Setup each profile item
$profiles | ForEach-Object {
    $profileName = $_.name
    $leagaleName = $profileName -replace '[ \r\n\t]', '-'
    $subItemRegPath = "$subMenuRegPath\shell\$leagaleName"
    $subItemCMDPath = "$subItemRegPath\command"

    $isHidden = $_.hidden
    $commandLine = $_.commandline
    $source = $_.source
    $icoPath = $_.icon

    if ($isHidden -eq $false) {
        [void](New-Item -Force -Path $subItemRegPath)
        [void](New-Item -Force -Path $subItemCMDPath)
        [void](New-ItemProperty -Path $subItemRegPath -Name "MUIVerb" -PropertyType String -Value "$profileName")
        [void](New-ItemProperty -Path $subItemCMDPath -Name "(default)" -PropertyType String -Value "$env:LOCALAPPDATA\Microsoft\WindowsApps\wt.exe -p `"$profileName`" -d %V")

        if($commandLine -eq "cmd.exe") {
            $icoPath = "$resourcePathValue$cmdIcoFileName"
        }
        elseif ($commandLine -eq "powershell.exe") {
            $icoPath = "$resourcePathValue$psIcoFileName"
        }
        elseif ($source -eq "Windows.Terminal.Wsl") {
            $icoPath = "$resourcePathValue$wslIcoFileName"
        }
        elseif ($source -eq "Windows.Terminal.PowershellCore") {
            $icoPath = "$resourcePathValue$psCoreIcoFileName"
        }
        elseif ($source -eq "Windows.Terminal.Azure") {
            $icoPath = "$resourcePathValue$azureCoreIcoFileName"
        }

        if($icoPath -ne "") {
            [void](New-ItemProperty -Path $subItemRegPath -Name "Icon" -PropertyType String -Value "$icoPath")
        }
    }
    Write-Host "Add new entry $profileName"
}
