#!/bin/sh

# finish script with error if:
# - any command finishes unsuccessfuly
# - any referenced variable is not defined
set -eu
set -o pipefail

ZITADEL_PAT="$(cat "${ZITADEL_TOKEN_PATH}" | xargs)"

zitadel_call() {
  method="$1" ; shift
  path="$1"   ; shift

  http --ignore-stdin --check-status -A bearer -a "$ZITADEL_PAT" \
    "$method" "$ZITADEL_URL$path" \
    "Host:${ZITADEL_HOST:-localhost}" "${@}"
}

org_id="$(zitadel_call POST /v2/organizations name=Supercool | jq -r '.organizationId')"

zitadel_call POST /management/v1/orgs/me/domains "x-zitadel-orgid:$org_id" domain=example.com

idp_id="$(zitadel_call POST /management/v1/idps/generic_oidc "x-zitadel-orgid:$org_id" \
  name=minimal-oidc-server \
  issuer=http://minimal-oidc-server:9998 \
  client_id=web \
  client_secret=secret \
  scopes:='["openid", "profile", "email", "custom-scope"]' \
  provider_options[is_auto_creation]:=true \
  provider_options[auto_linking]=AUTO_LINKING_OPTION_EMAIL | jq -r '.id')"

zitadel_call POST /management/v1/policies/login "x-zitadel-orgid:$org_id" \
  allow_external_idp:=true \
  hide_password_reset:=true \
  allow_domain_discovery:=true \
  password_check_lifetime=864000s \
  external_login_check_lifetime=864000s \
  mfa_init_skip_lifetime=2592000s \
  second_factor_check_lifetime=64800s \
  multi_factor_check_lifetime=43200s \
  idps[0][idp_id]=$idp_id \
  idps[0][ownerType]=IDP_OWNER_TYPE_ORG
