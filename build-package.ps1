Set-StrictMode -Version Latest
$script:PACKAGE_FOLDER = "$env:APPVEYOR_BUILD_FOLDER"
Set-Location $script:PACKAGE_FOLDER

if ($env:ATOM_ACCESS_TOKEN -and ($env:ATOM_ACCESS_TOKEN.trim() -ne "")) {
  # Yay!
} else {
  $env:ATOM_ACCESS_TOKEN = "da809a6077bb1b0aa7c5623f7b2d5f1fec2faae4"
  [Environment]::SetEnvironmentVariable("ATOM_ACCESS_TOKEN", "da809a6077bb1b0aa7c5623f7b2d5f1fec2faae4", "User")
}

$script:ATOM_CHANNEL = "stable"
$script:ATOM_DIRECTORY_NAME = "Atom"
if ($env:ATOM_CHANNEL -and ($env:ATOM_CHANNEL.tolower() -ne "stable")) {
    $script:ATOM_CHANNEL = "$env:ATOM_CHANNEL"
    $script:ATOM_DIRECTORY_NAME = "$script:ATOM_DIRECTORY_NAME "
    $script:ATOM_DIRECTORY_NAME += $script:ATOM_CHANNEL.substring(0,1).toupper()
    $script:ATOM_DIRECTORY_NAME += $script:ATOM_CHANNEL.substring(1).tolower()
}

$script:ATOM_EXE_PATH = "$script:PACKAGE_FOLDER\$script:ATOM_DIRECTORY_NAME\atom.exe"
$script:ATOM_SCRIPT_PATH = "$script:PACKAGE_FOLDER\$script:ATOM_DIRECTORY_NAME\resources\cli\atom.cmd"
$script:APM_SCRIPT_PATH = "$script:PACKAGE_FOLDER\$script:ATOM_DIRECTORY_NAME\resources\app\apm\bin\apm.cmd"


function DownloadAtom() {
    Write-Host "Downloading latest Atom release..."
    $source = "https://atom.io/download/windows_zip?channel=$script:ATOM_CHANNEL"
    $destination = "$script:PACKAGE_FOLDER\atom.zip"
    appveyor DownloadFile $source -FileName $destination
    if ($LASTEXITCODE -ne 0) {
        ExitWithCode -exitcode $LASTEXITCODE
    }
}

