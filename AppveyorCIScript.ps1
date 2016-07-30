#Preferences
$ErrorActionPreference = 'Stop'

##Variables
$ModuleName            = $env:ModuleName
$ModuleLocation        = $env:APPVEYOR_BUILD_FOLDER
$PublishingNugetKey    = $env:nugetKey
$Psd1Path              = "./$ModuleName.psd1"
$BuildNumber           = $env:APPVEYOR_BUILD_NUMBER

Write-Host -Message "Running AppveyorCIScript on $ModuleName from location $ModuleLocation. This is build $BuildNumber"

#Add current directory to ps modules path so module is available 
$env:psmodulepath      = $env:psmodulepath + ';' + 'C:\projects'

#Show module path: 
Write-Host "PS Module Path contains: $($env:psmodulepath -split ';')"
$env:psmodulepath -split ';' | %{
  Write-Host -Message $_
}

$DSC = Get-DscResource
Write-Host 'Listing DSC Resources:'
$DSC | Sort-Object name | % {Write-Host $_.Name}

Write-Host "Testing each resource in module: $ModuleName" 

##Check module exists
if (-not ($DSC | Where-Object {$_.Module.Name -eq $ModuleName}))
{
    Write-Error "Could not find: $ModuleName"
    Exit 1
}

$ExportedDSCResources = @()
##Test the modules resources
foreach ($Resource in ($DSC | Where-Object {$_.Module.Name -eq $ModuleName})) 
{
    Write-Host "Running Tests against $($Resource.Name) resource" -ForegroundColor Yellow
    try 
    {
        $Result = 1 # add pester here. 
        switch ($Result) 
        {
            $True 
            {
                Write-Host "All tests passed for $($Resource.Name)." -ForegroundColor Green
                #Add resource to array of strings, later used to update the manifest
                $ExportedDSCResources += $Resource.Name
            }
            $False 
            {
                Write-Error "One or more tests failed for $($Resource.Name)." -ForegroundColor Red
                exit 1
            }
        }
    }
    catch 
    {
        Write-Warning "The test for $($Resource.Name) failed due to an error"
        Write-Error $_.Exception.Message
        exit 1
    }
}

$OldVersion = Select-String -InputObject $Psd1Path -Pattern "ModuleVersion\s=\s'(.*)'" -AllMatches | %{$_.Matches.Groups[1].value}
Write-Host "Incrementing Module version, current version: $OldVersion"

$NewPsd1 = (Get-Content $Psd1Path -raw) -Replace "$ver","$env:APPVEYOR_BUILD_VERSION"
Write-Host "$NewPSD1"

##Publish the resource
Write-Host 'Publishing module to Powershell Gallery: ' -NoNewline

#Publish-Module -Name $ModuleName -NuGetApiKey $PublishingNugetKey