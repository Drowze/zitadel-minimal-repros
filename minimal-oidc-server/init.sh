#!/bin/sh

# Example:
# USERS_JSON='[{ "Email": "test96@example.com" },{ "Email": "test97@example.com" }]'
if [ -n "$USERS_JSON" ]; then
  export USERS_FILE=/users.json
  jq --argjson users_json "$USERS_JSON" -f /dev/stdin -n <<'JQ' > "$USERS_FILE"
    $users_json | map({
      FirstName: "Joe",
      LastName: "Doe",
      Username: .Email,
      Password: "verysecure",
      EmailVerified: true,
      Phone: "",
      PhoneVerified: false,
      PreferredLanguage: "EN",
      IsAdmin: false
    } + .) | with_entries({
      key: "id\(.key)",
      value: ({ID: "id\(.key)"} + .value)
    })
JQ
  jq -Mc -f /dev/stdin "$USERS_FILE" <<'JQ'
  {
    message: "Loaded users from supplied USERS_JSON",
    users: (. | map({ email: .Email, password: .Password, first_name: .FirstName, last_name: .LastName }))
  }
JQ
fi

/go/bin/mock-oidc
