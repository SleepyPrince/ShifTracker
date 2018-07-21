. ".\dropbox.ps1"
. ".\ProcessExcel.ps1"
. ".\Combine.ps1"
. ".\toLog.ps1"

$global:logFile = "pslog.txt"
$global:showDebug = $True

toLog "$(Get-Date)`tManual task started"

$xls = @("D:\Users\cad\Documents\ShifTracker\v9\ExportTXT-9.xlsm")
$xlsLog = @("D:\Users\cad\Documents\ShifTracker\v9\log.txt")

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

toLog "======================================================================"