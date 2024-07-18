using './main.bicep'

param environmentName = readEnvironmentVariable('AZURE_ENV_NAME', 'MY_ENV')

param location = readEnvironmentVariable('AZURE_LOCATION', 'eastus')

param principalId = readEnvironmentVariable('AZURE_PRINCIPAL_ID', '')
param principalType = readEnvironmentVariable('AZURE_PRINCIPAL_TYPE', 'ServicePrincipal')

param aiHubName = readEnvironmentVariable('AZUREAI_HUB_NAME', '')
param aiProjectName = readEnvironmentVariable('AZUREAI_PROJECT_NAME', '') 
param appInsightsName = readEnvironmentVariable('AZURE_APP_INSIGHTS_NAME', '')
param appServiceName = readEnvironmentVariable('AZURE_APP_SERVICE_NAME', '')
param appServicePlanName = readEnvironmentVariable('AZURE_APP_SERVICE_PLAN_NAME', '')
param containerRegistryName = readEnvironmentVariable('AZURE_CONTAINER_REGISTRY_NAME', '')
param containerRepositoryName = readEnvironmentVariable('AZURE_CONTAINER_REPOSITORY_NAME', '')
param keyVaultName = readEnvironmentVariable('AZURE_KEY_VAULT_NAME', '')
param logAnalyticsName = readEnvironmentVariable('AZURE_LOG_ANALYTICS_NAME', '')
param openAiName = readEnvironmentVariable('AZURE_OPENAI_NAME', '')
param searchServiceName = readEnvironmentVariable('AZURE_SEARCH_NAME', '')
param storageAccountName = readEnvironmentVariable('AZURE_STORAGE_ACCOUNT_NAME', '')
param azureSearchIndexSampleData = readEnvironmentVariable('AZURE_SEARCH_INDEX_SAMPLE_DATA', '')
