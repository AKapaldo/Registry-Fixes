<#
.Synopsis
Used to repair registry settings on a remote machine.
.Description
Used to repair registry settings on a remote machine.
.Parameter ComputerName
Set a remote machine name to edit the registry on.
.Notes
None.
#>
function Set-RegFix {
[cmdletbinding()]
param(
	[Parameter()]
	[string]$ComputerName=$(read-host -prompt "Enter Remote System Number")
)
Process {
Write-Host "R1 - Repair Username Hint Box"
Write-Host "R2 - Repair Skype for Outlook Addin"
Write-Host "R3 - Repair Entrust for Outlook Addin"
$Sel = Read-Host "Which Option?"
Switch ($sel) {
"R1" {
		
		$CurrentValue = Invoke-Command -ComputerName $ComputerName -ScriptBlock {Get-ItemProperty 'Registry::Hkey_local_machine\SOFTWARE\Policies\Microsoft\Windows\SmartCardCredentialProvider' | Select -expand X509HintsNeeded}
		IF ($CurrentValue -eq 1){Write-Host "X509HintsNeeded is already set to $CurrentValue"}
		ELSE {
		$Change = Read-Host "X509HintsNeeded is set to $CurrentValue - Change to 1/enable? Y or N"
			IF ($Change -eq "Y" -OR $Change -eq "Yes"){
			Invoke-Command -ComputerName $ComputerName -ScriptBlock {Set-ItemProperty 'Registry::Hkey_local_machine\SOFTWARE\Policies\Microsoft\Windows\SmartCardCredentialProvider' -Name X509HintsNeeded -value 1 -PassThru}
			Pause}
			ELSE {Write-Warning "X509HintsNeeded not changed."}
		
		}}
		"R2" {
		
		$CurrentValue = Invoke-Command -ComputerName $ComputerName -ScriptBlock {Get-ItemProperty 'Registry::Hkey_local_machine\Software\WOW6432Node\Microsoft\Office\Outlook\Addins\UCAddin.LyncAddin.1' | Select -Expand loadbehavior}
		IF ($CurrentValue -eq 3){Write-Host "LoadBehavior is already set to $CurrentValue"}
		ELSE {
		$Change = Read-Host "LoadBehavior is set to $CurrentValue - Change to 3/On Startup? Y or N"
			IF ($Change -eq "Y" -OR $Change -eq "Yes"){
			Invoke-Command -ComputerName $ComputerName -ScriptBlock {Set-ItemProperty 'Registry::Hkey_local_machine\Software\WOW6432Node\Microsoft\Office\Outlook\Addins\UCAddin.LyncAddin.1' -Name loadbehavior -value 3 -PassThru}
			Pause}
			ELSE {Write-Warning "LoadBehavior not changed."}
		}}
		"R3" {
		
		$CurrentValue1 = Invoke-Command -ComputerName $ComputerName -ScriptBlock {Get-ItemProperty 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Office\Outlook\Addins\Entrust.SMIMEFormat' | Select -Expand loadbehavior}
		$CurrentValue2 = Invoke-Command -ComputerName $ComputerName -ScriptBlock {Get-ItemProperty 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Office\Outlook\Addins\Entrust.SMIMEFormat' | Select -Expand loadbehavior}
		IF ($CurrentValue1 -eq 3 -AND $CurrentValue2 -eq 3) {Write-Host "LoadBehavior is already set to $CurrentValue"}
		ELSE {
		$Change = Read-Host "LoadBehavior set to $CurrentValue1 and $CurrentValue2 - Change to 3/On Startup? Y or N."}
			IF ($Change -eq "Y" -OR $Change -eq "Yes"){
				IF ($CurrentValue1 -eq 3 -AND $CurrentValue2 -ne 3)
				{Invoke-Command -ComputerName $ComputerName -ScriptBlock {Set-ItemProperty 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Office\Outlook\Addins\Entrust.SMIMEFormat' -Name loadbehavior -Value 3 -PassThru}
				Pause}
				ELSEIF ($CurrentValue1 -ne 3 -AND $CurrentValue2 -eq 3) {
				Invoke-Command -ComputerName $ComputerName -ScriptBlock {Set-ItemProperty 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Office\Outlook\Addins\Entrust.SMIMEFormat' -Name loadbehavior -Value 3 -PassThru}
				Pause
				}
				ELSEIF ($CurrentValue1 -ne 3 -AND $CurrentValue2 -ne 3) {Invoke-Command -ComputerName $ComputerName -ScriptBlock {
				Set-ItemProperty 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Office\Outlook\Addins\Entrust.SMIMEFormat' -Name loadbehavior -Value 3 -PassThru
				Set-ItemProperty 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Office\Outlook\Addins\Entrust.SMIMEFormat' -Name loadbehavior -Value 3 -PassThru
				Pause}}
				ELSE {Write-Warning "Error: Script Failed"}
			}
			ELSE {Write-Warning "LoadBehavior not changed."}
		}
		
		}}
		}
