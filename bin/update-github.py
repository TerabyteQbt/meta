#!/usr/bin/env python

# This script's purpose is to update the HEAD to point to the correct branches in github for a given meta version.
# dependencies: sh
# To run:  virtualenv .ve; source .ve/bin/activate; pip install sh; ./bin/update-github.py

import argparse
import json
import os
import sh
import sys


parser = argparse.ArgumentParser()
parser.add_argument("--user", help="github username", default=os.environ.get("USER"))
parser.add_argument("--organization", help="github organization under which repositories live")
parser.add_argument("--manifest-tag", help="tag used to name this constellation of branches (suggest using manifest sha1)", default="UNKNOWN-PROVIDENCE")
parser.add_argument("--token-file", help="location where your github api token is stored (defailt ~/.github-api-token)", default=os.path.expanduser("~/.github-api-token"))

args = parser.parse_args()

GITHUB_PREFIX = "https://api.github.com/repos"

manifest = json.load(sys.stdin)
token = None
with open(args.token_file) as f:
    token = f.read().rstrip()

for repo in manifest:
    sha = manifest[repo]["version"]
    branch = "%s-%s-%s" % (args.manifest_tag, repo, sha)
    # first create branch pointing to commit, which must already exist
    # TODO: detect missing branch and raise error
    # https://8thlight.com/blog/sandro-padin/2015/06/08/help-i-just-force-pushed-to-master.html
    curl_args = ["-H", "Accept: application/json", "-H", "Content-Type: application/json", "-H", "Authorization: token %s" % token, "-X", "POST", "-d", "{\"ref\":\"refs/heads/%s\", \"sha\":\"%s\"}" % (branch, sha), "%s/%s/%s/git/refs" % (GITHUB_PREFIX, args.organization, repo)]
    print("running: curl with args %s" % " ".join(curl_args))
    sh.curl(curl_args, _fg=True)

# we do this step last so a failure in any component in the earlier step will
# prevent moving any components HEADs
for repo in manifest:
    sha = manifest[repo]["version"]
    branch = "%s-%s-%s" % (args.manifest_tag, repo, sha)
    # now we are going to update HEADs to point to our newly created branches
    # https://developer.github.com/changes/2012-10-24-set-default-branch/
    curl_args = ["-H", "Accept: application/json", "-H", "Content-Type: application/json", "-H", "Authorization: token %s" % token, "-X", "POST", "-d", "{\"name\":\"%s\", \"default_branch\":\"%s\"}" % (repo, branch), "%s/%s/%s" % (GITHUB_PREFIX, args.organization, repo)]
    sh.curl(curl_args, _fg=True)
