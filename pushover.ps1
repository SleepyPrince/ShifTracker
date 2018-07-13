Function pushover {
	Param(
		[Parameter(Mandatory=$false)]
		[string]$title="",
		[Parameter(Mandatory=$true)]
		[string]$message
	)
	
	# Load token
	. ".\pushtoken.ps1"	

	$postParams = @{token=$pushoverToken;user=$pushoverUser1;html=1;title=$title;message=$message}
	$progressPreference = 'silentlyContinue'
	try {
		$r = Invoke-WebRequest -Uri https://api.pushover.net/1/messages.json -Method POST -Body $postParams
	} catch {
      $r = $_.Exception.Response.StatusCode.Value__
	}
	$progressPreference = 'Continue'
	return ($r -match '"status":1,')
}