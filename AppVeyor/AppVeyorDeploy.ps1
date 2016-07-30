#---------------------------------# 
# Header                          # 
#---------------------------------# 
Write-Host 'Running AppVeyor deploy script' -ForegroundColor Yellow

#---------------------------------# 
# Update module manifest          # 
#---------------------------------# 
Write-Host 'Creating new module manifest'
$ModuleManifestPath = Join-Path -path "$pwd" -ChildPath ("$env:ModuleName"+'.psd1')
$ModuleManifest     = Get-Content $ModuleManifestPath -Raw
[regex]::replace($ModuleManifest,'(ModuleVersion = )(.*)',"`$1'$env:APPVEYOR_BUILD_VERSION'") | Out-File -LiteralPath $ModuleManifestPath
Get-Content $ModuleManifestPath -Raw

#---------------------------------# 
# Publish to PS Gallery           # 
#---------------------------------# 
Write-Host 'Publishing module to Powershell Gallery'
#Publish-Module -Name $ModuleName -NuGetApiKey $PublishingNugetKey