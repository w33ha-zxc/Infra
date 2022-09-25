# Author - Sahil Sinha
# Last Updated by - Sahil Sinha
# Created on - 07/07/2022
# Last Updated - 14/07/2022
# Version - 1.3
# See API Documentation from Fortinet for Encrypting Backups
# Changelog - 
    #1.3 - Added feature for Encrypted Backups
    #1.2 - Purge Policy
    #1.1 - Webhook Implementation for Teams

#Importing the API Authentication CSV File
$Creds = Import-Csv .\SampleToken.csv -Header "Location","IP","Port","Token" -Delimiter ','
#$BackupPath = "C:\Users\SahilSinha\Desktop\"

ForEach ($Creds in $Creds) 
    {    
    $GetDate = Get-Date -UFormat "%Y-%m-%d_%H-%m-%S"
    $FileName = ($($Creds.Location) + $GetDate) + ".conf"
    $ResponseCode = (Test-NetConnection $($Creds.IP) -Port $($Creds.Port)).TcpTestSucceeded
    Write-Host $ResponseCode
    if ( $ResponseCode -eq "True" ) { 
        $F_URI =  "https://$($Creds.IP):$($Creds.Port)/api/v2/monitor/system/config/backup?scope=global&access_token=$($Creds.Token)"
        
        $Params = @{
            "URI"         = $F_URI
            "Method"      = 'GET'
            "ContentType" = 'application/json'  
        }
        Invoke-WebRequest -SkipCertificateCheck @Params -OutFile $Filename
        $Status = Write-Output "Config for the Firewall $($Creds.Location) $($Creds.IP) is downloaded successfully on the server $($env:computername) at the location $BackupPath..."
        $Output = "SUCCESS" 
    }
    else { 
        $Status = Write-Output "The Backup Failed at the server $($env:computername). Please check and validate the connectivity/credentials to the firewall." 
        $Output = "FAILURE" 
        }

    $URI = 'https://XXXX.webhook.office.com/webhookb2/46e8-ac94-ec3b4360a10c@f0b669c4-2198-4f68-9003-1f463c4b42c0/IncomingWebhook/9bdb7f961b644edd86d22c84da3bc0d9/86b0734d-4dfc-4d6b-9539-ea1528257cc9'

# @type - Must be set to `MessageCard`.
# @context - Must be set to [`https://schema.org/extensions`](<https://schema.org/extensions>).
# title - The title of the card, usually used to announce the card.
# text - The card's purpose and what it may be describing.
# activityTitle - The title of the section, such as "Test Section", displayed in bold.
# activitySubtitle - A descriptive subtitle underneath the title.
# activityText - A longer description that is usually used to describe more relevant data.

    $JSON = @{
        "@type"    = "MessageCard"
        "@context" = "<http://schema.org/extensions>"
        "title"    = 'Firewall Backups'
        "text"     = 'Checks the status of Backup Scripts across divisions'
        "sections" = @(
        @{
            "activityTitle"    =  "$($Creds.Location) - $($Output)"
            "activitySubtitle" =  $($Creds.IP) 
            "activityText"     =  $($Status)
        }
        )
        } | ConvertTo-JSON
  
        # You will always be sending content in via POST and using the ContentType of 'application/json'
        # The URI will be the URL that you previously retrieved when creating the webhook
        $Params = @{
            "URI"         = $URI
            "Method"      = 'POST'
            "Body"        = $JSON
            "ContentType" = 'application/json'
            }
  
    Invoke-RestMethod @Params
    }

#Delete files older than 6 months
#Get-ChildItem $BackupPath -Recurse -Force -ea 0 |Where-Object {!$_.PsIsContainer -and $_.LastWriteTime -lt (Get-Date).AddDays(-180)} |
#ForEach-Object {
#   $_ | Remove-Item -Force
#   $_.FullName | Out-File C:\Temp\deletedlog.txt -Append
#           }

