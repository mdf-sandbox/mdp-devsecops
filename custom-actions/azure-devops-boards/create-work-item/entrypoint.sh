#!/bin/bash
set -e

echo ${INPUT_REPOSITORY}
echo ${INPUT_PR_TITLE}
echo ${INPUT_PR_URL}
echo ${INPUT_PR_REPOSITORY_URL}
echo ${INPUT_PR_NUMBER}
echo ${INPUT_PR_STATE}
echo ${INPUT_PR_HEAD_REF}
echo ${INPUT_PR_BASE_REF}
echo ${INPUT_PR_CREATED_BY}
echo ${INPUT_PR_CREATED_AT}
echo ${INPUT_PACKAGE_NAME}
echo ${INPUT_TOKEN}

API_POST_URL="https://dev.azure.com/kBank-MDF-SANDBOX/MDF/_apis/wit/workitems/\${issue}?api-version=7.1-preview.3"
echo ${API_POST_URL}

API_RESPONSE=$(curl -ks -X "POST" "${API_POST_URL}" \
-H "Content-Type: application/json-patch+json" \
-u "__token__:${INPUT_TOKEN}" \
-d "[
  {
    'op': 'add',
    'path': '/fields/System.Title',
    'value': '${INPUT_PR_TITLE} #${INPUT_PR_NUMBER}'
  },
  {
    'op': 'add',
    'path': '/fields/System.Description',
    'from': null,
    'value': '<h2><span style=\"font-weight:normal;\"><b> ${INPUT_PR_CREATED_BY}</b> want to merge commits into </span><span style=\"font-weight:normal;background-color:#E2F3FE;color:#2F6BD4;\">${INPUT_PR_BASE_REF}</span><span style=\"font-weight:normal;\"> from </span><span style=\"font-weight:normal;background-color:#E2F3FE;color:#2F6BD4;\">${INPUT_PR_HEAD_REF}</span></h2><h3><span style=\"font-size:14px;\">GitHub Repository: </span><span style=\"font-weight:normal;font-size:14px;\">${INPUT_REPOSITORY}</span><br><span style=\"font-size:14px;\">GitHub URL: </span><span style=\"font-weight:normal;font-size:14px;\"><a href=\"${INPUT_PR_REPOSITORY_URL}\">${INPUT_PR_REPOSITORY_URL}</a></span><br><span style=\"font-size:14px;\">Created At: </span><span style=\"font-weight:normal;font-size:14px;\">${INPUT_PR_CREATED_AT}</span></h3>'
  },
  {
    'op': 'add',
    'path': '/fields/System.Tags',
    'value': '${INPUT_PACKAGE_NAME}'
  }
]")

WORK_ITEM_ID=$(echo ${API_RESPONSE} | jq -r '.id')
echo "work_item_id=${WORK_ITEM_ID}" >> $GITHUB_OUTPUT