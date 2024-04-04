# Quick Check On Server Performance
How much memory is free on the server? What's gobbling it up? Are the CPUs maxed out? But make it PowerShell.

## Why?
I could open a monitoring app, but then I'd have to leave the command line, and it's cozy here.

## How?
Run the script - it's all Windows PowerShell built-in stuff. Specify nothing for a local check, or a computer name for a remote one.

```powershell
. .\Get-WillowsServerPerformanceQuickCheck.ps1
. .\Get-WillowsServerPerformanceQuickCheck.ps1 -HowMuchDetail Some
. .\Get-WillowsServerPerformanceQuickCheck.ps1 -HowMuchDetail Some -ComputerName on.my.network.com
$firstTime = . .\Get-WillowsServerPerformanceQuickCheck.ps1 -HowMuchDetail Some -ComputerName on.my.network.com -OutputAsObjects;
<#
Look, I don't like bouncing SQL servers as my first step in performance tuning.
But if your monitoring tool is this script, I think we both know what your company spent on infrastructure.
#>
#Restart-Computer -ComputerName on.my.network.com;
$secondTime = . .\Get-WillowsServerPerformanceQuickCheck.ps1 -HowMuchDetail Some -ComputerName on.my.network.com -OutputAsObjects;

$firstTime.memoryOutput ;
$firstTime.processMemoryOutput ;
$firstTime.ProcessLoadOutput ;

$secondTime.memoryOutput ;
$secondTime.processMemoryOutput ;
$secondTime.ProcessLoadOutput ;

<#
Then eyeball check them.
#>

```
