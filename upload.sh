#!/usr/bin/env bash

set -euxo pipefail

# Uploading artifacts in the `repo` directory to a WebDav directory
# that is secured by an access token
curl -X DELETE -H "Authorization: Bearer ${WEBDAV_TOKEN}" "${WEBDAV_URL}/tmp-repo"
curl --fail -X MKCOL -H "Authorization: Bearer ${WEBDAV_TOKEN}" "${WEBDAV_URL}/tmp-repo"

for file in /repo/*
do
  curl --fail -H "Authorization: Bearer ${WEBDAV_TOKEN}" -T ${file} "${WEBDAV_URL}/tmp-repo/${file}"
done

curl -X DELETE -H "Authorization: Bearer ${WEBDAV_TOKEN}" "${WEBDAV_URL}/repo"
curl --fail -X MOVE --header "Destination:${WEBDAV_URL}/repo '${WEBDAV}/tmp-repo'