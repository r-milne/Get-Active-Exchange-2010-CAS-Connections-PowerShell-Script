# Get Active Exchange 2010 CAS Connections PowerShell Script
 Get Active Exchange 2010 CAS Connections PowerShell Script

.SYNOPSIS
Purpose of this script is to report on  particular performance monitor counters for Outlook RPC Client Access, OWA and Exchange ActiveSync on multiple servers

 

For more details please also see this post:
https://blog.rmilne.ca/2014/12/17/powershell-script-to-get-exchange-2010-active-cas-connections/

 

.DESCRIPTION

Script was initially created to easily show the number of connected users to each Exchange 2010 CAS. 
    
This was due to inequitable Load Balancer disctribution, and needed a way to quickly report on how Exchange saw the traffic, and how the traffic was distributed. 
 
Script will report to the screen the number of connectionss.  If required you can modify to output to a  CSV using standard methods. 

Uses Write-Progress to indicate the duration taken. 

Note that for EAS there is the requests/sec counter that is used. 

 

.ASSUMPTIONS

Script is being executed with sufficient permissions to retrieve perfmon counters on the server(s) targeted.

You can live with the Write-Host cmdlets :)

You can add your error handling if you need it. 

 

.VERSION

 
2.0  4-12-2014 -- Initial script released to the scripting gallery

3.0 20-1-2015 -- Updated script to include POP and IMAP counters

4.0 11-8-2015 -- Updated to handle errors when POP and IMAP not enabled

5.0 4-10-2016 -- Added Web Services to output as Adam was too lazy to do it himself

6.0 20-2-2019 -- Added Outlook Anywhere counters -- requested by Bruce from the Peg.

 

.Disclaimer
   
This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment. 
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE. 
We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code,
provided that You agree:
(i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded;
(ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
Please note: None of the conditions outlined in the disclaimer above will supercede the terms and conditions contained within the Premier Customer Services Description.
This posting is provided "AS IS" with no warranties, and confers no rights.

Use of included script samples are subject to the terms specified at http://www.microsoft.com/info/cpyright.htm.
