#!/usr/bin/env bash

set -e

CRED_FILE="$HOME/.githubCredentials"

if [[ ! -r "$CRED_FILE" ]]; then
    echo "Credential File does not exist"
    echo "To create, do this:"
    echo "touch ~/.githubCredentials"
    echo "chmod 700 ~/.githubCredentials"
    echo "cat <<EOF > ~/.githubCredentials"
    echo "org TerabyteQBT"
    echo "repo meta"
    echo "token mygithubapitoken"
    echo "EOF"
    exit 1
fi

ORG="$(cat $CRED_FILE | egrep '^org' | sed 's/.* //')"
REPO="$(cat $CRED_FILE | egrep '^repo' | sed 's/.* //')"
TOKEN="$(cat $CRED_FILE | egrep '^token' | sed 's/.* //')"

# get CV for meta_tools
META_TOOLS_CV="$(qbt resolveManifestCumulativeVersions --package meta_tools.release | sed 's/.* //')"
if [[ -z "$COMMIT_HASH" ]]; then
    COMMIT_HASH="$(git rev-parse HEAD)"
fi

MT_PATH="/tmp/meta_tools-$META_TOOLS_CV.tar.gz"

function cleanup {
    # XXX: rm -f $MT_PATH
    echo "XXX: skipping cleanup of $MT_PATH"
}
# clean up
trap cleanup EXIT

echo "Building a qbt meta_tools release ($META_TOOLS_CV) ..."
qbt build --package meta_tools.release --output requested,tarball,$MT_PATH

echo "Tagging release..."
TAG_NAME="metatools-$(date +%s)"
TAG_MSG="Release on $(date) by $(whoami)"

#XXX
#git tag -a $TAG_NAME -m"$TAG_MSG" $COMMIT_HASH
#git push git@github.com:$ORG/$REPO $TAG_NAME:$TAG_NAME

echo "Creating release on github..."
GITHUB_API="{\"tag_name\": \"$TAG_NAME\",\"target_commitish\": \"$COMMIT_HASH\",\"name\": \"$META_TOOLS_CV\",\"body\": \"$TAG_MSG\",\"draft\": false,\"prerelease\": false}"
echo "JSON Metadata: $GITHUB_API"

#XXX
#RELEASE_JSON=$(curl --data "$GITHUB_API" "https://api.github.com/repos/$ORG/$REPO/releases?access_token=$TOKEN")
#echo $RELEASE_JSON
RELEASE_JSON='{ "url": "https://api.github.com/repos/TerabyteQbt/meta/releases/5727608", "assets_url": "https://api.github.com/repos/TerabyteQbt/meta/releases/5727608/assets", "upload_url": "https://uploads.github.com/repos/TerabyteQbt/meta/releases/5727608/assets{?name,label}", "html_url": "https://github.com/TerabyteQbt/meta/releases/tag/metatools-1489427073", "id": 5727608, "tag_name": "metatools-1489427073", "target_commitish": "35b0ae06721e396a1ece243fa4ff94f47ea8fdcd", "name": "e8605d60e705a93c653307c425829047068ee4b1", "draft": false, "author": { "login": "terabyte", "id": 204385, "avatar_url": "https://avatars3.githubusercontent.com/u/204385?v=3", "gravatar_id": "", "url": "https://api.github.com/users/terabyte", "html_url": "https://github.com/terabyte", "followers_url": "https://api.github.com/users/terabyte/followers", "following_url": "https://api.github.com/users/terabyte/following{/other_user}", "gists_url": "https://api.github.com/users/terabyte/gists{/gist_id}", "starred_url": "https://api.github.com/users/terabyte/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/terabyte/subscriptions", "organizations_url": "https://api.github.com/users/terabyte/orgs", "repos_url": "https://api.github.com/users/terabyte/repos", "events_url": "https://api.github.com/users/terabyte/events{/privacy}", "received_events_url": "https://api.github.com/users/terabyte/received_events", "type": "User", "site_admin": false }, "prerelease": false, "created_at": "2017-03-13T17:44:33Z", "published_at": "2017-03-13T17:44:36Z", "assets": [ ], "tarball_url": "https://api.github.com/repos/TerabyteQbt/meta/tarball/metatools-1489427073", "zipball_url": "https://api.github.com/repos/TerabyteQbt/meta/zipball/metatools-1489427073", "body": "Release on Mon Mar 13 10:44:33 PDT 2017 by cmyers" }'

UPLOAD_URL="$(echo $RELEASE_JSON | sed 's/: /\n/g' | grep uploads.github.com | cut -d'"' -f2 | cut -d'{' -f1)"
echo "Uploading artifact to github (url: $UPLOAD_URL)..."
echo "UNIMPLEMENTED:  please manually upload the artifact at $MT_PATH"


# url will look like this after processing: https://uploads.github.com/repos/TerabyteQbt/meta/releases/5727608/assets

#CT_LENGTH="$(wc -c $MT_PATH | cut -d' ' -f1)"
#curl -v -XPOST -H "Content-Type: application/gzip" -H "Content-Length: $CT_LENGTH" "$UPLOAD_URL?label=meta_tools&name=meta_tools2-$META_TOOLS_CV.tar.gz&access_token=$TOKEN" @$MT_PATH



