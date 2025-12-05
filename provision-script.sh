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

org_id="$(zitadel_call POST /v2/organizations \
  -d '{"name": "Supercool"}' | jq -r '.organizationId')"

zitadel_call POST /management/v1/orgs/me/domains -H "x-zitadel-orgid: $org_id" -d '{"domain":"example.com"}'

idp_id="$(zitadel_call POST /management/v1/idps/generic_oidc \
  -H "x-zitadel-orgid: $org_id" -d '{
    "name":"minimal-oidc-server",
    "issuer":"http://minimal-oidc-server:9998",
    "client_id":"web",
    "client_secret":"secret",
    "scopes":["openid","profile","email"],
    "provider_options":{"is_auto_creation":true,"auto_linking": "AUTO_LINKING_OPTION_EMAIL"}
  }' | jq -r '.id')"

zitadel_call POST /management/v1/policies/login \
  -H "x-zitadel-orgid: $org_id" -d '{
    "ignore_unknown_usernames":false,
    "allow_username_password":false,
    "allow_register":false,
    "allow_external_idp":true,
    "hide_password_reset":true,
    "allow_domain_discovery":true,
    "password_check_lifetime":"864000s",
    "external_login_check_lifetime":"864000s",
    "mfa_init_skip_lifetime":"2592000s",
    "second_factor_check_lifetime":"64800s",
    "multi_factor_check_lifetime":"43200s",
    "idps":[{
      "idp_id":"'$idp_id'",
      "ownerType":"IDP_OWNER_TYPE_ORG"
    }]
  }'
