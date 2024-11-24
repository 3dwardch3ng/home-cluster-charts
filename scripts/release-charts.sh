#!/bin/bash
set -e

CHARTMUSEUM_URL=$1
CHARTMUSEUM_BASIC_AUTH_USER=$2
CHARTMUSEUM_BASIC_AUTH_PASSWORD=$3

echo "Install Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "Install helm-push plugin..."
helm plugin install https://github.com/chartmuseum/helm-push

echo "Add Chartmuseum helm repo..."
helm repo add chartmuseum $CHARTMUSEUM_URL
helm repo update

echo "Process and push charts to the Chartmuseum..."
for dir in charts/*; do
  chart_name="$(basename "$dir")"
  version="$(yq '.version' "$dir/Chart.yaml")"
  chart_ver_url=$CHARTMUSEUM_URL/api/charts/$chart_name
  charts=$(curl --location $chart_ver_url)
  if [[ $charts == *"404"* ]]; then
    echo "Chart $chart_name does not exist..."
    echo "Pushing chart $chart_name..."
    helm cm-push -u $CHARTMUSEUM_BASIC_AUTH_USER -p $CHARTMUSEUM_BASIC_AUTH_PASSWORD $dir chartmuseum
  else
    existing_versions=$(echo $charts | jq '.[].version')
    if [[ ${existing_versions[@]} =~ $version ]]; then
      echo "Version $version for chart $chart_name exists, skipping..."
    else
      echo "Pushing chart $chart_name..."
      helm cm-push -u $CHARTMUSEUM_BASIC_AUTH_USER -p $CHARTMUSEUM_BASIC_AUTH_PASSWORD $dir chartmuseum
    fi
  fi
done