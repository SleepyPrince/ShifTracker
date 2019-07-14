# Filename base on last write time (yyyyMMddHHmm.zip)
$root = "D:\Users\cad\Documents\ShifTracker"
get-item 'Z:\*Roster' | Foreach {if($_.LastWriteTime -gt $latest){$latest = $_.LastWriteTime}}
$zip = "$root\$($latest.toString('yyyyMMddHHmm')).zip"

# Check if file already exists
If(-Not (Test-path $zip -PathType Leaf)){
	# Zip file with supressed progress bar
	$global:ProgressPreference = 'SilentlyContinue'
	Compress-Archive -LiteralPath 'Z:\ATFSO_SATCO_ADCT Roster','Z:\ATCO & ADCO Roster' -DestinationPath $zip -CompressionLevel Optimal -Update | Out-Null

	# Print filename
	write-host $zip.split('\')[-1]

	# Upload zip file
	DropBox $zip "/$($zip.split('\')[-1])"
}else{
	write-host "File already exists ($($zip.split('\')[-1]))"
}