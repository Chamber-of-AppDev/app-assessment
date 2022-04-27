$folder = "C:\SizingAssessment\iis\"
$csvFile = "out.csv"
$scriptFile = "app-pool-analyzer.ps1"

if (!(Test-Path $folder))
{
    mkdir $folder
}


if (!(Test-Path ($folder + $csvFile)))
{
   New-Item  ($folder + $csvFile) -type "file"
}

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Chamber-of-AppDev/app-assessment/main/iis/app-pool-analyzer.ps1" -OutFile ($folder + $scriptFile)

$taskAction = New-ScheduledTaskAction -Execute "powershell.exe"  -Argument ("-File " + ($folder + $scriptFile))
$taskName = "IIS App Pool Analyzer"
$taskTrigger = New-ScheduledTaskTrigger -AtStartup 
$taskPrincipal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$everyMinute = New-TimeSpan -Minutes 1
$nolimit = New-TimeSpan -Minutes 0
$taskSettings = New-ScheduledTaskSettingsSet `
    -MultipleInstances IgnoreNew `
    -RestartInterval $everyMinute `
    -RestartCount 999 `
    -Priority 0 `
    -ExecutionTimeLimit $nolimit `
    -StartWhenAvailable `
    -DisallowHardTerminate

$taskAction

Register-ScheduledTask `
    -TaskName $taskName `
    -Action $taskAction `
    -Trigger $taskTrigger `
    -Description $taskName `
    -Principal $taskPrincipal `
    -Settings $taskSettings `
    -Force `
    -AsJob


Get-ScheduledTaskInfo -TaskName $taskName

Start-ScheduledTask -TaskName $taskName
