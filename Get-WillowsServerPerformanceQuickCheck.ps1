[cmdletbinding()]
PARAM(
    [Parameter(Mandatory= $false,ValueFromPipelineByPropertyName= $true)]$ComputerName = $env:COMPUTERNAME
    ,[Parameter(Mandatory= $false,ValueFromPipelineByPropertyName= $true)][ValidateSet("Little","Some","Lots")]$HowMuchDetail = 'Little'
    ,[switch]$OutputAsObjects
)

$allOutput = @();

#region Memory Usage
$CimInstanceComputerName = if ($ComputerName -like $env:COMPUTERNAME) {$null} else {$ComputerName};
$CimInstance = Get-CimInstance Win32_OperatingSystem -ComputerName $CimInstanceComputerName;
$memOutput = $CimInstance | Select-Object CSName,
    @{name="FreeMemPct";expression={[math]::Round($_.FreePhysicalMemory / $_.TotalVisibleMemorySize * 100,2)}},
    @{name="FreeMemGbs";expression={[math]::Round($_.FreePhysicalMemory / 1mb,2)}},
    @{name="TotalPhysMemGbs";expression={[math]::Round($_.TotalVisibleMemorySize / 1mb,2)}};
if ($OutputAsObjects.IsPresent) {$allOutput += [PSCustomObject]@{memoryOutput=$memOutput};}
else { $memOutput | Format-Table -Autosize;}
#endregion Memory Usage

#region Top Processes (grouped) by Memory Usage
if ($HowMuchDetail -ne 'Little') {
    $HowMany = if ($HowMuchDetail -eq 'Some') {4} else {100};
    $groups = Get-Process -ComputerName $ComputerName | Group-Object ProcessName;
    $procMemOutput = $groups | Foreach-Object {
        $agg = $_.group | Measure-Object ws -Sum;
        $_ | Select-Object @{name="ProcessName";expression={$_.Name}}, @{name="ProcessCount";expression={$agg.Count}}, @{name="TotalWorkingMemorySetGbs";expression={[math]::Round( $agg.Sum / 1gb , 2 )}}, @{name="TotalWorkingMemorySet";expression={$agg.Sum}}, @{name="PctOfTotalVisibleMemory";expression={[math]::Round( $( $agg.Sum / 1kb ) / $CimInstance.TotalVisibleMemorySize * 100 , 2 )}}
    } | Sort-Object TotalWorkingMemorySet -Descending | Select-Object  ProcessName, ProcessCount, TotalWorkingMemorySetGbs, PctOfTotalVisibleMemory -First $HowMany;
    if ($OutputAsObjects.IsPresent) {$allOutput += [PSCustomObject]@{processMemoryOutput=$procMemOutput};}
    else { $procMemOutput | Format-Table -Autosize;}

}
#endregion Top Processes by Memory Usage

#region Processor Load
$processors = Get-WmiObject -ComputerName $ComputerName -Class win32_processor;
$procLoadOutput = if ($HowMuchDetail -eq 'Little') {
    $processors | Measure-Object LoadPercentage -Average | Select-Object @{name='ProcessorCount';expression={$_.Count}}, @{name='ProcessorLoadAverage';expression={$_.Average}}
} else {
    $processors | Select-Object DeviceID, LoadPercentage;
};
if ($OutputAsObjects.IsPresent) {$allOutput += [PSCustomObject]@{processLoadOutput=$procLoadOutput};}
else { $procLoadOutput | Format-Table -Autosize;}
#endregion Processor Load

if ($OutputAsObjects.IsPresent) {$allOutput;}
