#!/usr/bin/env bash

# requires curl & jq

# upstreamCommit --purpur HASH
# flag: --purpur HASH - (Optional) the commit hash to use for comparing commits between purpur (PurpurMC/Purpur/compare/HASH...HEAD)

function getCommits() {
    curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/"$1"/compare/"$2"..."$3" | jq -r '.commits[] | "'"$1"'@\(.sha[:7]) \(.commit.message | split("\r\n")[0] | split("\n")[0])"'
}

(
set -e
PS1="$"

purpurHash=$(git diff gradle.properties | awk '/^-purpurCommit =/{print $NF}')

TEMP=$(getopt --long purpur: -o "" -- "$@")
eval set -- "$TEMP"
while true; do
    case "$1" in
        --purpur)
            purpurHash="$2"
            shift 2
            ;;
        *)
            break
            ;;
    esac
done

purpur=""
updated=""
logsuffix=""

# Purpur updates
if [ -n "$purpurHash" ]; then
    newHash=$(git diff gradle.properties | awk '/^+purpurCommit =/{print $NF}')
    purpur=$(getCommits "PurpurMC/Purpur" "$purpurHash" $(echo $newHash | grep . -q && echo $newHash || echo "HEAD"))

    # Updates found
    if [ -n "$purpur" ]; then
        updated="Purpur"
        logsuffix="$logsuffix\n\nPurpur Changes:\n$purpur"
    fi
fi

disclaimer="Upstream has released updates that appear to apply and compile correctly"
log="Updated Upstream ($updated)\n\n${disclaimer}${logsuffix}"

git add gradle.properties

echo -e "$log" | git commit -F -

) || exit 1