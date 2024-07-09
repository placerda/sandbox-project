#! /bin/bash

set -e

program_name=$0

function usage {
    echo "usage: $program_name [-i|-image_tag|--image_tag]"
    echo "  -i|-image_tag|--image_tag                     specify container image tag"
    echo "  -r|-registry|--registry                       specify container registry name, for example 'xx.azurecr.io'"
    echo "  -plan|--plan                                  specify app service plan name."
    echo "  -n|-name|--name                               specify app name to produce a unique FQDN as AppName.azurewebsites.net."
    echo "  -g|-resource_group|--resource_group           specify app resource group"
    echo "  -subscription|--subscription                  specify app subscription, default using az account subscription"
    echo "  -v|-verbose|--verbose                         specify verbose mode"
    echo "  -p|-path|--path                               specify folder path to be deployed"
    exit 1
}
if [ "$1" == "-help" ] || [ "$1" == "-h" ]; then
  usage
  exit 0
fi

verbose=false

####################### Parse and validate args ############################
echo "Arguments received: $@"

while [ $# -gt 0 ]; do
  echo "Processing argument: $1"
  case "$1" in
    -i|-image_tag|--image_tag)
      image_tag="$2"
      echo "Set image_tag to $image_tag"
      shift
      ;;
    -r|-registry|--registry)
      registry_name="$2"
      echo "Set registry_name to $registry_name"
      shift
      ;;
    -plan|--plan)
      service_plan_name="$2"
      echo "Set service_plan_name to $service_plan_name"
      shift
      ;;
    -n|-name|--name)
      name="$2"
      echo "Set name to $name"
      shift
      ;;
    -g|-resource_group|--resource_group)
      resource_group="$2"
      echo "Set resource_group to $resource_group"
      shift
      ;;
    -subscription|--subscription)
      subscription="$2"
      echo "Set subscription to $subscription"
      shift
      ;;
    -v|-verbose|--verbose)
      verbose=true
      echo "Set verbose to true"
      ;;
    -p|-path|--path)
      path="$2"
      echo "Set path to $path"
      shift
      ;;
    *)
      printf "***************************\n"
      printf "* Error: Invalid argument.*\n"
      printf "***************************\n"
      exit 1
      ;;
  esac
  shift
done

# Add a print statement to verify all variables
echo "Final values:"
echo "image_tag=$image_tag"
echo "registry_name=$registry_name"
echo "service_plan_name=$service_plan_name"
echo "name=$name"
echo "resource_group=$resource_group"
echo "subscription=$subscription"
echo "verbose=$verbose"
echo "path=$path"



# fail if image_tag not provided
if [ -z "$image_tag" ]; then
    printf "***************************\n"
    printf "* Error: image_tag is required.*\n"
    printf "***************************\n"
    exit 1
fi

# check if : in image_tag
if [[ $image_tag == *":"* ]]; then
    echo "image_tag: $image_tag"
else
    version="v$(date '+%Y%m%d-%H%M%S')"

    image_tag="$image_tag:$version"
    echo "image_tag: $image_tag"
fi

# fail if registry_name not provided
if [ -z "$registry_name" ]; then
    printf "***************************\n"
    printf "* Error: registry is required.*\n"
    printf "***************************\n"
fi

# fail if name not provided
if [ -z "$name" ]; then
    printf "***************************\n"
    printf "* Error: name is required.*\n"
    printf "***************************\n"
fi

# fail if resource_group not provided
if [ -z "$resource_group" ]; then
    printf "***************************\n"
    printf "* Error: resource_group is required.*\n"
    printf "***************************\n"
fi

# fail if path not provided
if [ -z "$path" ]; then
    printf "***************************\n"
    printf "* Error: path is required.*\n"
    printf "***************************\n"
    exit 1
fi

####################### Build and push image ############################
echo "Change working directory to $path"
cd "$path"
docker build -t "$image_tag" .

if [[ $registry_name == *"azurecr.io" ]]; then
    echo "Trying to login to $registry_name..."
    az acr login -n "$registry_name"

    acr_image_tag=$registry_name/$image_tag
    echo "ACR image tag: $acr_image_tag"
    docker tag "$image_tag" "$acr_image_tag"
    image_tag=$acr_image_tag
else
    echo "Make sure you have docker account login!!!"
    printf "***************************************************\n"
    printf "* WARN: Make sure you have docker account login!!!*\n"
    printf "***************************************************\n"

    docker_image_tag=$registry_name/$image_tag

    echo "Docker image tag: $docker_image_tag"
    docker tag "$image_tag" "$docker_image_tag"
    image_tag=$docker_image_tag
fi

echo "Start pushing image...$image_tag"
docker push "$image_tag"

####################### Create and config app ############################

function append_to_command {
  command=$1
  if [ -n "$subscription" ]; then
    command="$command --subscription $subscription"
  fi
  if $verbose; then
    command="$command --debug"
  fi
  echo "$command"
}


# Check if the app exists
app_exists=$(az webapp show --name $name --resource-group $resource_group --query "name" -o tsv)

if [ -z "$app_exists" ]; then
  # Create app
  echo "Creating app...$name"
  command="az webapp create --name $name -p $service_plan_name --deployment-container-image-name $image_tag --startup-file 'bash start.sh' -g $resource_group"
  command=$(append_to_command "$command")
  echo "$command"
  eval "$command"
else
  # Update app
  echo "Updating app...$name"
#   command="az webapp update --name $name --resource-group $resource_group --set containerSettings.imageName=$image_tag"
  command="az webapp config container set --name $name --resource-group $resource_group --container-image-name $image_tag"
  command=$(append_to_command "$command")
  echo "$command"
  eval "$command"
fi

# Config environment variable
echo "Config app...$name"

# Port default to 8080 corresponding to the DockerFile
command="az webapp config appsettings set -g $resource_group --name $name --settings USER_AGENT=promptflow-appservice WEBSITES_PORT=8080 @settings.json "
command=$(append_to_command "$command")
echo "$command"
eval "$command"
echo "Please go to https://portal.azure.com/ to config environment variables and restart the app: $name at (Settings>Configuration) or (Settings>Environment variables)"
echo "Reach deployment logs at (Deployment>Deployment Central) and app logs at (Monitoring>Log stream)"
echo "Reach advanced deployment tools at https://$name.scm.azurewebsites.net/"
echo "Reach more details about app service at https://learn.microsoft.com/en-us/azure/app-service/"