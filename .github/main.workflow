workflow "Build and Deploy" {
  on = "push"
  resolves = [
    "Verify AKS deployment",
  ]
}

# Build

action "Build Docker image" {
  uses = "docker://docker:stable"
  args = ["build", "-t", "aks-example-octozen", "."]
}

# Azure Kubernetes

action "Load AKS kube credentials" {
  uses = "docker://swinton/azure"
  secrets = [
    "AZURE_SERVICE_PASSWORD",
    "AZURE_SERVICE_TENANT",
    "AZURE_SERVICE_APP_ID",
  ]
  args = "aks get-credentials --resource-group kardashian --name kardashian"
}

action "Setup ACR" {
  needs = ["Load AKS kube credentials"]
  uses = "docker://swinton/azure"
  args = "acr login --name AKSExampleOctozenRegistry"
  secrets = ["AZURE_SERVICE_PASSWORD", "AZURE_SERVICE_TENANT"]
}

action "Tag image for ACR" {
  needs = ["Build Docker image"]
  uses = "actions/docker/tag@master"
  args = ["aks-example-octozen", "aksexampleoctozenregistry.azurecr.io/aks-example-octozen"]
}

action "Push image to ACR" {
  needs = ["Setup ACR", "Tag image for ACR"]
  uses = "docker://docker:stable"
  args = "push aksexampleoctozenregistry.azurecr.io/aks-example-octozen"
}

action "Deploy branch filter" {
  needs = ["Push image to ACR"]
  uses = "actions/bin/filter@master"
  args = "branch master"
}

action "Deploy to AKS" {
  needs = ["Push image to ACR", "Deploy branch filter"]
  uses = "docker://gcr.io/cloud-builders/kubectl"
  runs = "sh -l -c"
  args = ["kubectl set image deployment aks-example-octozen aks-example-octozen=aksexampleoctozenregistry.azurecr.io/aks-example-octozen:latest"]
}

action "Verify AKS deployment" {
  needs = ["Deploy to AKS"]
  uses = "docker://gcr.io/cloud-builders/kubectl"
  args = "rollout status deployment/aks-example-octozen"
}
