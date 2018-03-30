Function Combine {
	$betaRoster = ".\betaRoster.txt"
	if (Test-Path $betaRoster){
		Clear-Content -Path $betaRoster
	}
	$roster = Get-Content -Encoding ASCII -Path "D:\Users\cad\Documents\ShifTracker\ATCapp_Rosters_new.txt" 

	$month = $null
	$notes = @{}
	Foreach ($line in $roster){
		if($line -match 'Roster:(.+?);'){

			# Empty line
			write-debug
			
			# Roster month line
			$month = $Matches[1]
			
			# Clear notes
			$notes.clear()
			
			# Read monthly notes
			write-debug "Reading $($month) Notes"
			$ATCO = "D:\Users\cad\Documents\ShifTracker\$($month)ATCO.txt"
			
			$hasNoteFile = $False
			if (Test-Path $ATCO){
				$hasNoteFile = $True
				$notefile = Get-Content -Path $ATCO
			
				# Read notes into hashtable
				Foreach ($noteEntry in $notefile){
					$sp = ($noteEntry -replace ';(?!$)',';- ').Split(";",2,[System.StringSplitOptions]::RemoveEmptyEntries)
					$notes[$sp[0]] += "$($sp[1]);"
				}
				
				write-debug "Processing $($month)"
			}else{
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
		
		Add-Content -Encoding ASCII -Path $betaRoster -Value $line
	}
}