$SFbody = @{
  
    grant_type="password" 
    client_id=$SFclient_Id
    client_secret=$SFclient_sercret
    redirect_uri=$SFcallback
    username = $username
    password = [String]::Concat($password + $securityToken)


    }



    $SFauth = (Invoke-RestMethod -Method Post -uri ($SFbaseURI + $tokenPath) -body $SFbody)
    $SFinstance = $SFauth.instance_url
    $SFtoken = $SFauth.access_token

    $SFheader = @{

    Authorization = "Bearer " + $SFtoken

    } 

    $SFaddheader = @{

    Authorization = "Bearer " + $SFtoken
    'Content-Type' = "application/json"

    } 
    $SFdata = Invoke-RestMethod -method GET -uri ($SFinstance + $SFAPIURI) -Headers $SFheader