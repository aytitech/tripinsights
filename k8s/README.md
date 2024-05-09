# Kubernetes

az aks get-credentials --name aks-ozozturk --resource-group sunexpress



az keyvault create --name kvozozturk --resource-group sunexpress --location westeurope --enable-rbac-authorization


az keyvault secret set --vault-name kvozozturk --name SQLUSER --value azureadmin
az keyvault secret set --vault-name kvozozturk --name SQLPASSWORD --value 'qwq123AS!ozgur'
az keyvault secret set --vault-name kvozozturk --name SQLSERVER --value sozgur-sunexp-sql.database.windows.net
az keyvault secret set --vault-name kvozozturk --name SQLDBNAME --value mydrivingDB




az aks show -g sunexpress -n aks-ozozturk --query addonProfiles.azureKeyvaultSecretsProvider.identity.objectId -o tsv
az aks show -g sunexpress -n aks-ozozturk --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId -o tsv



objectId: 17fa27a0-ab90-476e-b6de-08141f982b4e
clientId: 459eb077-504e-4d21-93da-99551583d25f

az keyvault set-policy --name kvozozturk --key-permissions get --object-id 17fa27a0-ab90-476e-b6de-08141f982b4e


export KEYVAULT_SCOPE=$(az keyvault show --name kvozozturk --query id -o tsv)

az role assignment create --role "Key Vault Certificate User" --assignee 459eb077-504e-4d21-93da-99551583d25f --scope $KEYVAULT_SCOPE



kubectl create namespace api

    

https://learn.microsoft.com/en-us/azure/aks/app-routing?tabs=default%2Cdeploy-app-default