#!/usr/bin/env bash

set -euxo pipefail

# Uploading artifacts in the `repo` directory to a WebDav directory
# that is secured by an access token
curl -X DELETE -H "Authorization: Bearer ${WEBDAV_TOKEN}" "${WEBDAV_URL}/tmp-repo"
curl --fail -X MKCOL -H "Authorization: Bearer ${WEBDAV_TOKEN}" "${WEBDAV_URL}/tmp-repo"

cd repo
find . type -f -exec curl --fail -H "Authorization: Bearer ${WEBDAV_TOKEN}" -T {} "${WEBDAV_URL}/tmp-repo/"{} \;

curl -X DELETE -H "Authorization: Bearer ${WEBDAV_TOKEN}" "${WEBDAV_URL}/repo"
curl --fail -X MOVE -H "Authorization: Bearer ${WEBDAV_TOKEN}" -H "Destination:${WEBDAV_URL}/repo" "${WEBDAV_URL}/tmp-repo"