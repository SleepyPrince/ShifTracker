. ".\dropbox.ps1"
. ".\ProcessExcel.ps1"
. ".\Combine.ps1"
. ".\toLog.ps1"

$global:logFile = "pslog.txt"
$global:showDebug = $True

toLog "$(Get-Date)`tManual task started"
ProcessExcel "D:\Users\cad\Documents\ShifTracker\v9\ExportTXT-9.xlsm"

toLog "$(Get-Date)`tUploading files"

DropBox "D:\Users\cad\Documents\ShifTracker\v9\ATCapp_Roster_Version.txt" "/Server/STRostersVersion.txt"
DropBox "D:\Users\cad\Documents\ShifTracker\v9\ATCapp_Rosters_new.txt" "/Server/STRostersData.txt"

toLog "======================================================================"