# One instance only
#Get-Process pwsh | Where-Object {$_.MainWindowTitle -eq '' -and $_.Id -ne $pid} | Stop-Process

# Load Dropbox
. ".\dropbox.ps1"

$global:showDebug = $False
if($global:showDebug) { $DebugPreference = "Continue" }
$folder = 'Z:\'
$filter = '*.xlsx'
$global:pending = $false
$global:nextUpdate = (Get-Date).AddDays(1)
$global:logFile = "pslog-v5.txt"

# Clear previous change watchers
Unregister-Event FileChanged -Erroraction 'silentlycontinue'
Unregister-Event FileCreated -Erroraction 'silentlycontinue'
Unregister-Event FileRenamed -Erroraction 'silentlycontinue'

$fsw = New-Object IO.FileSystemWatcher
$fsw.Path = $folder
$fsw.Filter = $filter
$fsw.IncludeSubdirectories = $true
$fsw.EnableRaisingEvents = $true

function toLog {
	Param ([String] $msg)

	add-content $global:logFile $msg
	if ($global:showDebug) {
		Write-Debug $msg
	}
}

Function PendingUpdate {
    Param ($Event)
	$time = $Event.TimeGenerated
	$name = $Event.SourceEventArgs.Name
	$type = $Event.SourceEventArgs.ChangeType
	
	# Log all events
	#toLog "$($time)`t$($type)`t$($name)"
	
	# Skip Temp Files
    if($name.contains('~') -eq $False -and $name.contains(".tmp") -eq $False){
		
		# Set next run in 2 mins
		$global:nextUpdate = $time.AddMinutes(2)
		$global:pending = $true	
		
		# Log peding update time
		toLog "$($time)`t$($type)`t$($name)"
		toLog "`t`t`t`t`tPending Update @ $($global:nextUpdate)"

	}else{
		toLog "$($time)`tTemp File $($name)"
	}
}

toLog "$(Get-Date)`tScript Started"

# Monitor changes
Register-ObjectEvent $fsw Changed -SourceIdentifier FileChanged -Action {
	try{
		PendingUpdate($Event)
	}catch{
		if ($_ -ne $null){
			toLog "$(Get-Date)`tChanged Event Error: $($_)"
		}else{
			toLog "$(Get-Date)`tChanged Event Error"
		}
	}
} > $null

Register-ObjectEvent $fsw Created -SourceIdentifier FileCreated -Action {
	try{
		PendingUpdate($Event)
	}catch{
		if ($_ -ne $null){
			toLog "$(Get-Date)`tCreated Event Error: $($_)"
		}else{
			toLog "$(Get-Date)`tCreated Event Error"
		}
	}
} > $null

Register-ObjectEvent $fsw Renamed -SourceIdentifier FileRenamed -Action {
	try{
		PendingUpdate($Event)
	}catch{
		if ($_ -ne $null){
			toLog "$(Get-Date)`tRenamed Event Error: $($_)"
		}else{
			toLog "$(Get-Date)`tRenamed Event Error"
		}
	}
} > $null

toLog "$(Get-Date)`tEvents Registered"

while ($true) {
	# Loop every 1s
	Start-Sleep -Seconds 1
	
	# Run task if pending update and current time has passed 'next run' time
	if($global:pending -eq $true -AND (Get-Date).CompareTo($nextUpdate) -ge 0){
		toLog "$(Get-Date)`tTask Started"
		$global:pending = $false
		
		# Init and open Excel file
		$excel = new-object -comobject excel.application
		$excel.Visible = $False
		$excel.ScreenUpdating = $False
		$excel.DisplayAlerts = $False
		$filePath = "D:\Users\cad\Documents\ShifTracker\ExportTXT-8.1e.xls"
		$workbook = $excel.Workbooks.Open($FilePath)
		$excel.Visible = $false
		
		# Run macro
		$excel.Run("OneClick")

		# Close and release
		$workbook.close($false)
		while( [System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) ){}
		Remove-Variable workbook
		$excel.quit()
		while( [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) ){}
		Remove-Variable excel

		#toLog "`t`t`t`t`tClosed Excel"
		toLog "$(Get-Date)`tUploading files"

		DropBox "D:\Users\cad\Documents\ShifTracker\ATCapp_Rosters_new.txt" "/Server/STRostersData.txt"
		DropBox "D:\Users\cad\Documents\ShifTracker\ATCapp_Roster_Version.txt" "/Server/STRostersVersion.txt"
		
		toLog "======================================================================"
    }
}