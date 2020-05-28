<# 

.SYNOPSIS
	Purpose of this script is to report on  particular performance monitor counters for Outlook RPC Client Access, OWA and Exchange ActiveSync on multiple servers

.DESCRIPTION
	Script was initially created to easily show the number of connected users to each Exchange 2010 CAS. 
    
    This was due to inequitable Load Balancer disctribution, and needed a way to quickly report on how Exchange saw the traffic, and how the traffic was distributed.  
	
	Script will report to the screen the number of connections.  If required you can modify to output to a  CSV using standard methods.  

    Uses Write-Progress to indicate the duration taken.  

    Note that for EAS there is the requests/sec counter that is used.  

    Note that the counters are reversed for POP and IMAP for some reason....
    IMAP is "Current Connections"
    POP  is "Connections Current"

    If the IMAP and POP services are not running, script should continue.  The values reported will be zero.  



.ASSUMPTIONS
	Script is being executed with sufficient permissions to retrieve perfmon counters on the server(s) targeted. 

	You can live with the Write-Host cmdlets :) 

	You can add your error handling if you need it.   

	

.VERSION
  
	2.0  	4-12-2014 -- Initial script released to the scripting gallery 
	3.0	20-1-2015 -- Added POP & IMAP Counters due to customer feedback
	4.0	11-8-2015 -- Edited to remove warnings/errors if POP or IMAP not enabled
	5.0 	4-10-2016 -- Added EWS and Web Services counters for Adam as he was too lazy to do it himself.  Added Blurb to output to explain counters a little. 
	6.0	20-2-2019 -- Added Outlook Anywhere counters -- requested by Bruce from the Peg.

    
This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code, 
provided that You agree: 
(i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; 
(ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and 
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys� fees, that arise or result from the use or distribution of the Sample Code.
Please note: None of the conditions out lined in the disclaimer above will supercede the terms and conditions contained within the Premier Customer Services Description.
This posting is provided "AS IS" with no warranties, and confers no rights. 

Use of included script samples are subject to the terms specified at http://www.microsoft.com/info/cpyright.htm.

#>

# Script was intended to dynamically query for Exchange CAS 2010 servers.  The server input can be altered to suit your particular taste and/or requirements
# For example the below line can be remmed out, and you can use Import-CSV or Get-Content to feed in a list of names.....
#
# An example of Get-Content would be:
# $ExchangeServers = Get-Content  "C:\Scripts\ServerList.txt"

# The blurb is displayed to provide a precis of each reported value 
$Blurb = "Counters retrieved are: `n`tRPC  = RPC Client Access Connections `n`tOA   = Current Unique Outlook Anywhere users `n`tOWA  = Current Unique OWA users `n`tEAS  = EAS Requests/Sec `n`tIMAP = IMAP Total Connections  `n`tPOP  = POP Connections Current `n`tWSR  = Exchange Web Services Requests/Sec `n`tWST  = Web Service (IIS) Total Current Connections `n"

# All Exchange servers in the organisation are returned, sorted to meet my OCD personality issues and the Name property is then pipe to the ForEach-Obect to render it to a string
# This allows the input to be easily swapped to a CSV, TXT file or just a list of servers in a string.....


# Declare an empty array to hold the output
$Output = @()

# Declare a custom PS object. This is the template that will be copied multiple times. 
# This is used to allow easy manipulation of data from potentially different sources 
$TemplateObject = New-Object PSObject | Select ServerName, RPC, OA, OWA, EAS, IMAP, POP, WSR, WST 

# Get a list of Exchange 2010 CAS servers.  Sort this based on name to meet my OCD requirements...
# Can easily edit the query.
# 
# For more filtering examples see: 
# http://blogs.technet.com/b/rmilne/archive/2014/03/24/powershell-filtering-examples.aspx 
# 
$ExchangeServers = Get-ExchangeServer | Where-Object {$_.AdminDisplayVersion -match "^Version 14" -and $_.ServerRole -Match "ClientAccess" }  | Sort-Object  Name

# Use an array around the $Exchangeservers to work out the count.  Needed for later to display the progress bar
$ServerCount = @($ExchangeServers).count

# Write the description blurb to the screen
Write-Host $Blurb -ForeGroundColor Green

# Loop me baby! 
ForEach ($Server In $ExchangeServers)
{
    # Write a handy dandy progress bar to the screen so that we know how far along this is...
    # Increment the counter 
    $Int = $Int + 1
    # Work out the current percentage 
    $Percent = $Int/$ServerCount * 100
    # Write the progress bar out with the necessary verbiage....
    Write-Progress -Activity "Collecting server details" -Status "Processing server $Int of $ServerCount - $Server" -PercentComplete $Percent 

    # Make a copy of the TemplateObject.  Then work with the copy
    $WorkingObject = $TemplateObject | Select-Object * 
   
    # Write current activity to screen.  Avoid mushroom syndrome
    Write-Host "Processing $Int of $ServerCount -- $Server" -ForeGroundColor Magenta

    # Populate the TemplateObject with the necessary details.
    # Note that the perf counter data is an array so we pull out the first element's cooked value.  
    $WorkingObject.ServerName = $Server
    $WorkingObject.OA =  (Get-Counter "\RPC/HTTP Proxy\Current Number of Unique Users" -ComputerName $server.Name).CounterSamples[0].Cookedvalue 
    $WorkingObject.RPC = (Get-Counter "\MSExchange RpcClientAccess\User Count" -ComputerName $server.Name).CounterSamples[0].Cookedvalue 
    $WorkingObject.OWA = (Get-Counter "\MSExchange OWA\Current Unique Users"   -ComputerName $Server.Name).CounterSamples[0].Cookedvalue
    $WorkingObject.EAS = [math]::Truncate((Get-Counter "\MSExchange ActiveSync\Requests/sec" -ComputerName $Server.Name).CounterSamples[0].Cookedvalue)
   

    # Added POP3 and IMAP4 To Version 3.0 As requested
    # 
    # Check that we have valid IMAP data to work with before getting counter.
    If ((Get-Counter "\MSExchangeImap4(_total)\Current Connections" -WarningAction:silentlycontinue -ErrorAction:SilentlyContinue))
    {
    	$WorkingObject.IMAP = [math]::Truncate((Get-Counter "\MSExchangeImap4(_total)\Current Connections" -ComputerName $Server.Name).CounterSamples[0].Cookedvalue)
    }

    # Check that we have valid POP3 data to work with before getting counter.
    If ((Get-Counter "\MSExchangePOP3(_total)\Connections Current" -WarningAction:silentlycontinue -ErrorAction:SilentlyContinue))
    {
    	 $WorkingObject.POP  = [math]::Truncate((Get-Counter "\MSExchangePOP3(_total)\Connections Current"  -ComputerName $Server.Name).CounterSamples[0].Cookedvalue)
    }

    # Added the below for Web Services connections to Version 5 
    # WSR = Web Services Requests per second
    # WST = Web Services Total Current Connections 
    $WorkingObject.WSR = [math]::Truncate((Get-Counter "\MSExchangeWS\Requests/sec" -ComputerName $Server.Name).CounterSamples[0].Cookedvalue)
    $WorkingObject.WST = (Get-Counter "\Web Service(_Total)\Current Connections"    -ComputerName $Server.Name).CounterSamples[0].Cookedvalue



    # Display output to screen.  REM out if not required/wanted 
    $WorkingObject

    # Add current results to final output
    $Output += $WorkingObject

}    