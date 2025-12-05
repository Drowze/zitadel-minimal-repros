#!/bin/sh

# finish script with error if:
# - any command finishes unsuccessfuly
# - any referenced variable is not defined
set -eu

ZITADEL_PAT="$(cat "${ZITADEL_TOKEN_PATH}" | xargs)"

zitadel_call() {
  method="$1" ; shift
  path="$1"   ; shift

  # output the curl command for easy sharing/debugging
  # output is to stderr, so it doesn't interefere the function output
  echo "curl -X$method \$ZITADEL_URL$path $(echo "${*}" | tr '\n' ' ')" >&2

  curl --fail-with-body --silent -w "\n" \
    -X "$method" \
    -H "Host: ${ZITADEL_HOST:-localhost}" \
    -H "Authorization: Bearer ${ZITADEL_PAT}" \
    "$ZITADEL_URL$path" "${@}"
}

# update instance default login policy
zitadel_call PUT /admin/v1/policies/login -d '{
  "defaultRedirectUri": "http://localhost:5000/instance-default-login-policy",
  "allowUsernamePassword": true
}'

# create login policy for ZITADEL organization
org_id="$(zitadel_call POST /v2/organizations/_search -d '{
  "queries": [
    { "nameQuery": { "name": "ZITADEL", "method": "TEXT_QUERY_METHOD_EQUALS" }}
  ]
}' | jq -r '.result[-1].id')"
zitadel_call POST /management/v1/policies/login -H "x-zitadel-orgid: $org_id" -d '{
  "defaultRedirectUri": "http://localhost:5000/zitadel-login-policy",
  "allowUsernamePassword": true
}'

# create login policy for another organization (and set as default organization)
org_id="$(zitadel_call POST /v2/organizations -d '{"name": "Supercool"}' | jq -r '.organizationId')"
zitadel_call POST /management/v1/policies/login -H "x-zitadel-orgid: $org_id" -d '{
  "defaultRedirectUri": "http://localhost:5000/default-organization-login-policy",
  "allowUsernamePassword": true
}'
zitadel_call PUT /admin/v1/orgs/default/$org_id
