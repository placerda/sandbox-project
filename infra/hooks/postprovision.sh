#!/bin/bash

# Check if running in GitHub Workspace
if [ -z "$GITHUB_WORKSPACE" ]; then
    # The GITHUB_WORKSPACE is not set, meaning this is not running in a GitHub Action
    echo "GITHUB_WORKSPACE is not set. Running outside of GitHub Actions."
    DIR=$(dirname "$(realpath "$0")")
    echo "Executing login script at $DIR/login.sh"
    "$DIR/login.sh"
else
    echo "GITHUB_WORKSPACE is set. Running inside GitHub Actions."
fi

# Retrieve service names, resource group name, and other values from environment variables
resourceGroupName=$AZURE_RESOURCE_GROUP
searchService=$AZURE_SEARCH_NAME
openAiService=$AZURE_OPENAI_NAME
subscriptionId=$AZURE_SUBSCRIPTION_ID
mlProjectName=$AZUREAI_PROJECT_NAME
echo AZURE_SEARCH_INDEX_SAMPLE_DATA is $AZURE_SEARCH_INDEX_SAMPLE_DATA
indexSampleData=$([ -z "$AZURE_SEARCH_INDEX_SAMPLE_DATA" ] || [ "$AZURE_SEARCH_INDEX_SAMPLE_DATA" == "true" ] && echo true || echo false)
echo indexSampleData=$indexSampleData

# Ensure all required environment variables are set
if [ -z "$resourceGroupName" ] || [ -z "$searchService" ] || [ -z "$openAiService" ] || [ -z "$subscriptionId" ] || [ -z "$mlProjectName" ]; then
    echo "One or more required environment variables are not set."
    echo "Ensure that AZURE_RESOURCE_GROUP, AZURE_SEARCH_NAME, AZURE_OPENAI_NAME, AZURE_SUBSCRIPTION_ID, and AZUREAI_PROJECT_NAME are set."
    exit 1
fi

# Environment variables expected by app
echo "AZURE_OPENAI_API_VERSION: $AZURE_OPENAI_API_VERSION"
echo "AZURE_OPENAI_CHAT_DEPLOYMENT: $AZURE_OPENAI_CHAT_DEPLOYMENT"
echo "AZURE_SEARCH_ENDPOINT: $AZURE_SEARCH_ENDPOINT"

# Output environment variables to .env file using azd env get-values
azd env get-values >.env

# Create config.json with required Azure AI project config information
echo "{\"subscription_id\": \"$subscriptionId\", \"resource_group\": \"$resourceGroupName\", \"workspace_name\": \"$mlProjectName\"}" > config.json

echo "--- ✅ | 1. Post-provisioning - env configured ---"

if [ $indexSampleData = "true" ]; then

    # Setup to run notebooks
    echo 'Installing dependencies from "requirements.txt"'
    pip cache purge > /dev/null
    pip install --upgrade pip setuptools > /dev/null
    python -m pip install -r requirements.txt > /dev/null

    echo "Populating sample data ...."
    python data/sample-documents-indexing.py > /dev/null

    echo "--- ✅ | 2. Post-provisioning - populated data ---"

    # echo "Install ipython and ipykernel"
    # python -m pip install ipython ipykernel > /dev/null
    # echo "Configure the IPython kernel"
    # ipython kernel install --name=python3 --user > /dev/null
    # echo "Verify kernelspec list isn't empty"
    # jupyter kernelspec list > /dev/null
    # echo "--- ✅ | 2. Post-provisioning - ready execute notebooks ---"

    # echo "Populating sample data ...."
    # jupyter nbconvert --execute --to python --ExecutePreprocessor.timeout=-1 data/sample-documents-indexing.ipynb > /dev/null
    # echo "--- ✅ | 3. Post-provisioning - populated data ---"
fi