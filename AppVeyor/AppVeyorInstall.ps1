Write-Host 'Running AppVeyor install script'
Write-Host 'Configuring NuGet and Installing Pester:'
Install-PackageProvider -Name NuGet -Force
Install-Module -Name Pester -Repository PSGallery -Force

ls env: | out-string