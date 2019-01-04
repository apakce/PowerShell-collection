﻿#requires -Version 3.0 -Modules UpdateServices

<#
    .SYNOPSIS
    Accept License Agreements
	
    .DESCRIPTION
    Accept License Agreements for all Windows Server Update Services (WSUS) Updates
	
    .PARAMETER Name
    Specifies the name of a WSUS server.

    .EXAMPLE
    PS C:\> Approve-WSUSLicenseAgreementAcceptance -Name 'mycdc01'

    Accept License Agreements on the WSUS Server 'mycdc01'

    .EXAMPLE
    PS C:\> Approve-WSUSLicenseAgreementAcceptance

    Accept License Agreements 

    .NOTES
    Initial beta Version
#>
[CmdletBinding(ConfirmImpact = 'None',
SupportsShouldProcess)]
param
(
  [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName,
  Position = 1)]
  [Alias('WSUSServer')]
  [string]
  $Name = $null
)

begin
{
  try
  {
    # Set the Defaults
    $paramGetWsusServer = @{
      ErrorAction   = 'Stop'
      WarningAction = 'Continue'
    }
		
    if ($Name)
    {
      Write-Verbose -Message ('Use {0} as WSUS Server' -f $Name)
			
      # Add the Name field with the given value to the Hashtable (Command Splat)
      $paramGetWsusServer['Name'] = $Name
    }
		
    $WSUS = (Get-WsusServer @paramGetWsusServer)
  }
  catch
  {
    # Get error record
    [Management.Automation.ErrorRecord]$e = $_
		
    # Retrieve information about the error
    $info = [PSCustomObject]@{
      Exception = $e.Exception.Message
      Reason    = $e.CategoryInfo.Reason
      Target    = $e.CategoryInfo.TargetName
      Script    = $e.InvocationInfo.ScriptName
      Line      = $e.InvocationInfo.ScriptLineNumber
      Column    = $e.InvocationInfo.OffsetInLine
    }
		
    # Do some verbose stuff for troubleshooting
    Write-Verbose -Message $info
		
    # Thow the error and go...
    Write-Error -Message "$info.Exception" -ErrorAction Stop
		
    # This is a point the code should never reach (You told PowerShell to Ignore the ErrorAction above!)
    break
		
    # OK, now we have reached a point the we would never, never ever, see
    exit 1
  }
	
  $unapprovedUpdates = $null
  $unapprovedUpdates = $WSUS.getupdates() | Where-Object -FilterScript {
    $_.isdeclined -ne $true
  }
	
  $license = $null
  if ($unapprovedUpdates)
  {
    $license = $unapprovedUpdates | Where-Object -FilterScript {
      $_.RequiresLicenseAgreementAcceptance
    }
  }
  else
  {
    Write-Verbose -Message 'Nothing left todo.'
  }
}

process
{
  if ($license)
  {
    if ($pscmdlet.ShouldProcess("$license", 'Accept License Agreement'))
    {
      $license | ForEach-Object -Process {
        $_.AcceptLicenseAgreement()
      }
    }
  }
  else
  {
    Write-Verbose -Message 'Nothing left todo...'
  }
}

end
{
  Write-Verbose -Message 'Done'
}

#region CHANGELOG
<#
  Soon
#>
#endregion CHANGELOG

#region LICENSE
<#
  LICENSE:

  Copyright 2018 by enabling Technology - http://enatec.io

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

  By using the Software, you agree to the License, Terms and Conditions above!
#>
#endregion LICENSE

#region DISCLAIMER
<#
  DISCLAIMER:

  - Use at your own risk, etc.
  - This is open-source software, if you find an issue try to fix it yourself. There is no support and/or warranty in any kind
  - This is a third-party Software
  - The developer of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way
  - The Software is not supported by Microsoft Corp (MSFT)
  - By using the Software, you agree to the License, Terms, and any Conditions declared and described above
  - If you disagree with any of the Terms, and any Conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER

