#!/usr/bin/env bash

set -euxo pipefail

# Uploading artifacts in the `repo` directory to a WebDav directory
# that is secured by an access token
curl -X MKCOL -H "Authorization: Bearer ${WEBDAV_TOKEN}" "${WEBDAV_URL}/repo"

cd repo
find . -type f -exec curl --fail -H "Authorization: Bearer ${WEBDAV_TOKEN}" -T "{}" "${WEBDAV_URL}/repo/{}" \;