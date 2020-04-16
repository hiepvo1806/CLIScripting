#az login
$subcription = ""
az account set -s  $subcription
cls
$keyVaults = az keyvault list --query "[].name" -o tsv

foreach ($keyvault in $keyVaults) {
    $allKeys = az keyvault secret list --vault-name $keyvault --query "[].name" -o tsv
    foreach ($secretName in $allKeys) {
       $secretValue =  az keyvault secret show -n $secretName --vault-name $keyvault --query "value" -o tsv
       #Write-Host "$keyvault;$secretName;$secretValue" -ForegroundColor white;


       if ($secretValue -And $secretValue.ToLower() -Match "server=") {
          $sb = New-Object System.Data.Common.DbConnectionStringBuilder

          # Attempting to set the ConnectionString property directly won't work, see below
          $sb.set_ConnectionString($secretValue)
          $val = $sb.Values -join ";"
          Write-Host "keyvault;$keyvault;$secretName;$val"  -ForegroundColor white
        }
    }
}