# SIG # Begin signature block
# MIIjzQYJKoZIhvcNAQcCoIIjvjCCI7oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUDTAmy1CwKnC4Vu1MiDuj7fA7
# 04eggh8rMIIFLzCCBBegAwIBAgIVAJ0OATHCEQYLKXlMtSRrPmYvJ3aiMA0GCSqG
# SIb3DQEBCwUAMD8xCzAJBgNVBAYTAkdCMREwDwYDVQQKEwhBc2NlcnRpYTEdMBsG
# A1UEAxMUQXNjZXJ0aWEgUHVibGljIENBIDEwHhcNMTkwMTA0MTUzMjA3WhcNMTkw
# MjA0MTUzMjA3WjCBpzELMAkGA1UEBhMCREUxITAfBgkqhkiG9w0BCQEWEmpvZXJn
# QGhvY2h3YWxkLm5ldDEPMA0GA1UECBMGSGVzc2VuMRAwDgYDVQQHEwdNYWludGFs
# MRcwFQYDVQQKEw5Kb2VyZyBIb2Nod2FsZDEgMB4GA1UECxMXT3BlbiBTb3VyY2Ug
# RGV2ZWxvcG1lbnQxFzAVBgNVBAMTDkpvZXJnIEhvY2h3YWxkMIIBIjANBgkqhkiG
# 9w0BAQEFAAOCAQ8AMIIBCgKCAQEAy+erEpBAhw0epCs5yobwm9/nDvCufmCXVxu5
# Gc5CnJ7DoqPNN/mtz5Dv8xTR/QrqvjnP9cEZHqHj2mi75PVa10ODQY8cevWTv0WP
# hB0jmes93ghW/JoMyzX9WeKsIFlfdRhdSD2uFZ4pQ0sLFvfGsUPpZDl6i7tfKoU9
# Ujz/MWaf+ZhtnLQ9xwO6eposgl5BQQSJYOh3Zz5/wHMavU+7/RqWFePo857dgK3v
# mCVfSekpd6inIY5TSHpLRDTiVep5JnmSfTyY+rDowBbQD5RSYKBtRcNfvhqKDcgt
# +57qljipQir6fG69BdosVo7NktTrp/8PtOiZ1+P9GWYU3e3UnwIDAQABo4IBtzCC
# AbMwDgYDVR0PAQH/BAQDAgbAMAwGA1UdEwEB/wQCMAAwPQYIKwYBBQUHAQEEMTAv
# MC0GCCsGAQUFBzABhiFodHRwOi8vb2NzcC5nbG9iYWx0cnVzdGZpbmRlci5jb20w
# gfAGA1UdIASB6DCB5TCB4gYKKwYBBAH8SQEBATCB0zCB0AYIKwYBBQUHAgIwgcMM
# gcBXYXJuaW5nOiBDZXJ0aWZpY2F0ZXMgYXJlIGlzc3VlZCB1bmRlciB0aGlzIHBv
# bGljeSB0byBpbmRpdmlkdWFscyB0aGF0IGhhdmUgbm90IGhhZCB0aGVpciBpZGVu
# dGl0eSBjb25maXJtZWQuIERvIG5vdCB1c2UgdGhlc2UgY2VydGlmaWNhdGVzIGZv
# ciB2YWx1YWJsZSB0cmFuc2FjdGlvbnMuIE5PIExJQUJJTElUWSBJUyBBQ0NFUFRF
# RC4wTAYDVR0fBEUwQzBBoD+gPYY7aHR0cDovL3d3dy5nbG9iYWx0cnVzdGZpbmRl
# ci5jb20vY3Jscy9Bc2NlcnRpYVB1YmxpY0NBMS5jcmwwEwYDVR0lBAwwCgYIKwYB
# BQUHAwMwDQYJKoZIhvcNAQELBQADggEBAIxGRztqVffdY91xmUr4P41HdSRX9lAJ
# wnlu7MSLyJOwFT7OspypFCHSecguJKoDV5LN6vOKcGgpo8T1W5oOsGVfxLVSG21+
# M6DVu1FQVJdyMngqisWj05wk6FZ2W6HdEvfasFeTmCjxRpj7rp6kkOhuLpUxbx6G
# Oax3eYyO+VZnpjdZVuhZYnSY6IR+m4jPjjN6dS8HGLb4rT1kj+HL7Bb7RSoad67y
# lIojwchPqpsfbTbktcqYMUX7Z3QsJmqp14823mUaDaQ9Ru0a3IeFnqVehYSte96g
# X8APvLfCqwdFuIe9ehI5O0ZMkJO4WsDthgSw6mtqm1y5Ihz7Gu1u8dQwggWPMIIE
# d6ADAgECAgIA5TANBgkqhkiG9w0BAQUFADA9MQswCQYDVQQGEwJHQjERMA8GA1UE
# ChMIQXNjZXJ0aWExGzAZBgNVBAMTEkFzY2VydGlhIFJvb3QgQ0EgMjAeFw0wOTA0
# MTcxMzIyMzVaFw0yOTAzMTUxMjU5NTlaMD0xCzAJBgNVBAYTAkdCMREwDwYDVQQK
# EwhBc2NlcnRpYTEbMBkGA1UEAxMSQXNjZXJ0aWEgUm9vdCBDQSAyMIIBIjANBgkq
# hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlje+nuDZPqaGExf2SvOpB/MWaNV/RBZH
# 8yGfffzk/6T0C77N9MIGA+LsoUQUxZChn9HR9x4ys9TfUhSbndHqm8bR92D6/K1I
# x5MY619+C8QhVgTaI+E9xcNyxp06RnjusRGhAwHb3SJ5twSb6RuFVhEt2e0ibXmi
# G5DZqg59A4UaTBV4jSoGSjViHCTNWRlvfjmTu78VGazjwX3HqZVoO9E6K3PEwWC+
# z79f4OpLmQjuw8dZxemoIvRgiB0ZDK3I4LiKpIPKki/ilscFriovGBwRuIu7yILx
# zii9pZ5naHut1kQBvcFB2+vHbsAXNbSAD6mpvdDEKzMoUxs4cCO2gwIDAQABo4IC
# lzCCApMwDgYDVR0PAQH/BAQDAgEGMA8GA1UdEwEB/wQFMAMBAf8wggEzBgNVHQ4E
# ggEqBIIBJjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJY3vp7g2T6m
# hhMX9krzqQfzFmjVf0QWR/Mhn3385P+k9Au+zfTCBgPi7KFEFMWQoZ/R0fceMrPU
# 31IUm53R6pvG0fdg+vytSMeTGOtffgvEIVYE2iPhPcXDcsadOkZ47rERoQMB290i
# ebcEm+kbhVYRLdntIm15ohuQ2aoOfQOFGkwVeI0qBko1YhwkzVkZb345k7u/FRms
# 48F9x6mVaDvROitzxMFgvs+/X+DqS5kI7sPHWcXpqCL0YIgdGQytyOC4iqSDypIv
# 4pbHBa4qLxgcEbiLu8iC8c4ovaWeZ2h7rdZEAb3BQdvrx27AFzW0gA+pqb3QxCsz
# KFMbOHAjtoMCAwEAATCCATcGA1UdIwSCAS4wggEqgIIBJjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBAJY3vp7g2T6mhhMX9krzqQfzFmjVf0QWR/Mhn338
# 5P+k9Au+zfTCBgPi7KFEFMWQoZ/R0fceMrPU31IUm53R6pvG0fdg+vytSMeTGOtf
# fgvEIVYE2iPhPcXDcsadOkZ47rERoQMB290iebcEm+kbhVYRLdntIm15ohuQ2aoO
# fQOFGkwVeI0qBko1YhwkzVkZb345k7u/FRms48F9x6mVaDvROitzxMFgvs+/X+Dq
# S5kI7sPHWcXpqCL0YIgdGQytyOC4iqSDypIv4pbHBa4qLxgcEbiLu8iC8c4ovaWe
# Z2h7rdZEAb3BQdvrx27AFzW0gA+pqb3QxCszKFMbOHAjtoMCAwEAATANBgkqhkiG
# 9w0BAQUFAAOCAQEAAVsprh7rRtV3De9pJytO4jlHvWlPXEtAtOsUZf60zEPPn2xx
# PkCn5bv/M+nM/I5lNl54gOT0FNbZK7dowkEvy83zn2fo1N5IK/OkNmmuDFITQMls
# 7Pt0ODRcLDlb/u0YTPRMhOG1bnisazG7oDMTZOEtUfFaCRCN4ZvjrqmWOJrESoWu
# xALt41CLGLIq1q8m4lKrcKo1mNq10gjVnNlpzzLNYDm6WtJUoTNU1wAOBCxqBd5l
# S6qyf56d6cqZD/S9rWTtiXXza+F+F+Ukbq+dvbiaspHXOauRw0oizYmHC68rDtEv
# x99cm/EGUkjgWLBZVUo/f0ilKq4bFAuaBHP4KzCCBmowggVSoAMCAQICEAMBmgI6
# /1ixa9bV6uYX8GYwDQYJKoZIhvcNAQEFBQAwYjELMAkGA1UEBhMCVVMxFTATBgNV
# BAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8G
# A1UEAxMYRGlnaUNlcnQgQXNzdXJlZCBJRCBDQS0xMB4XDTE0MTAyMjAwMDAwMFoX
# DTI0MTAyMjAwMDAwMFowRzELMAkGA1UEBhMCVVMxETAPBgNVBAoTCERpZ2lDZXJ0
# MSUwIwYDVQQDExxEaWdpQ2VydCBUaW1lc3RhbXAgUmVzcG9uZGVyMIIBIjANBgkq
# hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAo2Rd/Hyz4II14OD2xirmSXU7zG7gU6mf
# H2RZ5nxrf2uMnVX4kuOe1VpjWwJJUNmDzm9m7t3LhelfpfnUh3SIRDsZyeX1kZ/G
# FDmsJOqoSyyRicxeKPRktlC39RKzc5YKZ6O+YZ+u8/0SeHUOplsU/UUjjoZEVX0Y
# hgWMVYd5SEb3yg6Np95OX+Koti1ZAmGIYXIYaLm4fO7m5zQvMXeBMB+7NgGN7yfj
# 95rwTDFkjePr+hmHqH7P7IwMNlt6wXq4eMfJBi5GEMiN6ARg27xzdPpO2P6qQPGy
# znBGg+naQKFZOtkVCVeZVjCT88lhzNAIzGvsYkKRrALA76TwiRGPdwIDAQABo4ID
# NTCCAzEwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAww
# CgYIKwYBBQUHAwgwggG/BgNVHSAEggG2MIIBsjCCAaEGCWCGSAGG/WwHATCCAZIw
# KAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwggFkBggr
# BgEFBQcCAjCCAVYeggFSAEEAbgB5ACAAdQBzAGUAIABvAGYAIAB0AGgAaQBzACAA
# QwBlAHIAdABpAGYAaQBjAGEAdABlACAAYwBvAG4AcwB0AGkAdAB1AHQAZQBzACAA
# YQBjAGMAZQBwAHQAYQBuAGMAZQAgAG8AZgAgAHQAaABlACAARABpAGcAaQBDAGUA
# cgB0ACAAQwBQAC8AQwBQAFMAIABhAG4AZAAgAHQAaABlACAAUgBlAGwAeQBpAG4A
# ZwAgAFAAYQByAHQAeQAgAEEAZwByAGUAZQBtAGUAbgB0ACAAdwBoAGkAYwBoACAA
# bABpAG0AaQB0ACAAbABpAGEAYgBpAGwAaQB0AHkAIABhAG4AZAAgAGEAcgBlACAA
# aQBuAGMAbwByAHAAbwByAGEAdABlAGQAIABoAGUAcgBlAGkAbgAgAGIAeQAgAHIA
# ZQBmAGUAcgBlAG4AYwBlAC4wCwYJYIZIAYb9bAMVMB8GA1UdIwQYMBaAFBUAEisT
# mLKZB+0e36K+Vw0rZwLNMB0GA1UdDgQWBBRhWk0ktkkynUoqeRqDS/QeicHKfTB9
# BgNVHR8EdjB0MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNl
# cnRBc3N1cmVkSURDQS0xLmNybDA4oDagNIYyaHR0cDovL2NybDQuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0QXNzdXJlZElEQ0EtMS5jcmwwdwYIKwYBBQUHAQEEazBpMCQG
# CCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQQYIKwYBBQUHMAKG
# NWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRENB
# LTEuY3J0MA0GCSqGSIb3DQEBBQUAA4IBAQCdJX4bM02yJoFcm4bOIyAPgIfliP//
# sdRqLDHtOhcZcRfNqRu8WhY5AJ3jbITkWkD73gYBjDf6m7GdJH7+IKRXrVu3mrBg
# JuppVyFdNC8fcbCDlBkFazWQEKB7l8f2P+fiEUGmvWLZ8Cc9OB0obzpSCfDscGLT
# Ykuw4HOmksDTjjHYL+NtFxMG7uQDthSr849Dp3GdId0UyhVdkkHa+Q+B0Zl0DSbE
# Dn8btfWg8cZ3BigV6diT5VUW8LsKqxzbXEgnZsijiwoc5ZXarsQuWaBh3drzbaJh
# 6YoLbewSGL33VVRAA5Ira8JRwgpIr7DUbuD0FAo6G+OPPcqvao173NhEMIIGzTCC
# BbWgAwIBAgIQBv35A5YDreoACus/J7u6GzANBgkqhkiG9w0BAQUFADBlMQswCQYD
# VQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGln
# aWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3QgQ0Ew
# HhcNMDYxMTEwMDAwMDAwWhcNMjExMTEwMDAwMDAwWjBiMQswCQYDVQQGEwJVUzEV
# MBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29t
# MSEwHwYDVQQDExhEaWdpQ2VydCBBc3N1cmVkIElEIENBLTEwggEiMA0GCSqGSIb3
# DQEBAQUAA4IBDwAwggEKAoIBAQDogi2Z+crCQpWlgHNAcNKeVlRcqcTSQQaPyTP8
# TUWRXIGf7Syc+BZZ3561JBXCmLm0d0ncicQK2q/LXmvtrbBxMevPOkAMRk2T7It6
# NggDqww0/hhJgv7HxzFIgHweog+SDlDJxofrNj/YMMP/pvf7os1vcyP+rFYFkPAy
# IRaJxnCI+QWXfaPHQ90C6Ds97bFBo+0/vtuVSMTuHrPyvAwrmdDGXRJCgeGDboJz
# PyZLFJCuWWYKxI2+0s4Grq2Eb0iEm09AufFM8q+Y+/bOQF1c9qjxL6/siSLyaxhl
# scFzrdfx2M8eCnRcQrhofrfVdwonVnwPYqQ/MhRglf0HBKIJAgMBAAGjggN6MIID
# djAOBgNVHQ8BAf8EBAMCAYYwOwYDVR0lBDQwMgYIKwYBBQUHAwEGCCsGAQUFBwMC
# BggrBgEFBQcDAwYIKwYBBQUHAwQGCCsGAQUFBwMIMIIB0gYDVR0gBIIByTCCAcUw
# ggG0BgpghkgBhv1sAAEEMIIBpDA6BggrBgEFBQcCARYuaHR0cDovL3d3dy5kaWdp
# Y2VydC5jb20vc3NsLWNwcy1yZXBvc2l0b3J5Lmh0bTCCAWQGCCsGAQUFBwICMIIB
# Vh6CAVIAQQBuAHkAIAB1AHMAZQAgAG8AZgAgAHQAaABpAHMAIABDAGUAcgB0AGkA
# ZgBpAGMAYQB0AGUAIABjAG8AbgBzAHQAaQB0AHUAdABlAHMAIABhAGMAYwBlAHAA
# dABhAG4AYwBlACAAbwBmACAAdABoAGUAIABEAGkAZwBpAEMAZQByAHQAIABDAFAA
# LwBDAFAAUwAgAGEAbgBkACAAdABoAGUAIABSAGUAbAB5AGkAbgBnACAAUABhAHIA
# dAB5ACAAQQBnAHIAZQBlAG0AZQBuAHQAIAB3AGgAaQBjAGgAIABsAGkAbQBpAHQA
# IABsAGkAYQBiAGkAbABpAHQAeQAgAGEAbgBkACAAYQByAGUAIABpAG4AYwBvAHIA
# cABvAHIAYQB0AGUAZAAgAGgAZQByAGUAaQBuACAAYgB5ACAAcgBlAGYAZQByAGUA
# bgBjAGUALjALBglghkgBhv1sAxUwEgYDVR0TAQH/BAgwBgEB/wIBADB5BggrBgEF
# BQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBD
# BggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0
# QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0fBHoweDA6oDigNoY0aHR0cDovL2Ny
# bDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDA6oDig
# NoY0aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9v
# dENBLmNybDAdBgNVHQ4EFgQUFQASKxOYspkH7R7for5XDStnAs0wHwYDVR0jBBgw
# FoAUReuir/SSy4IxLVGLp6chnfNtyA8wDQYJKoZIhvcNAQEFBQADggEBAEZQPsm3
# KCSnOB22WymvUs9S6TFHq1Zce9UNC0Gz7+x1H3Q48rJcYaKclcNQ5IK5I9G6OoZy
# rTh4rHVdFxc0ckeFlFbR67s2hHfMJKXzBBlVqefj56tizfuLLZDCwNK1lL1eT7EF
# 0g49GqkUW6aGMWKoqDPkmzmnxPXOHXh2lCVz5Cqrz5x2S+1fwksW5EtwTACJHvzF
# ebxMElf+X+EevAJdqP77BzhPDcZdkbkPZ0XN1oPt55INjbFpjE/7WeAjD9KqrgB8
# 7pxCDs+R1ye3Fu4Pw718CqDuLAhVhSK46xgaTfwqIa1JMYNHlXdx3LEbS0scEJx3
# FMGdTy9alQgpECYwggciMIIGCqADAgECAgIA5jANBgkqhkiG9w0BAQUFADA9MQsw
# CQYDVQQGEwJHQjERMA8GA1UEChMIQXNjZXJ0aWExGzAZBgNVBAMTEkFzY2VydGlh
# IFJvb3QgQ0EgMjAeFw0wOTA0MjExMjE1MTdaFw0yODA0MTQyMzU5NTlaMD8xCzAJ
# BgNVBAYTAkdCMREwDwYDVQQKEwhBc2NlcnRpYTEdMBsGA1UEAxMUQXNjZXJ0aWEg
# UHVibGljIENBIDEwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDPWPIz
# xLPZHflPEdu447bWvKchN1cue6kMlLPLEvBHWs4hcF4Tg5w+zKP+nr1T1tgwZD+K
# bl3EG1KwEfXZCNBO9gRP/v8kcl8NrLSqfDT42wpYJms0u6xpNCjM8YVrkheQld6f
# i/Hfo4rVEEhWeHE5XjSdaLuaswnz/WQOJ12InjrOxOdu8fvyHVHt64fW07nBMI+N
# p8nNXQ/rfn8Em19GxgezP826lbFX9Jtv5rSKGGUq4A9AAA5EcMB++AZ6tWozF/Sb
# MRk1RL0bBjn6lmnnolWUad8hjcHRCfae65imcyCh1Zl3CCK5/Okds+hZ8NIQcJop
# Di3O7EQ4cxdyQTdlAgMBAAGjggQoMIIEJDAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0T
# AQH/BAgwBgEB/wIBAjCB8AYDVR0gBIHoMIHlMIHiBgorBgEEAfxJAQEBMIHTMIHQ
# BggrBgEFBQcCAjCBwxqBwFdhcm5pbmc6IENlcnRpZmljYXRlcyBhcmUgaXNzdWVk
# IHVuZGVyIHRoaXMgcG9saWN5IHRvIGluZGl2aWR1YWxzIHRoYXQgaGF2ZSBub3Qg
# aGFkIHRoZWlyIGlkZW50aXR5IGNvbmZpcm1lZC4gRG8gbm90IHVzZSB0aGVzZSBj
# ZXJ0aWZpY2F0ZXMgZm9yIHZhbHVhYmxlIHRyYW5zYWN0aW9ucy4gTk8gTElBQklM
# SVRZIElTIEFDQ0VQVEVELjCCATMGA1UdDgSCASoEggEmMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAz1jyM8Sz2R35TxHbuOO21rynITdXLnupDJSzyxLw
# R1rOIXBeE4OcPsyj/p69U9bYMGQ/im5dxBtSsBH12QjQTvYET/7/JHJfDay0qnw0
# +NsKWCZrNLusaTQozPGFa5IXkJXen4vx36OK1RBIVnhxOV40nWi7mrMJ8/1kDidd
# iJ46zsTnbvH78h1R7euH1tO5wTCPjafJzV0P635/BJtfRsYHsz/NupWxV/Sbb+a0
# ihhlKuAPQAAORHDAfvgGerVqMxf0mzEZNUS9GwY5+pZp56JVlGnfIY3B0Qn2nuuY
# pnMgodWZdwgiufzpHbPoWfDSEHCaKQ4tzuxEOHMXckE3ZQIDAQABMFoGA1UdHwRT
# MFEwT6BNoEuGSWh0dHA6Ly93d3cuYXNjZXJ0aWEuY29tL09ubGluZUNBL2NybHMv
# QXNjZXJ0aWFSb290Q0EyL0FzY2VydGlhUm9vdENBMi5jcmwwPQYIKwYBBQUHAQEE
# MTAvMC0GCCsGAQUFBzABhiFodHRwOi8vb2NzcC5nbG9iYWx0cnVzdGZpbmRlci5j
# b20wggE3BgNVHSMEggEuMIIBKoCCASYwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
# ggEKAoIBAQCWN76e4Nk+poYTF/ZK86kH8xZo1X9EFkfzIZ99/OT/pPQLvs30wgYD
# 4uyhRBTFkKGf0dH3HjKz1N9SFJud0eqbxtH3YPr8rUjHkxjrX34LxCFWBNoj4T3F
# w3LGnTpGeO6xEaEDAdvdInm3BJvpG4VWES3Z7SJteaIbkNmqDn0DhRpMFXiNKgZK
# NWIcJM1ZGW9+OZO7vxUZrOPBfceplWg70Torc8TBYL7Pv1/g6kuZCO7Dx1nF6agi
# 9GCIHRkMrcjguIqkg8qSL+KWxwWuKi8YHBG4i7vIgvHOKL2lnmdoe63WRAG9wUHb
# 68duwBc1tIAPqam90MQrMyhTGzhwI7aDAgMBAAEwDQYJKoZIhvcNAQEFBQADggEB
# AJSUl6GjE5m6hkpci2WLPoJMrG90TALbigGZS1zTYLsIwUxfx0VndhR/YU7dUQf5
# vFPhzQf9mwm9vidT9Wwd6Wg0hmDiT8Lh5y7T4XyqjuMKN3cp7eDFkrSCUhvT8Lg2
# n/qxeeJMD3ghtFhoyXtI5A/6CmPHBkcNMtQZAhORKjpJ41wSa+vH6v1TzC8otw+x
# uxgyAkO/hRmmmBIgGDuwxKfLrdBQRZWeBRmWqH7grQlE0gYYpBFS4FlorwBqjiID
# p6FH52OrLS9gLV2f1emxMQAlwh3LMBmwvUtTQs++8M8oX2EpXZCIHeoOEFEMbzmE
# v4I88yooHJxcTL026vcl/1IxggQMMIIECAIBATBYMD8xCzAJBgNVBAYTAkdCMREw
# DwYDVQQKEwhBc2NlcnRpYTEdMBsGA1UEAxMUQXNjZXJ0aWEgUHVibGljIENBIDEC
# FQCdDgExwhEGCyl5TLUkaz5mLyd2ojAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIB
# DDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEE
# AYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUSVCok5o7sxVJ
# 2mYtd1aVb/HRqaAwDQYJKoZIhvcNAQEBBQAEggEApt8n3Jk/deFKlydZhpoQMUfI
# AwKSw+36R7y/F1Sw7J/uWzFFB32ZBpSoEWnZKaVJ/FYnQWc4gTwrgepYePE/3u5O
# rxM7Yrb4TEUgBv5+InUNbq4jxlmWoBOjGi1hbYM171RnL0Ja1RoTRP5hn/7TUTYe
# LHw9r3wFvj5n+FSPVoLbay0P+9nqGLE7aTkrRHHTu5Ps9b8GbBxOLz7AI0/vK6sl
# tbUK3f8psOIuGZFpPRVChBwasvXu4noNSuXu8ggUC+uzDZEzsjqwDhCQl87bwVoM
# 6+yn4pJBEoHntW6y5utvWhAK1f7m69SYZa8P1/QhdfiE68rpQB4XS3eyV52z+aGC
# Ag8wggILBgkqhkiG9w0BCQYxggH8MIIB+AIBATB2MGIxCzAJBgNVBAYTAlVTMRUw
# EwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20x
# ITAfBgNVBAMTGERpZ2lDZXJ0IEFzc3VyZWQgSUQgQ0EtMQIQAwGaAjr/WLFr1tXq
# 5hfwZjAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkq
# hkiG9w0BCQUxDxcNMTkwMTA0MjA1MDE4WjAjBgkqhkiG9w0BCQQxFgQUxJcggzFZ
# jOdtlHFaSjxAmMo3KhcwDQYJKoZIhvcNAQEBBQAEggEAFdSMNLkTWzKu9Rnjm7pe
# FLsSDldPiqocZH+0I3dy4nNXb5TDUpKRH/ZnMNOTBVN12t2Hi7GoGUodu+/QP7re
# skIWVFz6lIZ3ytC7wX2XLC2tKjfHHW0fsi3Ql8e+LMXuk8aNkpwbTN0Hpd42ycqz
# a3Nqmv0fh9pwWI0rgoV1HnT2NlFEUQE3DRcAJs+uh4Uvu1QYj2UxYR/W+ZXSEdmt
# /Pv/vcltHy2ob/+CsVJ7ecLc7OfVvR6hLWd/Fa7XzIYrjZxApIlhFQ/9eLFJaufB
# LckMKlV3Qy3gqA+vcl37z/G5hgKAReYjp/uDRIGIuyIOxEZWZZpIyDJLgd51Y5Cf
# iQ==
# SIG # End signature block