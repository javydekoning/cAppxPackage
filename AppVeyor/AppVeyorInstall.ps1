#Header
Write-Host 'Running AppVeyor install script' -ForegroundColor Yellow

#Install Nuget
Write-Host 'Installing NuGet PackageProvide'
$pkg = Install-PackageProvider -Name NuGet -Force
Write-Host "Installed NuGet version '$($pkg.version)'" 

#Install Pester
Write-Host 'Installing Pester'
Install-Module -Name Pester -Repository PSGallery -Force