$Verbose = @{}
$Verbose.add('Verbose',$True)

$PSVersion    = $PSVersionTable.PSVersion.Major
$cAppxPackage = "$PSScriptRoot\..\cAppxPackage.psm1"

Describe "cAppxPackage PS$PSVersion" {
    Copy-Item $cAppxPackage TestDrive:\script.ps1 -Force
    Mock Export-ModuleMember {return $true}
    . 'TestDrive:\script.ps1'
    
    Context 'Strict mode' { 

        Set-StrictMode -Version latest

        It 'PSScriptAnalyzer should return zero suggestions' {
          Invoke-ScriptAnalyzer -Path . | should Be Null
        }

        It 'get() method should return class of type cAppxPackage' {
          $app = New-Object cAppxPackage
          $app.name = 'NotAPackageName'
          $app.ensure = 'Present'
          $app.get().GetType().Name | should Be cAppxPackage
        }

        It 'test() method should return Boolean' {
          $app = New-Object cAppxPackage
          $app.name = 'NotAPackageName'
          $app.ensure = 'Present'
          $app.test().GetType().Name | should Be Boolean
        }
    }
}
