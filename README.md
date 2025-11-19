# zitadel-minimal-repros

This sets up a minimal Zitadel instance using docker-compose, along with a
mocked identity provider (`minimal-oidc-server`) and a minimal http server
to receive requests from Zitadel actions (`zitadel-hooks`)

To start it, simply run: `docker compose up`

* zitadel url: http://localhost:8080
* zitadel admin user: `admin@zitadel.localhost:Password1!`
* test user from a regular organization: `testuser@example.com`
  * Attempting to sign to this user credentials should succesfully get the
  identity `minimal-oidc-server` (a dummy identity provider) and automatically
  create a user on the `Supercool` organization.
