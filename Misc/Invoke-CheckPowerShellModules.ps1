﻿function Invoke-CheckPowerShellModules
{
   <#
         .SYNOPSIS
         Check if one or more given modules are installed.

         .DESCRIPTION
         Check if one or more given modules are installed.
         Any missing modules can be installed (optional) and updated to the latest version available on the PowerShell Gallery can be applied (optional).

         .PARAMETER Module
         One or more modules to check, update, install.

         .PARAMETER Install
         Install any missing modules from the PowerShell Gallery?

         .PARAMETER Update
         Updated to the latest PowerShell Gallery Version of the module, if available?

         .PARAMETER Scope
         Specifies the installation scope of the module.
         The acceptable values for this parameter are: AllUsers and CurrentUser.
         The default is CurrentUser.

         The AllUsers scope lets modules be installed in a location that is accessible to all users of the computer,
         that is, %systemdrive%:\ProgramFiles\WindowsPowerShell\Modules. Elevated Shell required!

         The CurrentUser scope lets modules be installed only to $home\Documents\WindowsPowerShell\Modules,
         so that the module is available only to the current user.

         .EXAMPLE
         PS C:\> Invoke-CheckPowerShellModules -Module 'MSOnline', 'azuread', 'AzureADPreview', 'Microsoft.Online.SharePoint.PowerShell', 'MicrosoftTeams', 'Microsoft.PowerApps.PowerShell', 'Microsoft.PowerApps.Administration.PowerShell', 'SharePointPnPPowerShellOnline', 'credentialmanager' -Install

         Check if all the Office 365 related PowerShell Modules are installed.
         This will not install anything missing; it just runs a check!

         .EXAMPLE
         PS C:\> Invoke-CheckPowerShellModules -Module 'MSOnline', 'azuread', 'AzureADPreview', 'Microsoft.Online.SharePoint.PowerShell', 'MicrosoftTeams', 'Microsoft.PowerApps.PowerShell', 'Microsoft.PowerApps.Administration.PowerShell', 'SharePointPnPPowerShellOnline', 'credentialmanager' -Install

         Install all the Office 365 related PowerShell Modules if anything is missing.

         .EXAMPLE
         PS C:\> Invoke-CheckPowerShellModules -Module 'MSOnline', 'azuread', 'AzureADPreview', 'Microsoft.Online.SharePoint.PowerShell', 'MicrosoftTeams', 'Microsoft.PowerApps.PowerShell', 'Microsoft.PowerApps.Administration.PowerShell', 'SharePointPnPPowerShellOnline', 'credentialmanager' -Scope AllUsers

         Install all the Office 365 related PowerShell Modules if anything is missing (system wide).
         This required to runn in an elevated Shell!!!

         .EXAMPLE
         PS C:\> Invoke-CheckPowerShellModules -Module  'MSOnline', 'azuread', 'AzureADPreview', 'Microsoft.Online.SharePoint.PowerShell', 'MicrosoftTeams', 'Microsoft.PowerApps.PowerShell', 'Microsoft.PowerApps.Administration.PowerShell', 'SharePointPnPPowerShellOnline', 'credentialmanager' -Update

         Install all the Office 365 related PowerShell Modules if missing, automatically updates the latest version (if there is any update available)

         .NOTES
         For now, only the PowerShell Gallery is supported as Repository!
         The next version might bring the check for an elevated shell if the scope is set to 'AllUsers'.

         Version: 1.0.1

         GUID: e1aab9c6-e383-469f-9ac9-f5c146334987

         Author: Joerg Hochwald

         Companyname: Alright-IT GmbH

         Copyright: Copyright (c) 2019, Alright-IT GmbH - All rights reserved.

         License: https://opensource.org/licenses/BSD-3-Clause

         Releasenotes:
         1.0.1 2019-05-24: Make it a bit more robust and add some examples (intial public release)
         1.0.0 2019-05-15: Initial Release (internal)

         THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
   #>
   [CmdletBinding(ConfirmImpact = 'Low',
   SupportsShouldProcess)]
   param
   (
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0,
      HelpMessage = 'One or more Modules to check.')]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Module,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 1)]
      [Alias('AutoInstall', 'InstallMissing')]
      [switch]
      $Install = $null,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 2)]
      [Alias('AutoUpdate')]
      [switch]
      $Update = $null,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 3)]
      [ValidateNotNullOrEmpty()]
      [ValidateSet('AllUsers', 'CurrentUser', IgnoreCase = $true)]
      [Alias('InstallScope', 'ModuleScope')]
      [string]
      $Scope = 'CurrentUser'
   )

   begin
   {
      # The default scope is the current user (if not given)
      if (-not $Scope)
      {
         $Scope = 'CurrentUser'
      }

      # Mandatory PowerShell Modules for Office 365 administration.
      if (-not $Module)
      {
         $Module = 'MSOnline', 'azuread', 'AzureADPreview', 'Microsoft.Online.SharePoint.PowerShell', 'MicrosoftTeams', 'Microsoft.PowerApps.PowerShell', 'Microsoft.PowerApps.Administration.PowerShell'
      }
   }

   process
   {
      foreach ($PowerShellModule in $Module)
      {
         # Cleanup
         $InstalledModuleVersion = $null
         $LatestModuleVersion = $null
         $UpdateVersion = $null

         try
         {
            Write-Verbose -Message ('Start processing for {0}' -f $PowerShellModule)

            # Cleanup
            $InstalledModuleVersion = $null

            # In some cases, we might have different versions installed.
            # We just want to have the latest and greatest one.
            $paramGetModule = @{
               Name          = $PowerShellModule
               ListAvailable = $true
               ErrorAction   = 'Stop'
            }
            $InstalledModuleVersion = (Get-Module @paramGetModule | Select-Object -Property Name, Version, repositorysourcelocation | Sort-Object -Property Version -Descending | Select-Object -First 1)

            if (-not $InstalledModuleVersion)
            {
               if ($Install)
               {
                  Write-Verbose -Message ('Start the installation of {0}' -f $PowerShellModule)

                  try
                  {
                     if ($pscmdlet.ShouldProcess($PowerShellModule, 'Install'))
                     {
                        $paramInstallModule = @{
                           Name          = $PowerShellModule
                           Repository    = 'PSGallery'
                           ErrorAction   = 'Stop'
                           WarningAction = 'Continue'
                           Scope         = $Scope
                           Force         = $true
                           AllowClobber  = $true
                        }
                        $null = (Install-Module @paramInstallModule)
                     }
                  }
                  catch
                  {
                     # Get error record
                     [Management.Automation.ErrorRecord]$e = $_

                     # Build the Info object
                     $info = [PSCustomObject]@{
                        Exception = $e.Exception.Message
                        Reason    = $e.CategoryInfo.Reason
                        Target    = $e.CategoryInfo.TargetName
                        Script    = $e.InvocationInfo.ScriptName
                        Line      = $e.InvocationInfo.ScriptLineNumber
                        Column    = $e.InvocationInfo.OffsetInLine
                     }

                     # Do some verbose things
                     $info | Out-String | Write-Verbose

                     $paramWriteError = @{
                        Message      = $e.Exception.Message
                        ErrorAction  = 'Stop'
                        Exception    = $e.Exception
                        TargetObject = $e.CategoryInfo.TargetName
                     }
                     Write-Error @paramWriteError
                  }

                  Write-Verbose -Message ('Finished the installation of {0}' -f $PowerShellModule)
               }
               else
               {
                  # Error message
                  Write-Error -Message ('{0} was not found...' -f $PowerShellModule) -Category NotInstalled -ErrorAction Stop
               }
            }
            else
            {
               if ($InstalledModuleVersion.RepositorySourceLocation.Authority -ne 'www.powershellgallery.com')
               {
                  Write-Error -Message ('Sorry, but only modules from the PowerShell Gallery are supported and {0} is not installed from there.' -f $PowerShellModule) -Category InvalidType -ErrorAction Stop
               }
               else
               {
                  try
                  {
                     Write-Verbose -Message ('Get the latest PowerShell Gallery version for {0}' -f $PowerShellModule)

                     $paramFindModule = @{
                        Name        = $PowerShellModule
                        Repository  = 'PSGallery'
                        ErrorAction = 'Stop'
                     }
                     $LatestModuleVersion = (Find-Module @paramFindModule | Select-Object -Property Name, Version)

                     $UpdateVersion = $LatestModuleVersion.Version

                     Write-Verbose -Message ('Found version {0} of {1} in the PowerShell Gallery' -f $UpdateVersion, $PowerShellModule)

                     if ($InstalledModuleVersion.Version -ilt $UpdateVersion)
                     {
                        Write-Verbose -Message ('Version {0} for {1} is availible in the PowerShell Galery' -f $UpdateVersion, $PowerShellModule)

                        if ($Update)
                        {
                           Write-Verbose -Message ('Start the update for {0} to version {1}' -f $PowerShellModule, $UpdateVersion)

                           try
                           {
                              if ($pscmdlet.ShouldProcess($PowerShellModule, 'Update'))
                              {
                                 $paramInstallModule = @{
                                    Name          = $PowerShellModule
                                    Repository    = 'PSGallery'
                                    ErrorAction   = 'Stop'
                                    WarningAction = 'Continue'
                                    Scope         = $Scope
                                    Force         = $true
                                    AllowClobber  = $true
                                 }
                                 $null = (Install-Module @paramInstallModule)
                              }

                              Write-Verbose -Message ('Installed version {0} for {1}' -f $UpdateVersion, $PowerShellModule)
                           }
                           catch
                           {
                              # Get error record
                              [Management.Automation.ErrorRecord]$e = $_

                              # Create the Info Object
                              $info = [PSCustomObject]@{
                                 Exception = $e.Exception.Message
                                 Reason    = $e.CategoryInfo.Reason
                                 Target    = $e.CategoryInfo.TargetName
                                 Script    = $e.InvocationInfo.ScriptName
                                 Line      = $e.InvocationInfo.ScriptLineNumber
                                 Column    = $e.InvocationInfo.OffsetInLine
                              }

                              # Do some verbose stuff
                              $info | Out-String | Write-Verbose

                              Write-Warning -Message $e.Exception.Message
                           }
                        }
                        else
                        {
                           Write-Warning -Message ('Version {0} for {1} is availible on the PowerShell Galery' -f $UpdateVersion, $PowerShellModule)
                        }
                     }
                     else
                     {
                        Write-Verbose -Message ('No update found for {0}' -f $PowerShellModule)
                     }
                  }
                  catch
                  {
                     # Get error record
                     [Management.Automation.ErrorRecord]$e = $_

                     # Create the Info Object
                     $info = [PSCustomObject]@{
                        Exception = $e.Exception.Message
                        Reason    = $e.CategoryInfo.Reason
                        Target    = $e.CategoryInfo.TargetName
                        Script    = $e.InvocationInfo.ScriptName
                        Line      = $e.InvocationInfo.ScriptLineNumber
                        Column    = $e.InvocationInfo.OffsetInLine
                     }

                     # Do some verbose stuff
                     $info | Out-String | Write-Verbose

                     Write-Warning -Message $e.Exception.Message
                  }
               }
            }
         }
         catch
         {
            # Get error record
            [Management.Automation.ErrorRecord]$e = $_

            # Create the Info Object
            $info = [PSCustomObject]@{
               Exception = $e.Exception.Message
               Reason    = $e.CategoryInfo.Reason
               Target    = $e.CategoryInfo.TargetName
               Script    = $e.InvocationInfo.ScriptName
               Line      = $e.InvocationInfo.ScriptLineNumber
               Column    = $e.InvocationInfo.OffsetInLine
            }

            # Do some verbose stuff
            $info | Out-String | Write-Verbose

            $paramWriteError = @{
               Message      = $e.Exception.Message
               ErrorAction  = 'Stop'
               Exception    = $e.Exception
               TargetObject = $e.CategoryInfo.TargetName
            }
            Write-Error @paramWriteError
         }
      }
   }

   end
   {
      Write-Verbose -Message 'Done'
   }
}
