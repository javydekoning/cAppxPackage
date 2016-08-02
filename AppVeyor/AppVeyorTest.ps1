#---------------------------------# 
# Header                          # 
#---------------------------------# 
Write-Host 'Running Pester Tests' -ForegroundColor Yellow
Write-Host "Current working directory: $pwd"

$ModulePath = Split-Path $pwd
Write-Host "Adding $ModulePath to 'psmodulepath' PATH variable"
$env:psmodulepath = $env:psmodulepath + ';' + $ModulePath
Import-Module -Name 'cAppxPackage' -Force

#---------------------------------# 
# Run Pester Tests                # 
#---------------------------------# 
$testResultsFile = '.\TestsResults.xml'
$res             = Invoke-Pester -Script .\Tests\cAppxPackage.Tests.ps1 -OutputFormat NUnitXml -OutputFile $testResultsFile -PassThru

Write-Host 'Uploading results'
(New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path $testResultsFile))

#---------------------------------# 
# Validate                        # 
#---------------------------------# 
if (($res.FailedCount -gt 0) -or ($res.PassedCount -eq 0)) { 
    throw "$($res.FailedCount) tests failed."
} else {
  Write-Host 'All tests passed' -ForegroundColor Green
}