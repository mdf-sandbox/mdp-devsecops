#!/bin/bash
set -e

#API URL of Artifact Details - Get Packages to get details about all of the packages in the feed.
#Resource: https://learn.microsoft.com/en-us/rest/api/azure/devops/artifacts/artifact-details/get-packages?view=azure-devops-rest-7.0
API_GET_URL="https://feeds.dev.azure.com/kBank-MDF-SANDBOX/_apis/packaging/Feeds/kBank-MDF-SANDBOX/packages?packageNameQuery=${INPUT_PACKAGE_NAME}&includeAllVersions=True&api-version=7.0-preview.1"

#API URL of of Python - Update Package Version to update state for a package version.
#Resource: https://learn.microsoft.com/en-us/rest/api/azure/devops/artifactspackagetypes/python/update-package-version?view=azure-devops-rest-7.0
API_PATCH_URL="https://pkgs.dev.azure.com/kBank-MDF-SANDBOX/_apis/packaging/feeds/kBank-MDF-SANDBOX/pypi/packages/${INPUT_PACKAGE_NAME}/versions/${INPUT_PACKAGE_VERSION}?api-version=7.0-preview.1"

#Call API to get feed views of specified version of package.
API_RESPONSE=$(curl -ks -X "GET" "${API_GET_URL}" \
-H "Content-Type: application/json" \
-u "__token__:${INPUT_TOKEN}"
)
echo "Call API to get feed views of specified version of package."
echo "GET ${API_GET_URL}"
echo "List all feed views for '${INPUT_PACKAGE_NAME}' version '${INPUT_PACKAGE_VERSION}'"
echo ${API_RESPONSE} | jq '.value.[0].versions.[] | select(.version==$ARGS.positional[0]) | {version: .version, views: [.views.[].name]}' --args ${INPUT_PACKAGE_VERSION}

#Convert a Python Data list to a bash array
FEED_VIEW_ARRAY=($(echo ${INPUT_FEED_VIEW} | tr -d '[],'))

for FEED_VIEW in ${FEED_VIEW_ARRAY[@]}; do
#Call API to update feed view of specified version of package.
API_RESPONSE=$(curl -ks -X "PATCH" "${API_PATCH_URL}" \
-H "Content-Type: application/json" \
-u "__token__:${INPUT_TOKEN}" \
-d $"{
  'views': {
    'op': 'add',
    'path': '/views/-',
    'value': '${FEED_VIEW}'
  }
}")
echo "Call API to promote feed view of specified version of package."
echo "PATCH ${API_PATCH_URL}"
echo "Promoting package '${INPUT_PACKAGE_NAME}' version '${INPUT_PACKAGE_VERSION}' to feed view '${FEED_VIEW}'..."
sleep 10
echo ${API_RESPONSE}
done

#Call API to get feed views of specified version of package.
API_RESPONSE=$(curl -ks -X "GET" "${API_GET_URL}" \
-H "Content-Type: application/json" \
-u "__token__:${INPUT_TOKEN}"
)
echo "Call API to get feed views of specified version of package."
echo "GET ${API_GET_URL}"
echo "List all feed views for '${INPUT_PACKAGE_NAME}' version '${INPUT_PACKAGE_VERSION}'"
echo ${API_RESPONSE} | jq '.value.[0].versions.[] | select(.version==$ARGS.positional[0]) | {version: .version, views: [.views.[].name]}' --args ${INPUT_PACKAGE_VERSION}

for FEED_VIEW in ${FEED_VIEW_ARRAY[@]}; do
#Validate changes of specified version of package.
CHECK_FEED_VIEW=$(echo ${API_RESPONSE} | jq -r '.value.[0].versions.[] | select(.version==$ARGS.positional[0]) | .views.[] | select(.name==$ARGS.positional[1]) | .name' --args ${INPUT_PACKAGE_VERSION} ${FEED_VIEW})
if [[ ${CHECK_FEED_VIEW} == ${FEED_VIEW} ]]; then
  echo "Package '${INPUT_PACKAGE_NAME}' version '${INPUT_PACKAGE_VERSION}' has been promoted to feed view '${FEED_VIEW}' successfully."
else
  echo "Package '${INPUT_PACKAGE_NAME}' version '${INPUT_PACKAGE_VERSION}' has not been promoted to feed view '${FEED_VIEW}' yet."
fi
done