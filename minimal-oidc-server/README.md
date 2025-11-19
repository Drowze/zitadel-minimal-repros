# OIDC mock server

Running it:

```
USERS_FILE=/users.json docker run --rm -it -v $(pwd)/users.json:/users.json -e REDIRECT_URI=http://example.com -p 9998:9998 local:zitadel-oidc
```
