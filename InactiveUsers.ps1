# Last Sign In Date and Time for All Users: In this scenario, you request a list of all users, and the last lastSignInDateTime for each respective user: https://graph.microsoft.com/beta/users?$select=displayName,signInActivity

#


$clientID       = '97XX'    #  <-insert your own app ID here
$clientSecret   = 'yXX'      #  <-insert your own secret here
$tenantDomain   = 'sda'             #  <-insert your own tenant id here


$PastDate = (Get-Date).AddDays(-60).Date
$Date = Get-Date $PastDate -Format "yyyy-MM-ddTHH:mm:ssZ"

$loginURL       = 'https://login.microsoft.com'
$resource       = 'https://graph.microsoft.com'
$body       = @{grant_type="client_credentials";resource=$resource;client_id=$ClientID;client_secret=$ClientSecret}
$oauth      = Invoke-RestMethod -Method Post -Uri $loginURL/$tenantdomain/oauth2/token?api-version=1.0 -Body $body
$headerParams = @{'Authorization'="$($oauth.token_type) $($oauth.access_token)"}
 
#_______________________________________________________________________________________________
 
$InactiveDetections = @()

$url = "https://graph.microsoft.com/beta/users?filter=signInActivity/lastSignInDateTime le $date & select=displayName,userPrincipalName,userType,signInActivity"
 
While ($null -ne $url) {
    $data = (Invoke-WebRequest -Headers $headerParams -Uri $url) | ConvertFrom-Json
    $InactiveDetections += $data.Value
    $url = $data.'@Odata.NextLink'
}

$InactiveDetections 