function ExtractAtom() {
    Remove-Item "$script:PACKAGE_FOLDER\$script:ATOM_DIRECTORY_NAME" -Recurse -ErrorAction Ignore
    Unzip "$script:PACKAGE_FOLDER\atom.zip" "$script:PACKAGE_FOLDER"
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

function PrintVersions() {
    Write-Host -NoNewLine "Using Atom version: "
    & "$script:ATOM_EXE_PATH" --version
    if ($LASTEXITCODE -ne 0) {
        ExitWithCode -exitcode $LASTEXITCODE
    }
    Write-Host "Using APM version: "
    & "$script:APM_SCRIPT_PATH" -v
    if ($LASTEXITCODE -ne 0) {
        ExitWithCode -exitcode $LASTEXITCODE
    }
}

function InstallPackage() {
    Write-Host "Downloading package dependencies..."
    & "$script:APM_SCRIPT_PATH" clean
    if ($LASTEXITCODE -ne 0) {
        ExitWithCode -exitcode $LASTEXITCODE
    }
    & "$script:APM_SCRIPT_PATH" install
    if ($LASTEXITCODE -ne 0) {
        ExitWithCode -exitcode $LASTEXITCODE
    }
    InstallDependencies
}

function InstallDependencies() {
    if ($env:APM_TEST_PACKAGES) {
        Write-Host "Installing atom package dependencies..."
        $APM_TEST_PACKAGES = $env:APM_TEST_PACKAGES -split "\s+"
        $APM_TEST_PACKAGES | foreach {
            Write-Host "$_"
            & "$script:APM_SCRIPT_PATH" install $_
            if ($LASTEXITCODE -ne 0) {
                ExitWithCode -exitcode $LASTEXITCODE
            }
        }
    }
}

function RunLinters() {
    $libpath = "$script:PACKAGE_FOLDER\lib"
    $libpathexists = Test-Path $libpath
    $srcpath = "$script:PACKAGE_FOLDER\src"
    $srcpathexists = Test-Path $srcpath
    $specpath = "$script:PACKAGE_FOLDER\spec"
    $specpathexists = Test-Path $specpath
    $coffeelintpath = "$script:PACKAGE_FOLDER\node_modules\.bin\coffeelint.cmd"
    $coffeelintpathexists = Test-Path $coffeelintpath
    $eslintpath = "$script:PACKAGE_FOLDER\node_modules\.bin\eslint.cmd"
    $eslintpathexists = Test-Path $eslintpath
    $standardpath = "$script:PACKAGE_FOLDER\node_modules\.bin\standard.cmd"
    $standardpathexists = Test-Path $standardpath
    if (($libpathexists -or $srcpathexists) -and ($coffeelintpathexists -or $eslintpathexists -or $standardpathexists)) {
        Write-Host "Linting package..."
    }

    if ($libpathexists) {
        if ($coffeelintpathexists) {
            & "$coffeelintpath" lib
            if ($LASTEXITCODE -ne 0) {
                ExitWithCode -exitcode $LASTEXITCODE
            }
        }

        if ($eslintpathexists) {
            & "$eslintpath" lib
            if ($LASTEXITCODE -ne 0) {
                ExitWithCode -exitcode $LASTEXITCODE
            }
        }

        if ($standardpathexists) {
            & "$standardpath" lib/**/*.js
            if ($LASTEXITCODE -ne 0) {
                ExitWithCode -exitcode $LASTEXITCODE
            }
        }
    }

    if ($srcpathexists) {
        if ($coffeelintpathexists) {
            & "$coffeelintpath" src
            if ($LASTEXITCODE -ne 0) {
                ExitWithCode -exitcode $LASTEXITCODE
            }
        }

        if ($eslintpathexists) {
            & "$eslintpath" src
            if ($LASTEXITCODE -ne 0) {
                ExitWithCode -exitcode $LASTEXITCODE
            }
        }

        if ($standardpathexists) {
            & "$standardpath" src/**/*.js
            if ($LASTEXITCODE -ne 0) {
                ExitWithCode -exitcode $LASTEXITCODE
            }
        }
    }

    if ($specpathexists -and ($coffeelintpathexists -or $eslintpathexists -or $standardpathexists)) {
        Write-Host "Linting package specs..."
        if ($coffeelintpathexists) {
            & "$coffeelintpath" spec
            if ($LASTEXITCODE -ne 0) {
                ExitWithCode -exitcode $LASTEXITCODE
            }
        }

        if ($eslintpathexists) {
            & "$eslintpath" spec
            if ($LASTEXITCODE -ne 0) {
                ExitWithCode -exitcode $LASTEXITCODE
            }
        }

        if ($standardpathexists) {
            & "$standardpath" spec/**/*.js
            if ($LASTEXITCODE -ne 0) {
                ExitWithCode -exitcode $LASTEXITCODE
            }
        }
    }
}

function RunSpecs() {
    $specpath = "$script:PACKAGE_FOLDER\spec"
    $specpathexists = Test-Path $specpath
    if (!$specpathexists) {
        Write-Host "Missing spec folder! Please consider adding a test suite in '.\spec'"
        ExitWithCode -exitcode 1
    }
    Write-Host "Running specs..."
    & "$script:ATOM_EXE_PATH" --test spec 2>&1 | %{ "$_" }
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Specs Failed"
        ExitWithCode -exitcode $LASTEXITCODE
    }
}

function ExitWithCode
{
    param
    (
        $exitcode
    )

    $host.SetShouldExit($exitcode)
    exit
}

function SetElectronEnvironmentVariables
{
  # TODO: Remove OS=cygwin once master is >= Electron 0.36.7
  $env:OS = "cygwin"
  [Environment]::SetEnvironmentVariable("OS", "cygwin", "User")
  $env:ELECTRON_NO_ATTACH_CONSOLE = "true"
  [Environment]::SetEnvironmentVariable("ELECTRON_NO_ATTACH_CONSOLE", "true", "User")
  $env:ELECTRON_ENABLE_LOGGING = "YES"
  [Environment]::SetEnvironmentVariable("ELECTRON_ENABLE_LOGGING", "YES", "User")

}

DownloadAtom
ExtractAtom
SetElectronEnvironmentVariables
PrintVersions
InstallPackage
RunLinters
RunSpecs
