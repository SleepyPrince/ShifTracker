function toLog {
	Param ([String] $msg)

	add-content $global:logFile $msg
	if ($global:showDebug) {
		Write-Debug $msg
	}
}