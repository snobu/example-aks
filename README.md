# Azure Kubernetes Service (AKS) GitHub Action Example

An example workflow, using [the GitHub Action for Azure](https://github.com/actions/azure) to build, tag, and deploy a container image to a running Kubernetes cluster on AKS.

## Workflow

The [example workflow](.github/main.workflow) will trigger on every push to this repo.

For pushes to a _feature_ branch, the workflow will:

1. Build the Docker image from [the included `Dockerfile`](Dockerfile)
1. Tag and push the image to Azure Container Registry (ACR)

For pushes to the _default_ branch (`master`), in addition to the above Actions, the workflow will:

1. Update the deployment resource on the running AKS Kubernetes with the latest container image

### Prerequisites

The following setup steps must be complete before running the example workflow.

1. Create an Azure resource group, a logical container into which Azure resources are deployed and managed, in a location of your choice:
    - `az group create --name $RESOURCE_GROUP --location $LOCATION` ([more info](https://docs.microsoft.com/en-us/cli/azure/group?view=azure-cli-latest#az-group-create))
1. Create an Azure Container Registry (ACR) instance in your resource group:
    - `az acr create --name $REGISTRY --resource-group $RESOURCE_GROUP --sku Basic` ([more info](https://docs.microsoft.com/en-us/cli/azure/acr?view=azure-cli-latest#az-acr-create))
1. Configure ACR authentication, grant the AKS service principal the correct rights to pull images from ACR:
    -  `az role assignment create --assignee $AZURE_SERVICE_APP_ID --scope $ACR_ID --role Reader` ([more info](https://docs.microsoft.com/en-us/cli/azure/role/assignment?view=azure-cli-latest#az-role-assignment-create))
1. Build, tag, and push the [included Docker image](Dockerfile) to ACR
1. Create an AKS Kubernetes cluster:
    - `az aks create --resource-group $RESOURCE_GROUP --name $CLUSTER --node-count 1 --service-principal $AZURE_SERVICE_APP_ID --client-secret $AZURE_SERVICE_PASSWORD --generate-ssh-keys` ([more info](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-create))
1. Connect to your cluster using `kubectl`:
    - `az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER` ([more info](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-get-credentials))
1. Apply the [included Kubernetes configuration](kconfig.yml) to your cluster:
    - `kubectl apply -f ./kconfig.yml`

## License

This repository is [licensed under CC0-1.0](LICENSE), which waives all copyright restrictions.
