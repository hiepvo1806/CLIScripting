$subcription = ""
az account set -s  $subcription
$apps = az webapp list --query "[].{name:name,resourcegroup: resourceGroup }" -o tsv
cls
  
 foreach ($app in $apps) {
   $appInfo = $app -split "`t"
   $appName = $appInfo[0]
   $rg = $appInfo[1]
   $environments = az webapp deployment slot list --name $appName --resource-group $rg --query "[].{name:name}" -o tsv
   $environmentsArr = $environments -split "`t"
    foreach ($e in $environmentsArr) {
        $connectionStringArr = az webapp config connection-string list -n $appName --resource-group $rg -s $e --query "[].{name:name,value: value.value}" -o tsv
        foreach ($cs in $connectionStringArr) {
        $csSplit = $cs -split "`t"
        $csName = $csSplit[0]
        $csString = $csSplit[1]
        $sb = New-Object System.Data.Common.DbConnectionStringBuilder

        # Attempting to set the ConnectionString property directly won't work, see below
        $sb.set_ConnectionString($csString)
        $val = $sb.Values -join ";"
        "$appName; $rg;$e; $csName; $val"
       }
    }
 }