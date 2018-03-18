# Upload to dropbox

Function Dropbox {
	Param(
		[Parameter(Mandatory=$true)]
		[string]$SourceFilePath,
		[Parameter(Mandatory=$true)]
		[string]$TargetFilePath,
		[Parameter(Mandatory=$false)]
		[string]$token
	)

	# Load Token
	if(-not($PSBoundParameters.ContainsKey('token'))){
		$token = Get-Content .\token -Raw
	}
	$authorization = "Bearer $($token)"
	
	$arg = '{ "path": "' + $TargetFilePath + '", "mode": {".tag" : "overwrite"} }'

	# Dropbox Upload Headers
	$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
	$headers.Add("Authorization", $authorization)
	$headers.Add("Dropbox-API-Arg", $arg)
	$headers.Add("Content-Type", 'application/octet-stream')
	
	# Get File Name
	$name = Split-Path $SourceFilePath -leaf
	
	# Check if toLog exists, if not use Write-Host instead
	if (Get-Command toLog -errorAction SilentlyContinue)
	{
		$alias = $false
	}else{
		Set-Alias toLog Write-Host
		$alias = $true
	}
	
	# Try to upload and write error if fail
	try{
		Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $SourceFilePath -Headers $headers > $null
		toLog "$(Get-Date)`t$($name) uploaded successfully"
	}catch{
		if ($_ -ne $null){
			toLog "$(Get-Date)`t$($name) upload failed: $($_)"
		}else{
			toLog "$(Get-Date)`t$($name) upload failed. (Reason unknown)"
		}
	}
	
	# remove alias if set
	if($alias){
		Remove-Item alias:\toLog
	}
}