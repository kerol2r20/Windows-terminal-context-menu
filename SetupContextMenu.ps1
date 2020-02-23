#Requires -RunAsAdministrator

Param(
    [bool]$uninstall=$false
)

# Global definitions
$config = "$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\profiles.json"
$resourcePath = "$env:LOCALAPPDATA\WindowsTerminalContextIcons\"
$resourcePathReg = "%LOCALAPPDATA%\WindowsTerminalContextIcons\"

$contextMenuIcoName = "terminal.ico"
$cmdIcoFileName = "cmd.ico"
$wslIcoFileName = "linux.ico"
$psIcoFileName = "powershell.ico"
$psCoreIcoFileName = "powershell-core.ico"
$azureCoreIcoFileName = "azure.ico"

$menuRegID = "WindowsTerminal"
$contextMenuLabel = "Open Windows Terminal here"
$contextMenuDir = "Registry::HKEY_CLASSES_ROOT\Directory"
$contextMenuLib = "Registry::HKEY_CLASSES_ROOT\LibraryFolder"
$contextMenuRegPath = "\shell\$menuRegID"
$contextBGMenuRegPath = "\Background\shell\$menuRegID"
$subMenuRegPath = "\ContextMenus\$menuRegID"
$subMenuRegRelativePath = "Directory\ContextMenus\$menuRegID"

# Get Windows terminal profile
$rawContent = (Get-Content $config) -replace '^\s*\/\/.*' | Out-String
$profiles = (ConvertFrom-Json -InputObject $rawContent).profiles.list

# Setup icons
if($uninstall) {
  if((Test-Path -Path $resourcePath)) {
      Remove-Item -Recurse -Path $resourcePath
      Write-Host "Remove $resourcePath"
  } 
}
else {
  if(-Not (Test-Path -Path $resourcePath)) {
      [void](New-Item -ItemType directory -Path $resourcePath)
      Write-Host "Create path $resourcePath"
  }
  [void](Copy-Item -Path "$PSScriptRoot\icons\*.ico" -Destination $resourcePath)
  Write-Host "Copy icons => $resourcePath"
}

# Clear register
foreach ($rootPath in $contextMenuDir,$contextMenuLib) {
    foreach ($filePath in $contextMenuRegPath,$contextBGMenuRegPath,$subMenuRegPath) {
        if((Test-Path -Path $rootPath$filePath)) {
            Remove-Item -Recurse -Force -Path $rootPath$filePath
            Write-Host "Clear $rootPath$filePath"
        }
        if((Test-Path -Path $rootPath$filePath)) {
            Remove-Item -Recurse -Force -Path $rootPath$filePath
            Write-Host "Clear $rootPath$filePath"
        }
        if((Test-Path -Path $rootPath$filePath)) {
            Remove-Item -Recurse -Force -Path $rootPath$filePath
            Write-Host "Clear $rootPath$filePath"
        }
    }
}
if($uninstall) {
    Exit
}

# Setup First layer context menu
foreach ($rootPath in $contextMenuDir,$contextMenuLib) {
    foreach ($filePath in $contextMenuRegPath,$contextBGMenuRegPath) {
        [void](New-Item -Force -Path $rootPath$filePath)
        [void](New-ItemProperty -Path $rootPath$filePath -Name ExtendedSubCommandsKey -PropertyType String -Value $subMenuRegRelativePath)
        [void](New-ItemProperty -Path $rootPath$filePath -Name Icon -PropertyType String -Value $resourcePathReg$contextMenuIcoName)
        [void](New-ItemProperty -Path $rootPath$filePath -Name MUIVerb -PropertyType String -Value $contextMenuLabel)
        Write-Host "Add top layer menu => $rootPath$filePath"
    }
}

# Setup each profile item
foreach ($rootPath in $contextMenuDir,$contextMenuLib) {
    $profiles | ForEach-Object {
        $profileName = $_.name
        $leagaleName = $profileName -replace '[ \r\n\t]', '-'
        $subItemRegPath = "$rootPath$subMenuRegPath\shell\$leagaleName"
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
                $icoPath = "$resourcePathReg$cmdIcoFileName"
            }
            elseif ($commandLine -eq "powershell.exe") {
                $icoPath = "$resourcePathReg$psIcoFileName"
            }
            elseif ($source -eq "Windows.Terminal.Wsl") {
                $icoPath = "$resourcePathReg$wslIcoFileName"
            }
            elseif ($source -eq "Windows.Terminal.PowershellCore") {
                $icoPath = "$resourcePathReg$psCoreIcoFileName"
            }
            elseif ($source -eq "Windows.Terminal.Azure") {
                $icoPath = "$resourcePathReg$azureCoreIcoFileName"
            }

            if($icoPath -ne "") {
                [void](New-ItemProperty -Path $subItemRegPath -Name "Icon" -PropertyType String -Value "$icoPath")
            }
        }
        Write-Host "Add new entry => $subItemRegPath"
    }
}
