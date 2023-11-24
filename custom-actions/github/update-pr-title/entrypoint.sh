#!/bin/bash
set -e

echo ${INPUT_REPOSITORY}
echo ${INPUT_PR_TITLE}
echo ${INPUT_PR_NUMBER}
echo ${INPUT_WORK_ITEM_ID}
echo ${INPUT_TOKEN}

API_PATCH_URL="https://api.github.com/repos/${INPUT_REPOSITORY}/pulls/${INPUT_PR_NUMBER}"
echo ${API_PATCH_URL}

API_RESPONSE=$(curl -Lv -X "PATCH" "${API_PATCH_URL}" \
-H "Accept: application/vnd.github+json" \
-H "Authorization: Bearer ${INPUT_TOKEN}" \
-H "X-GitHub-Api-Version: 2022-11-28" \
-d "{
  \"title\": \"AB#${INPUT_WORK_ITEM_ID} ${INPUT_PR_TITLE}\"
}")

echo ${API_RESPONSE}