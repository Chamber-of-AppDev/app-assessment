$folder = "C:\SizingAssessment\iis\"
$taskName = "IIS App Pool Analyzer"

Stop-ScheduledTask -TaskName $taskName
Unregister-ScheduledTask -TaskName $taskName
rm $folder -Recurse -Force
