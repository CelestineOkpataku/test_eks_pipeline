#!/bin/bash

# Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod +x get_helm.sh
./get_helm.sh

# Verify Helm installation
helm version

# Add Kyverno Helm repository
helm repo add kyverno https://kyverno.github.io/kyverno/

# Update Helm repositories
helm repo update

# Install Kyverno
helm install kyverno kyverno/kyverno --namespace kyverno --create-namespace --set installCRDs=true

echo 'hello'