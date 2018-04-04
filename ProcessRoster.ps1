. ".\dropbox.ps1"
. ".\ProcessExcel.ps1"
. ".\Combine.ps1"
. ".\toLog.ps1"

$global:logFile = "pslog.txt"
$global:showDebug = $True

toLog "$(Get-Date)`tManual task started"
ProcessExcel "D:\Users\cad\Documents\ShifTracker\ExportTXT-8.1e.xls"

toLog "$(Get-Date)`tIntegrating personal notes"

Combine

toLog "$(Get-Date)`tUploading files"

DropBox "D:\Users\cad\Documents\ShifTracker\ATCapp_Rosters_new.txt" "/Server/STRostersData_raw.txt"
DropBox "D:\Users\cad\Documents\ShifTracker\betaRoster.txt" "/Server/STRostersData.txt"
DropBox "D:\Users\cad\Documents\ShifTracker\ATCapp_Roster_Version.txt" "/Server/STRostersVersion.txt"

toLog "======================================================================"