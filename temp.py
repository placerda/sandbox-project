import openai
from azure.identity import DefaultAzureCredential

# Set the API endpoint
openai.api_base = "https://oai0-rqftu7hlbj4he.openai.azure.com/"

# Use DefaultAzureCredential to authenticate with Azure
credential = DefaultAzureCredential()

# Set the API key (if needed, otherwise DefaultAzureCredential should handle it)
openai.api_key = "cd75c0cf492642849bca4bcadaf00e6a"

# Create embeddings
response = openai.Embedding.create(
    input="Your text here",
    model="text-embedding-ada-002"
)
print(response)

