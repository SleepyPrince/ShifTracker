function ProcessExcel {
	Param (
		[Parameter(Mandatory=$true)]
		[String] $filePath,
		[Parameter(Mandatory=$false)]
		[string] $logFile = ""
	)
	$filePath = (Resolve-Path $filePath)
	if ($logFile -eq ""){
		$logFile = "$(Split-Path -Path $filePath)\log.txt"
	}else{
		$logFile = (Resolve-Path $logFile)
	}
	
	# Check if file exists
	if ([System.IO.File]::Exists($filePath) -And [System.IO.File]::Exists($logFile)){
	
		# Init and open Excel file
		$excel = new-object -comobject excel.application
		$excel.Visible = $False
		$excel.ScreenUpdating = $False
		$excel.DisplayAlerts = $False
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
		
	}else{
		#Write-debug "Excel file ($($filePath)) not found"
		return $False
	}
	
	if ( [System.IO.File]::Exists($logFile) -and (get-content $logFile)[-1] -Match 'Roster conversion completed' ){
		return $True
	}else{
		return $False
	}
}