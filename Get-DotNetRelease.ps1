#
# Get-DotNetReleaseVersion.ps1
#

Function Get-DotNetReleaseVersion
{
	[CmdletBinding()]
	Param ( 
		[string]$ComputerName = "$env:ComputerName"
	)

	# Check to make sure the target computer is alive.
	# If it's alive, continue.
	# If it's dead, break.
	Begin
	{
		if (Test-Connection $ComputerName -Quiet -Count 2)
		{
			Write-Verbose "$ComputerName is reachable."
		
		}
		else
		{
			Write-Verbose "Cannot establish communication with $ComputerName"
			BREAK;
		}
	}
	
	# Try to open up the .NET 4.5 registry key on the target computer
	# If the key exists, get the value of the release.
	# The release value is passed to a switch step to determine the .NET framework version
	# Updated versions can be found at https://msdn.microsoft.com/en-us/library/hh925568(v=vs.110).aspx#net_d
	Process
	{
		try
			{
				$Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $ComputerName)
				$RegKey= $Reg.OpenSubKey("SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full")
				$DotNetRelease = $RegKey.GetValue("Release")
			}
			catch [System.Management.Automation.MethodException]
			{
				write-verbose "Cannot open registry key on $ComputerName"
				Write-Verbose ".NET Framework 4.5 or newer cannot be found."
				BREAK;
			}
			catch [System.SystemException]
			{
				write-verbose "Cannot open registry key on $ComputerName"
				Write-Verbose ".NET Framework 4.5 or newer cannot be found."
				BREAK;
			}

		Switch ($DotNetRelease)
		{ 
			379893 {"$ComputerName is running .NET Framework 4.5.2"} 
			378758 {"$ComputerName is running .NET Framework 4.5.1"} # Windows 7
			378675 {"$ComputerName is running .NET Framework 4.5.1"} # Windows 8.1
			378389 {"$ComputerName is running .NET Framework 4.5"} 
			393295 {"$ComputerName is running .NET Framework 4.6"}  # Windows 10
			393297 {"$ComputerName is running .NET Framework 4.6"} 
			394254 {"$ComputerName is running .NET Framework 4.6.1"} # Windows 10
			394271 {"$ComputerName is running .NET Framework 4.6.1"} 
			default {".NET Framework 4.5 or newer cannot be found on $ComputerName"}
		}

	}
	
	End
	{
		write-verbose "The script has finished successfully."
	}
}
