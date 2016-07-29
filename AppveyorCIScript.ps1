$ErrorActionPreference = "Stop"
]
##Variables
$ModuleName = $env:ModuleName
$ModuleLocation = $env:APPVEYOR_BUILD_FOLDER
$PublishingNugetKey = $env:nugetKey
$Psd1Path = "./$ModuleName.psd1"
$BuildNumber = $env:APPVEYOR_BUILD_NUMBER

##Setup
#Add current directory to ps modules path so module is available 
$env:psmodulepath = $env:psmodulepath + ";" + "C:\projects"
#Install dsc resource designer to make tests available
Install-Module -Name xDSCResourceDesigner -force

Write-Host `n
Write-Host "PS Module Path: $($env:psmodulepath)"
Write-Host `n

##Test the resource
$DSC = Get-DscResource

Write-Host `n
Write-Host "Available Modules"
Write-Host `n
$DSC | Format-Table

write-host `n
write-host " Testing each resource in module: " -NoNewline
write-host "$ModuleName" -ForegroundColor blue -BackgroundColor darkyellow
write-host `n

##Check module exists
if (-not ($DSC | ? {$_.Module.Name -eq $ModuleName}))
{
    Write-Error "Module not found: $ModuleName"
}

$ExportedDSCResources = @()
##Test the modules resources
foreach ($Resource in ($DSC | ? {$_.Module.Name -eq $ModuleName})) 
{
    write-host "Running Tests against $($Resource.Name) resource" -ForegroundColor Yellow
    try 
    {
        $Result = Test-xDscResource -Name $Resource.Name
        switch ($Result) 
        {
            $True 
            {
                write-host "All tests passed for $($Resource.Name)." -ForegroundColor Green
                #Add resource to array of strings, later used to update the manifest
                $ExportedDSCResources += $Resource.Name
            }
            $False 
            {
                Write-Error "One or more tests failed for $($Resource.Name)." -ForegroundColor Red
                exit 1
            }
        }
        write-host `n

    }
    catch 
    {
        Write-Warning "The test for $($Resource.Name) failed due to an error"
        Write-Error $_.Exception.Message
        exit 1
    }
}

write-host "Incrementing Module version, current version: " -NoNewline

##Publish the resource
write-host `n
write-host "Publishing module to Powershell Gallery: " -NoNewline
write-host "$ModuleName" -ForegroundColor blue -BackgroundColor darkyellow
write-host `n

#Publish-Module -Name $ModuleName -NuGetApiKey $PublishingNugetKey