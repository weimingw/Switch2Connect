param(
    [Parameter(Mandatory = $true)][string]$SourcePath
)
$ErrorActionPreference = 'Stop'
$expectedCommit = 'd6cebbef5c7909168d1f881185be8f607d6aefd4'
$source = (Resolve-Path -LiteralPath $SourcePath).Path
$commit = (& git -C $source rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or $commit -ne $expectedCommit) { throw "Expected WinUHid revision $expectedCommit, found $commit" }
if (@(& git -C $source status --porcelain --untracked-files=no).Count -ne 0) { throw 'WinUHid source has tracked changes; build from a clean checkout.' }
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
$vs = & $vswhere -latest -products '*' -property installationPath
$msbuild = Join-Path $vs 'MSBuild\Current\Bin\arm64\MSBuild.exe'
$wdk = (Join-Path ${env:ProgramFiles(x86)} 'Windows Kits\10') + '/'
if (-not (Test-Path $msbuild) -or -not (Test-Path (Join-Path $wdk 'build\10.0.26100.0\WindowsDriver.Common.targets'))) { throw 'Visual Studio ARM64 MSBuild or WDK 26100 not found.' }
$project = Join-Path $source 'WinUHid Driver\WinUHid Driver.vcxproj'
$solutionDir = $source.TrimEnd('\') + '/'
& $msbuild $project /p:Configuration=Release /p:Platform=ARM64 /p:WindowsTargetPlatformVersion=10.0.26100.0 /p:SignMode=Off "/p:WDKContentRoot=$wdk" "/p:SolutionDir=$solutionDir" /v:minimal
if ($LASTEXITCODE -ne 0) { throw "Driver build failed: $LASTEXITCODE" }
Write-Host "Unsigned driver package: $(Join-Path $source 'build\Release\ARM64\WinUHid Driver')"
Write-Host 'Sign and validate the catalog before copying the package and its certificate to drivers\arm64.'
