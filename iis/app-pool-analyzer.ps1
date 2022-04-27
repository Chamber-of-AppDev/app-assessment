# Requires IIS and admin

$frequencyInSeconds = 30
$outputFile = "C:\SizingAssessment\iis\out.csv"

$properties=@(
    @{Name="App Pool"; Expression = {$pool.AppPool}},
    @{Name="Date"; Expression = {Get-Date -Format "yyyyMMdd-HHmmss"}},
    @{Name="PID"; Expression = {$_.IDProcess}},
    @{Name="CPU (%)"; Expression = {$_.PercentProcessorTime}},
    @{Name="Memory (MB)"; Expression = {[Math]::Round(($_.workingSetPrivate / 1mb),2)}}
    @{Name="I/O (MB/Sec)"; Expression = {[Math]::Round(($_.IODataOperationsPersec / 1mb),2)}}
)

while($true) {

    $pools = Get-WmiObject -Class Win32_Process -Filter "name='w3wp.exe'" | Select-Object -Property Name, ProcessId, @{Name="AppPool";Expression={$_.GetOwner().user}} 
    foreach ($pool in $pools){

        $processID = $pool.ProcessID

        $result = (Get-WmiObject -class Win32_PerfFormattedData_PerfProc_Process |
            Where-Object {$_.IDProcess -eq $processID } | 
            Select-Object $properties | Format-Table -HideTableHeaders | Out-String).Trim() 
        $result >> $outputFile
        $result 
    }

    Start-Sleep -Seconds $frequencyInSeconds 
}
