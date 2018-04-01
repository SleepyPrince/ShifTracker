Function Combine {
	$betaRoster = ".\betaRoster.txt"
	if (Test-Path $betaRoster){
		Clear-Content -Path $betaRoster
	}
	
	# Output StreamWriter
	$stream = [System.IO.StreamWriter] $betaRoster
	
	# Read roster
	$roster = Get-Content -Encoding ASCII -Path ".\ATCapp_Rosters_new.txt" 

	$month = $null
	$notes = @{}
	Foreach ($line in $roster){
		if($line -match 'Roster:(.+?);'){

			# Empty line
			write-debug ""
			
			# Roster month line
			$month = $Matches[1]
			
			# Clear notes
			$notes.clear()
			
			# Read monthly notes
			write-debug "Reading $($month) Notes"
			$ATCO = ".\$($month)ATCO.txt"
			
			# Read note file is exists
			if (Test-Path $ATCO){
				$hasNoteFile = $True
				$notefile = Get-Content -Path $ATCO
			
				# Read notes into hashtable
				Foreach ($noteEntry in $notefile){
					$sp = ($noteEntry -replace ';(?!$)',';- ').Split(";",2,[System.StringSplitOptions]::RemoveEmptyEntries)
					$notes[$sp[0]] += $sp[1]
				}
				
				write-debug "Processing $($month)"
			}else{
				$hasNoteFile = $False
				write-debug "$($ATCO) not found"
			}

		}elseif($line -match 'Name:.+?;([A-Z]{2});'){
			# Name line
			# Callsign
			$cs = $Matches[1]
			
			# Replace emdash
			$line = $line -replace ";\? ",";-"
			
			# Append/Replace Notes
			#$line = $line -replace '(ATFSO|APPRoster|AreaRoster);.+?$','$1;'
			if($hasNoteFile -eq $True){
				$line = $line -replace 'Individual notes are indicated on "Master Roster".;'
				
				if( $notes.ContainsKey($cs) -and $notes[$cs] -ne ""){
					$line += $notes[$cs]
				}
			}
		}
		# Stream write to output
		$stream.WriteLine($line)
	}
	
	# Close output file
	$stream.close()
}