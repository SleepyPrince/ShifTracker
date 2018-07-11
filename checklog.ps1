Function checklog {
	Param(
		[Parameter(Mandatory=$true)]
		[string]$logFile
	)
	
	if ( [System.IO.File]::Exists($logFile) -and (get-content $logFile)[-1] -NotMatch 'Roster conversion completed' ){
		# Load token
		. ".\pushtoken.ps1"	
		$message = (get-content $logFile -tail 12) -join '<br>'
		$message = "$logFile<br>$message"
		$title = "Roster conversion failed"
		#write-host $title

		$postParams = @{token=$pushoverToken;user=$pushoverUser;html=1;title=$title;message=$message}
		Invoke-WebRequest -Uri https://api.pushover.net/1/messages.json -Method POST -Body $postParams
		return $False
	}
	return $True
}