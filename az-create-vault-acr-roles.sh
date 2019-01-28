RES_GROUP=my_res_group # Resource Group name
ACR_NAME=my_acr_name       # Azure Container Registry registry name
AKV_NAME=my_new_az_vault_name       # Azure Key Vault vault name

set -x
set -e

az keyvault create -g $RES_GROUP -n $AKV_NAME

## Service principal for azure registry with role reader (use in docker swarm)
az keyvault secret set \
  --vault-name $AKV_NAME \
  --name $ACR_NAME-reader-pwd \
  --value $(az ad sp create-for-rbac \
                --name $ACR_NAME-reader \
                --scopes $(az acr show --name $ACR_NAME --query id --output tsv) \
                --role reader \
                --query password \
                --output tsv)

az keyvault secret set \
    --vault-name $AKV_NAME \
    --name $ACR_NAME-reader-usr \
    --value $(az ad sp show --id http://$ACR_NAME-reader --query appId --output tsv)

# ## Service principal for azure registry with role contributor (use in ci system)
az keyvault secret set \
  --vault-name $AKV_NAME \
  --name $ACR_NAME-contributor-pwd \
  --value $(az ad sp create-for-rbac \
                --name $ACR_NAME-contributor \
                --scopes $(az acr show --name $ACR_NAME --query id --output tsv) \
                --role contributor \
                --query password \
                --output tsv)

az keyvault secret set \
    --vault-name $AKV_NAME \
    --name $ACR_NAME-contributor-usr \
    --value $(az ad sp show --id http://$ACR_NAME-contributor --query appId --output tsv)
