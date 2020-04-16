$subcription = ""
az account set -s  $subcription
$apps = az functionapp list --query "[].{name:name,resourcegroup: resourceGroup }" -o tsv
cls
  
 foreach ($app in $apps) {
   $appInfo = $app -split "`t"
   $appName = $appInfo[0]
   $rg = $appInfo[1]
   $environments = az webapp deployment slot list --name $appName --resource-group $rg --query "[].{name:name}" -o tsv
   $environmentsArr = $environments -split "`t"
    foreach ($e in $environmentsArr) {
            #appSettings
            $appsettings = az functionapp config appsettings list -s $e --name $appName --resource-group $rg --query "[].{name:name,value: value}" -o tsv
            foreach ($as in $appsettings) {
                $appInfo = $as -split "`t"
                $setting = $appInfo[0]
                $value = $appInfo[1]
                #$value
                if ($value.ToLower() -Match "server=") {
                    $sb = New-Object System.Data.Common.DbConnectionStringBuilder

                    # Attempting to set the ConnectionString property directly won't work, see below
                    $sb.set_ConnectionString($value)
                    $val = $sb.Values -join ";"
                    "appSetting;$e;$appName; $rg; $setting; $val"
                }
            }
            
            #connectionstring
            $connectionStringArr = az webapp config connection-string list --name $appName --resource-group $rg -s $e --query "[].{name:name,value: value.value}" -o tsv
            foreach ($cs in $connectionStringArr) {
                $csSplit = $cs -split "`t"
                $csName = $csSplit[0]
                $csString = $csSplit[1]
                $sb = New-Object System.Data.Common.DbConnectionStringBuilder

                # Attempting to set the ConnectionString property directly won't work, see below
                $sb.set_ConnectionString($csString)
                $val = $sb.Values -join ";"
                "connectionstring;$e;$appName; $rg; $csName; $val"
            }
    }
 }