#!/bin/bash
set -e

echo ${INPUT_PR_STATE}
echo ${INPUT_PR_MERGED_BY}
echo ${INPUT_PR_MERGED_AT}
echo ${INPUT_ENVIRONMENT}
echo ${INPUT_WORK_ITEM_ID}
echo ${INPUT_BOARD_COLUMN}
echo ${INPUT_TOKEN}
echo ${INPUT_RUN_ID}
echo ${INPUT_RUN_RESULT_STATE}
echo ${INPUT_RUN_NOTEBOOK_PATH}
echo ${INPUT_RUN_PAGE_URL}

# if [[ ${INPUT_PR_STATE} != '' ]]; then
#   COMMENT="${INPUT_PR_MERGED_BY} merged this pull request at ${INPUT_PR_MERGED_AT}"
# else
#   COMMENT="ahongtrakulchai deployed the package from this pull request to ${INPUT_ENVIRONMENT} environment."
# fi

# COMMENT="Execute Approval Gate Check for Run ID: ${INPUT_RUN_ID}
# {
#   "result_state": "${INPUT_RUN_RESULT_STATE}",
#   "notebook_path": "${INPUT_RUN_NOTEBOOK_PATH}",
#   "run_page_url": "${INPUT_RUN_PAGE_URL}"
# }"
if [[ ${INPUT_PR_STATE} != '' ]]; then
  COMMENT="${INPUT_PR_MERGED_BY} merged this pull request at ${INPUT_PR_MERGED_AT}"
else
  # COMMENT="<div>Execute Approval Gate Check for Run ID: ${INPUT_RUN_ID}</div><div><br></div><div>{<span style="font-weight:normal\;"><span>&nbsp; </span>\n&quot;result_state&quot;: &quot;<b>${INPUT_RUN_RESULT_STATE}</b>&quot;,</span><span style="font-weight:normal\;"><span>&nbsp; </span>&quot;\nnotebook_path&quot;: &quot;<b>${INPUT_RUN_NOTEBOOK_PATH}</b>&quot;,</span><span style="font-weight:normal\;"><span>&nbsp; </span>&quot;\nrun_page_url&quot;: &quot;<b><a href="${INPUT_RUN_PAGE_URL}">${INPUT_RUN_PAGE_URL}</a></b>&quot;</span>}</div><div><br></div>"
  # COMMENT="<div><span style="color:rgba(0, 0, 0, 0.9)\;">Execute Approval Gate Check for Run ID: 70802930006636</span></div><div><span style="color:rgba(0, 0, 0, 0.9)\;"><br></span></div><div><p style="margin:0.0px 0.0px 0.0px 0.0px\;font:13.0px 'Helvetica Neue'\;">{</p><p style="margin:0px\;font-style:normal\;font-size:13px\;line-height:normal\;"><span style="font-weight:normal\;"><span>&nbsp; </span>&quot;result_state&quot;: &quot;<b>SUCCESS</b>&quot;,</span></p><p style="margin:0px\;font-style:normal\;font-size:13px\;line-height:normal\;"><span style="font-weight:normal\;"><span>&nbsp; </span>&quot;notebook_path&quot;: &quot;</span><b>/test/mdp/unit/ingestion_area1/1.summary_passed</b>&quot;,</p><p style="margin:0px\;font-style:normal\;font-size:13px\;line-height:normal\;"><span style="font-weight:normal\;"><span>&nbsp; </span>&quot;run_page_url&quot;: &quot;</span><b><a href=\"https://adb-5730376679189321.1.azuredatabricks.net/?o=5730376679189321#job/47563390805699/run/70802930006636\">https://adb-5730376679189321.1.azuredatabricks.net/?o=5730376679189321#job/47563390805699/run/70802930006636</a></b>&quot;</p><p style="margin:0.0px 0.0px 0.0px 0.0px\;font:13.0px 'Helvetica Neue'\;">}</p><br></div>"
  # COMMENT="<div><span style=\"color:rgba(0, 0, 0, 0.9);\">Execute Approval Gate Check for Run ID: 70802930006636</span></div><div><span style=\"color:rgba(0, 0, 0, 0.9);\"><br></span></div><div><p style=\"margin:0.0px 0.0px 0.0px 0.0px;font:13.0px 'Helvetica Neue';\">{</p><p style=\"margin:0px;font-style:normal;font-size:13px;line-height:normal;\"><span style=\"font-weight:normal;\"><span>&nbsp; </span>&quot;result_state&quot;: &quot;<b>SUCCESS</b>&quot;,</span></p><p style=\"margin:0px;font-style:normal;font-size:13px;line-height:normal;\"><span style=\"font-weight:normal;\"><span>&nbsp; </span>&quot;notebook_path&quot;: &quot;</span><b>/test/mdp/unit/ingestion_area1/1.summary_passed</b>&quot;,</p><p style=\"margin:0px;font-style:normal;font-size:13px;line-height:normal;\"><span style=\"font-weight:normal;\"><span>&nbsp; </span>&quot;run_page_url&quot;: &quot;</span><b><a href=\\\"https://adb-5730376679189321.1.azuredatabricks.net/?o=5730376679189321#job/47563390805699/run/70802930006636\\\">https://adb-5730376679189321.1.azuredatabricks.net/?o=5730376679189321#job/47563390805699/run/70802930006636</a></b>&quot;</p><p style=\"margin:0.0px 0.0px 0.0px 0.0px;font:13.0px 'Helvetica Neue';\">}</p><br></div>"
  COMMENT="<div>Execute Approval Gate Check for Run ID: 70802930006636</div><div>{\"result_state\": \"<b>SUCCESS</b>\", \"notebook_path\": \"<b>/test/mdp/unit/ingestion_area1/1.summary_passed</b>\", \"run_page_url\": \"<b><a href=\\\"https://adb-5730376679189321.1.azuredatabricks.net/?o=5730376679189321#job/47563390805699/run/70802930006636\\\">https://adb-5730376679189321.1.azuredatabricks.net/?o=5730376679189321#job/47563390805699/run/70802930006636</a></b>\", }</div>"
fi


if [[ ${INPUT_ENVIRONMENT} != 'PRD' ]]; then
  STATE="Doing"
else
  STATE="Done"
fi

API_PATCH_URL="https://dev.azure.com/kBank-MDF-SANDBOX/MDF/_apis/wit/workitems/${INPUT_WORK_ITEM_ID}?api-version=7.1-preview.3"
echo ${API_PATCH_URL}

API_RESPONSE=$(curl -v -X "PATCH" "${API_PATCH_URL}" \
-H "Content-Type: application/json-patch+json" \
-u "__token__:${INPUT_TOKEN}" \
-d "[
  {
    'op': 'add',
    'path': '/fields/System.State',
    'value': '${STATE}'
  },
  {
    'op': 'replace',
    'path': '/fields/WEF_3C5EBBCC56D24168AAEFD5886887382F_Kanban.Column',
    'value': '${INPUT_BOARD_COLUMN}'
  },
  {
    'op': 'add',
    'path': '/fields/System.History',
    'from': null,
    'value': '${COMMENT}'
  }
]")

echo ${API_RESPONSE}