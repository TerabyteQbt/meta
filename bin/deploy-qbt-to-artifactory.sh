#!/usr/bin/env bash

set -e

CRED_FILE="$HOME/.artifactoryCredentials"

if [[ ! -r "$CRED_FILE" ]]; then
    echo "Credential File does not exist"
    echo "To create, do this:"
    echo "touch ~/.artifactoryCredentials"
    echo "chmod 700 ~/.artifactoryCredentials"
    echo "cat <<EOF > ~/.artifactoryCredentials"
    echo "url http://my.artifactory.example.com/artifactory/libs-release-local"
    echo "username myusername"
    echo "password mypassword"
    echo "EOF"
    exit 1
fi

PUBLISH_URL_PREFIX="$(cat $CRED_FILE | egrep '^url' | sed 's/.* //')"
USERNAME="$(cat $CRED_FILE | egrep '^username' | sed 's/.* //')"
PASSWORD="$(cat $CRED_FILE | egrep '^password' | sed 's/.* //')"

# get CV for meta_tools
META_TOOLS_CV="$(qbt resolveManifestCumulativeVersions --package meta_tools.release | sed 's/.* //')"
PUBLISH_PATH="qbt/meta_tools/$META_TOOLS_CV/meta_tools-$META_TOOLS_CV.tar.gz"


MT_PATH="/tmp/meta_tools-$META_TOOLS_CV.tar.gz"

echo "Building a qbt meta_tools releasei ($META_TOOLS_CV) ..."
qbt build --package meta_tools.release --output requested,tarball,$MT_PATH

SHA1="$(openssl sha1 "$MT_PATH" | sed 's/.* //')"
MD5="$(openssl md5 "$MT_PATH" | sed 's/.* //')"

echo "Uploading to artifactory..."
curl -XPUT -L -H "X-Checksum-Sha1: $SHA1" -H "X-Checksum-Md5: $MD5" -u "$USERNAME:$PASSWORD" --data-binary @"$MT_PATH" "$PUBLISH_URL_PREFIX/$PUBLISH_PATH"

# clean up
rm $MT_PATH
