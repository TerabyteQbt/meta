#!/bin/bash

set -e
set -x

# This script is designed for non-interactive (such as cron-based) updating in place with the artifacts of a package.
# 
# usage:
# deploy-local-package-if-changed.sh <package> <output dir>
# qbt must be on your path, and must be able to find a qbt-manifest

PKG="$1"
OUTPUT_DIR="$2"
DATE="$(date +"%Y%m%d%H%M%S")"
NEW_DIR="$OUTPUT_DIR.$DATE"
CURRENT="unknown"

if [[ -z "$PKG" ]]; then
    echo "Must provide two arguments: $0 [PKG] [OUTPUT_DIR]" 1>&2
    exit 1
fi

if [[ -f "$OUTPUT_DIR/qbt.versionDigest" ]]; then
    CURRENT="$(cat $OUTPUT_DIR/qbt.versionDigest)"
fi

# calculate new version
NEWVERSION="$(qbt resolveManifestCumulativeVersions --package $PKG | cut -d' ' -f2)"

if [[ "$CURRENT" == "$NEWVERSION" ]]; then
    exit 0
fi
echo "Updating from version $CURRENT to version $NEWVERSION"

# confirm build succeeds first
qbt build --package $PKG --verify

OLD_PATH=""
function cleanup {
    echo "blah"
    #if [[ -n "$OLD_PATH" ]]; then
    #    rm -rf $OLD_PATH
    #fi
}
trap cleanup EXIT

qbt build --package $PKG --output "requested,directory,$NEW_DIR"

if [[ -e "$OUTPUT_DIR" ]]; then
    OLD_PATH="$(readlink -f $OUTPUT_DIR)"
fi
strace ln -s -n -f $NEW_DIR $OUTPUT_DIR

exit 0

