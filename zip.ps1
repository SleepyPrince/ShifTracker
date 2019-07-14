# Filename base on last write time (yyyyMMddHHmm.zip)
$root = "D:\Users\cad\Documents\ShifTracker"
get-item 'Z:\*Roster' | Foreach {if($_.LastWriteTime -gt $latest){$latest = $_.LastWriteTime}}
$zip = "$root\$($latest.toString('yyyyMMddHHmm')).zip"

# Zip file with supressed progress bar
$global:ProgressPreference = 'SilentlyContinue'
Compress-Archive -LiteralPath 'Z:\ATFSO_SATCO_ADCT Roster','Z:\ATCO & ADCO Roster' -DestinationPath $zip -CompressionLevel Optimal -Update | Out-Null

# Print filename
write-host $zip.split('\')[-1]