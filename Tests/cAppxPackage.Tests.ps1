$Modules = Get-ChildItem "$PSScriptRoot\..\" -Filter '*.psm1'
$Rules   = Get-ScriptAnalyzerRule

if ($Modules.count -gt 0) {
  Describe 'Testing all Modules against default PSScriptAnalyzer rule-set' {
    foreach ($module in $modules) {
      Context "Testing Module '$($module.FullName)'" {
        foreach ($rule in $rules) {
          It "passes the PSScriptAnalyzer Rule $rule" {
            (Invoke-ScriptAnalyzer -Path $module.FullName -IncludeRule $rule.RuleName ).Count | Should Be 0
          }
        }
      }
    }
  }
}

$PSVersion    = $PSVersionTable.PSVersion.Major
$cAppxPackage = $Modules | Where-Object {$_.Name -eq 'cAppxPackage.psm1'}

Describe "Testing $($cAppxPackage.FullName) PS$PSVersion" {
  Copy-Item $cAppxPackage TestDrive:\script.ps1 -Force
  Mock Export-ModuleMember {return $true}
  . 'TestDrive:\script.ps1'
    
  Context 'Strict mode' { 

    Set-StrictMode -Version latest

    $app = New-Object cAppxPackage
    $app.name = 'NotAPackageName'
    $app.ensure = 'Present'
      
    It 'get() method should return class of type cAppxPackage' {
      $app.get().GetType().Name | should Be cAppxPackage
    }

    It 'test() method should return Boolean' {
      $app.test().GetType().Name | should Be Boolean
    }
    
    It 'TestAppxPresent() method should return Boolean' {
      $app.TestAppxPresent($app.name).GetType().Name | should Be Boolean
    }

    It 'TestSystemPriv() method should return Boolean' {
      $app.TestSystemPriv().GetType().Name | should Be Boolean
    }
  }
}