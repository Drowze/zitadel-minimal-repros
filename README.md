# zitadel-minimal-repros

This sets up a minimal Zitadel instance using docker-compose, along with a
mocked identity provider (`minimal-oidc-server`) and a minimal http server
to receive requests from Zitadel actions (`zitadel-hooks`).

## Setup instructions:

* run: `docker compose up`
* add a localhost entry for `minimal-oidc-server` on `/etc/hosts`, e.g.:
    ```
    # /etc/hosts
    127.0.0.1   minimal-oidc-server
    ```

## Reference of created resources:

After the above steps you should have a fully-working Zitadel instance with:
* url: http://localhost:8080
* admin user: `admin@zitadel.localhost:Password1!`
* test user from a regular organization: `testuser@example.com:verysecure`
  * Attempting to sign with this user's credentials for the first time should
  succesfully get the identity `minimal-oidc-server` (a dummy identity provider)
  and automatically create a user on the `Supercool` organization.

---

#### Summary of the repository structure:

This repository aims to be as simple and self-contained as possible, while still
allowing to reproduce Zitadel issues that require a few moving pieces. Summary:

* `docker-compose.yml`
* `data/` - directory mounted into Zitadel, where a machine admin PAT and JWT
  private key are created (so we can use that for provisioning resources to
  Zitadel)
* `init.yml` - initial config passed to Zitadel (via `--steps`)
* `config.yml` - config passed to Zitadel (via `--config`)
* `provision-script.sh` - (<ins>Please have a look at it!</ins>) script executed
  after Zitadel is fully created. It simply executes a bunch of Zitadel API
  requests to e.g.: create an organization, identity provider and login policy.
  To execute this script, a lightweight `zitadel-provision` service is spin up
  in our docker-compose configuration (after the `zitadel` service is healthy)
* `minimal-oidc-server/` - files related to the mocked identity provider (which
  is based on [zitadel/oidc](https://github.com/zitadel/oidc)). It is spin up
  as `minimal-oidc-server` in our docker-compose configuration.
* `hooks-server.rb` - a dead simple ruby server that simply prints the requests
  it receives. It is spin up as `zitadel-hooks` in our docker-compose
  configuration.
