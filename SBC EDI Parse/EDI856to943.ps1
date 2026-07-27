# Initialize Regex patterns for various EDI segments
$ISARegex = [System.Text.RegularExpressions.Regex]::new("(?<ISA>ISA)(?<Separator>\*{1})(?<ISA01>[^*]{2})\k<Separator>(?<ISA02>[^*]{10})\k<Separator>(?<ISA03>[^*]{2})\k<Separator>(?<ISA04>[^*]{10})\k<Separator>(?<ISASenderQualifer>[^*]{2})\k<Separator>(?<ISASender>[^*]{15})\k<Separator>(?<ISAReceiverQualifer>[^*]{2})\k<Separator>(?<ISAReceiver>[^*]{15})\k<Separator>(?<ISADate>[^*]{6})\k<Separator>(?<ISA10>[^*]{4})\k<Separator>(?<ISA11>[^*]{1})\k<Separator>(?<ISAVersion>[^*]{5})\k<Separator>(?<ISA13>[^*]{9})\k<Separator>(?<ISA14>[^*]{1})\k<Separator>(?<ISATestQualifier>[^*]{1})\k<Separator>")
$GSRegex = [System.Text.RegularExpressions.Regex]::new("(?<=\~)(?<GS>GS)(?<Separator>\*{1})(?<GS01>[^*]{2})\k<Separator>(?<GSSender>[^*]{1,15})\k<Separator>(?<GSReceiver>[^*]{1,15})\k<Separator>")
$STRegex = [System.Text.RegularExpressions.Regex]::new("(?<=ST\*)856(?=\*)")
<#$BSNRegex = [System.Text.RegularExpressions.Regex]::new('(?<=\~)BSN')
$DTMRegex = [System.Text.RegularExpressions.Regex]::new('(?<=\~)DTM')
$LINRegex = [System.Text.RegularExpressions.Regex]::new('(?<=\~)LIN')
$SN1Regex = [System.Text.RegularExpressions.Regex]::new('(?<=\~)SN1')
$CTTRegex = [System.Text.RegularExpressions.Regex]::new('(?<=\~)CTT')#>
$TestRegex = [System.Text.RegularExpressions.Regex]::new('(TST|TEST)')

# Initialize directories and other constants
$UnileverArchive = [System.IO.DirectoryInfo]::new('C:\LexiCom\inbox\Unilever\Archive')
$FileContentDirectory = [System.IO.DirectoryInfo]::new("C:\LexiCom\inbox\Unilever\To ODW")
$SuaveInboundArchiveDirectory = [System.IO.DirectoryInfo]::new("C:\LexiCom\inbox\Unilever\To ODW\Archive")
$ODWOutboundDirectory = [System.IO.DirectoryInfo]::new('C:\LexiCom\outbox\ODW')

$TestTransmission = $false
$TestQualifer = 'T'
$ProductionQualifer = 'P'
$ISATestQualifier = $ProductionQualifer
if ($TestTransmission) { $ISATestQualifier = $TestQualifer }
$ODWReceiveQualifier = '12'
$ODWID = '6148812966'
$ODWReceiver = $ODWID.trim().PadRight(15, ' ')

