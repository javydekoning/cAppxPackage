| Branch        | Status        |
| ------------- | ------------- |
| master        | [![Build status](https://ci.appveyor.com/api/projects/status/id2vjxhw6gnbb66p/branch/master?svg=true&passingText=master%20-%20OK&pendingText=master%20-%20PENDING&failingText=master%20-%20FAILED)](https://ci.appveyor.com/project/javydekoning/cappxpackage/branch/master) |
| dev           | [![Build status](https://ci.appveyor.com/api/projects/status/id2vjxhw6gnbb66p/branch/dev?svg=true&passingText=dev%20-%20OK&pendingText=dev%20-%20PENDING&failingText=dev%20-%20FAILED)](https://ci.appveyor.com/project/javydekoning/cappxpackage/branch/dev) |

# cAppxPackage
Class-based DSC resource for Windows 10 AppxPackage(s). Usage example:

```powershell
$cred = get-credential

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName='Localhost'
            PSDscAllowPlainTextPassword=$true
         }
    )
}

configuration AppxExample
{
  param (
      [Parameter(Mandatory=$false)]
      [PSCredential] [System.Management.Automation.Credential()] 
      $Credential
  )
  Import-DscResource -ModuleName 'cAppxPackage'  
  
  Node $AllNodes.NodeName {
    cAppxPackage 'Profile'
    {
      Name = 'Microsoft.WindowsAlarms'
      Ensure = 'Present'
      PsDscRunAsCredential = $Credential
    }
  }
}
$config = AppxExample -ConfigurationData $ConfigurationData -credential $cred


Start-DscConfiguration -Verbose -Path $config.PSParentPath -Wait -Force
```
