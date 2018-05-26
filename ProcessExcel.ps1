function ProcessExcel {
	Param ([String] $filePath)
	$filePath = (Resolve-Path $filePath)
	# Check if file exists
	if ([System.IO.File]::Exists($filePath)){
	
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
		Write-debug "Excel file ($($filePath)) not found"
	}
}