# Process each file in the directory
$LastFileWriteTime = $SuaveInboundArchiveDirectory.GetFiles('*', [System.IO.SearchOption]::TopDirectoryOnly) | Sort-Object -Property LastWriteTime -Descending | Select-Object -first 1 | Select-Object -ExpandProperty LastWriteTime 
#$FileContentDirectory.GetFiles('*', [System.IO.SearchOption]::TopDirectoryOnly).Where{$_.LastWriteTime -ge $LastFileWriteTime}.ForEach{
$UnileverArchive.GetFiles('*', [System.IO.SearchOption]::TopDirectoryOnly).Where{ $_.LastWriteTime -ge $LastFileWriteTime }.ForEach{
    [System.IO.FileInfo]$currentFile = $_
    # Write the updated content to a new file and move the original to the archive
    $outputPath = [System.IO.Path]::Combine($ODWOutboundDirectory.FullName, $currentFile.Name)
    $archivePath = [System.IO.Path]::Combine($SuaveInboundArchiveDirectory.FullName, $currentFile.Name)
    $fileExists = ([System.IO.FileInfo]::new($archivePath)).Exists
 
    if (-not $fileExists) { 
        
        try {
            # Read the content of the current file
            $fileContent = [System.IO.File]::ReadAllText($currentFile.FullName)

            # Check if the file is an 856 based on the ST segment
            if ($STRegex.IsMatch($fileContent)) {
                $result = $ISARegex.Match($fileContent)
                $separator = $result.Groups["Separator"].Value
                $isaSender = $result.Groups["ISAReceiver"].Value
                if (-not $TestTransmission) { $isaSender = $TestRegex.Replace($isaSender, '').trim().PadRight(15, ' ') }
                # Build the new ISA segment using StringBuilder
                $isaStringBuilder = [System.Text.StringBuilder]::new()
                $isaStringBuilder.Append($result.Groups["ISA"].Value) > $null
                $isaStringBuilder.Append($separator) > $null
                $isaStringBuilder.Append($result.Groups["ISA01"].Value) > $null
                $isaStringBuilder.Append($separator) > $null
                $isaStringBuilder.Append($result.Groups["ISA02"].Value) > $null
                $isaStringBuilder.Append($separator) > $null
                $isaStringBuilder.Append($result.Groups["ISA03"].Value) > $null
                $isaStringBuilder.Append($separator) > $null
                $isaStringBuilder.Append($result.Groups["ISA04"].Value) > $null
                $isaStringBuilder.Append($separator) > $null
                $isaStringBuilder.Append($result.Groups["ISAReceiverQualifer"].Value) > $null
                $isaStringBuilder.Append($separator) > $null
                $isaStringBuilder.Append($isaSender) > $null
                $isaStringBuilder.Append($separator) > $null
                # $isaStringBuilder.Append($result.Groups["ISAReceiverQualifer"].Value) > $null
                # $isaStringBuilder.Append($separator) > $null
                # $isaStringBuilder.Append($result.Groups["ISAReceiver"].Value) > $null
                # $isaStringBuilder.Append($separator) > $null
                $isaStringBuilder.Append($ODWReceiveQualifier) > $null
                $isaStringBuilder.Append($separator) > $null
                $isaStringBuilder.Append($ODWReceiver) > $null
                $isaStringBuilder.Append($separator) > $null
                $isaStringBuilder.Append($result.Groups["ISADate"].Value) > $null
                $isaStringBuilder.Append($separator) > $null
                $isaStringBuilder.Append($result.Groups["ISA10"].Value) > $null
                $isaStringBuilder.Append($separator) > $null
                $isaStringBuilder.Append($result.Groups["ISA11"].Value) > $null
                $isaStringBuilder.Append($separator) > $null
                $isaStringBuilder.Append($result.Groups["ISAVersion"].Value) > $null
                $isaStringBuilder.Append($separator) > $null
                $isaStringBuilder.Append($result.Groups["ISA13"].Value) > $null
                $isaStringBuilder.Append($separator) > $null
                $isaStringBuilder.Append($result.Groups["ISA14"].Value) > $null
                $isaStringBuilder.Append($separator) > $null
                $isaStringBuilder.Append($ISATestQualifier) > $null
                $isaStringBuilder.Append($separator) > $null
            
                # Update the content with new ISA and other segments
                $updatedFileContent = $ISARegex.Replace($fileContent, $isaStringBuilder.ToString())
            
                #Update the GS Segment
                $gsResult = $GSRegex.Match($updatedFileContent)
                $gsSender = $gsResult.Groups["GSReceiver"].Value
                $gsStringBuilder = [System.Text.StringBuilder]::new()
                $gsStringBuilder.Append($gsResult.Groups["GS"].Value) > $null
                $gsStringBuilder.Append($separator) > $null
                $gsStringBuilder.Append($gsResult.Groups["GS01"].Value) > $null
                $gsStringBuilder.Append($separator) > $null
                $gsStringBuilder.Append($gsSender) > $null
                $gsStringBuilder.Append($separator) > $null
                $gsStringBuilder.Append($ODWID) > $null
                $gsStringBuilder.Append($separator) > $null
                $updatedFileContent = $GSRegex.Replace($updatedFileContent, $gsStringBuilder.ToString())
                #$updatedFileContent = $STRegex.Replace($updatedFileContent, '943')
                <#$UpdatedFileContent = $STRegex.Replace($UpdatedFileContent, '943')
            $UpdatedFileContent = $BSNRegex.Replace($UpdatedFileContent, 'W06') 
            $UpdatedFileContent = $DTMRegex.Replace($UpdatedFileContent, 'G62')
            $UpdatedFileContent = $LINRegex.Replace($UpdatedFileContent, 'W12')
            $UpdatedFileContent = $SN1Regex.Replace($UpdatedFileContent, 'W12')
            $UpdatedFileContent = $CTTRegex.Replace($UpdatedFileContent, 'W27')#>


                [System.IO.File]::WriteAllText($outputPath, $updatedFileContent)
                [System.IO.File]::Copy($currentFile.FullName, $archivePath)
            }
        }
        catch {
            Write-Host "An error occurred: $_"
        }
    }
}
