# One instance only (Kill current Instance)
Get-Process pwsh | Where-Object {$_.MainWindowTitle -eq '' -and $_.Id -ne $pid} | Stop-Process

# Load functions
. ".\dropbox.ps1"
. ".\ProcessExcel.ps1"
. ".\toLog.ps1"
. ".\pushover.ps1"

function PendingUpdate {
    Param ($Event)
	$time = $Event.TimeGenerated
	$name = $Event.SourceEventArgs.Name
	$type = $Event.SourceEventArgs.ChangeType
	
	# Log all events
	#toLog "$($time)`t$($type)`t$($name)"
	
	# Skip Temp Files
    if($name.contains('~') -eq $False -and $name.contains(".tmp") -eq $False){
		
		# Set next run in 30s
		$global:nextUpdate = $time.AddSeconds(30)
		$global:pending = $true
		
		# Log peding update time
		toLog "$($time)`t$($type)`t$($name)"
		toLog "`t`t`t`t`tPending Update @ $($global:nextUpdate)"

	}else{
		#toLog "$($time)`tTemp File $($name)"
	}
}

$global:showDebug = $False
if($global:showDebug) { $DebugPreference = "Continue" }
$folder = 'Z:\'
$filter = '*.xlsx'
$global:pending = $true
$global:nextUpdate = (Get-Date).AddMinutes(0)
$global:logFile = "pslog.txt"

# Init fileSystemWatcher parameters
$fsw = New-Object IO.FileSystemWatcher
$fsw.Path = $folder
$fsw.Filter = $filter
$fsw.IncludeSubdirectories = $true
$fsw.EnableRaisingEvents = $true

# Clear previous change watchers
Unregister-Event FileChanged -Erroraction 'silentlycontinue'
Unregister-Event FileCreated -Erroraction 'silentlycontinue'
Unregister-Event FileRenamed -Erroraction 'silentlycontinue'

toLog "$(Get-Date)`tScript Started"

# Monitor changes
Register-ObjectEvent $fsw Changed -SourceIdentifier FileChanged -Action {
	endingUpdate($Event)
} > $null

Register-ObjectEvent $fsw Created -SourceIdentifier FileCreated -Action {
	PendingUpdate($Event)
} > $null

Register-ObjectEvent $fsw Renamed -SourceIdentifier FileRenamed -Action {
	PendingUpdate($Event)
} > $null

toLog "$(Get-Date)`tEvents Registered"

while ($true) {
	# Re-register events if Network drive is disconnected
	If((Test-Path $folder) -ne $True){
		toLog "$(Get-Date)`tNetwork drive disconnected"
		
		while ((Test-Path $folder) -ne $True){
			# Wait 10s
			Start-Sleep -Seconds 10
		}
		
		toLog "$(Get-Date)`tNetwork drive back online"
		
		# Clear previous change watchers
		Unregister-Event FileChanged -Erroraction 'silentlycontinue'
		Unregister-Event FileCreated -Erroraction 'silentlycontinue'
		Unregister-Event FileRenamed -Erroraction 'silentlycontinue'

		# Monitor changes
		Register-ObjectEvent $fsw Changed -SourceIdentifier FileChanged -Action {
			endingUpdate($Event)
		} > $null

		Register-ObjectEvent $fsw Created -SourceIdentifier FileCreated -Action {
			PendingUpdate($Event)
		} > $null

		Register-ObjectEvent $fsw Renamed -SourceIdentifier FileRenamed -Action {
			PendingUpdate($Event)
		} > $null

		toLog "$(Get-Date)`tEvents Registered"
		
		# Do an update in case file changes during network drive disconnect
		$global:nextUpdate = (Get-Date)
		$global:pending = $true
		toLog "$(Get-Date)`tPending Update @ $($global:nextUpdate)"
	}
	
	# Loop every 1s
	Start-Sleep -Seconds 1
	
	# Run task if pending update and current time has passed 'next run' time
	if($global:pending -eq $true -AND (Get-Date).CompareTo($nextUpdate) -ge 0){
		toLog "$(Get-Date)`tTask Started"
		$global:pending = $false
		
		$xls = "D:\Users\cad\Documents\ShifTracker\v9\ExportTXT-9.xlsm", "D:\Users\cad\Documents\ShifTracker\v9.1\ExportTXT-9.xlsm"
		$xlsLog = "D:\Users\cad\Documents\ShifTracker\v9\log.txt", "D:\Users\cad\Documents\ShifTracker\v9.1\log.txt"
		
		for ($i=0 ; $i -lt $xls.Count ; $i++){
			if ( -Not (ProcessExcel $xls[$i])[-1] ){
				toLog "$(Get-Date)`t$($xls[$i]) Failed"
				$message = (get-content $xlslog[$i] -tail 11) -join '<br>'
				$message = "$($xls[$i])<br>$message"
				$title = "Roster conversion failed"
				if((pushover $title $message)){
					toLog "$(Get-Date)`tAlert sent successfully"
				}else{
					toLog "$(Get-Date)`tAlert sent failed"
				}
			}else{
				toLog "$(Get-Date)`t$($xls[$i]) Success"
			}
		}
				
		toLog "$(Get-Date)`tUploading files"
		
		DropBox "D:\Users\cad\Documents\ShifTracker\v9\ATCapp_Roster_Version.txt" "/Server/STRostersVersion.txt"
		DropBox "D:\Users\cad\Documents\ShifTracker\v9\ATCapp_Rosters_new.txt" "/Server/STRostersData.txt"
		DropBox "D:\Users\cad\Documents\ShifTracker\v9.1\ATCapp_Rosters_new.txt" "/Server/STRostersData_v9.txt"
		
		toLog "======================================================================"
    }
}