#!/bin/bash
# This is the extracted bash code from dockerhub-cleanup.yml


DOCKERHUB_USERNAME='arturklauser'
DOCKERHUB_TOKEN='...'  # put in pwd or personal access token
REPO='gnucash'
DRY_RUN='false'
set -e # Exit on error

REPO_FULL="${DOCKERHUB_USERNAME}/${REPO}"
echo "Logging in to Docker Hub..."
ACCESS_TOKEN=$(curl -s -H "Content-Type: application/json" -X POST \
  -d "{\"identifier\": \"$DOCKERHUB_USERNAME\", \"secret\": \"$DOCKERHUB_TOKEN\"}" \
  https://hub.docker.com/v2/auth/token/ | jq -r .access_token)

if [ -z "$ACCESS_TOKEN" ] || [ "$ACCESS_TOKEN" == "null" ]; then
  echo "::error::Failed to get Docker Hub access token."
  exit 1
fi

echo "Fetching all image manifests for repository: $DOCKERHUB_USERNAME/$REPO"
# Loop through all pages of the API response
NEXT_URL="https://hub.docker.com/v2/namespaces/$DOCKERHUB_USERNAME/repositories/$REPO/tags?page_size=100"
# R2R: Problem: This only gives me tagged manifests, i.e., they all have a
#      non-empty/non-null name. But what I want to find are the untagged ones.
ALL_RESULTS="[]"
while [ -n "$NEXT_URL" -a "$NEXT_URL" != 'null' ]; do
  RESPONSE=$(curl -s -H "Authorization: JWT $ACCESS_TOKEN" "$NEXT_URL")
  PAGE_RESULTS=$(echo "$RESPONSE" | jq '.results')
  ALL_RESULTS=$(echo "$ALL_RESULTS" | jq --argjson page "$PAGE_RESULTS" '. + $page')
  NEXT_URL=$(echo "$RESPONSE" | jq -r '.next')
done

echo "--- ALL RESULTS (DEBUG) ---"
echo "$ALL_RESULTS" | jq .
echo "---------------------------"

echo "Identifying orphaned manifests (untagged and inactive)..."
# An image is an orphan if it has no tags AND its status is "inactive".
# This correctly ignores untagged manifests that are part of a tagged multi-arch manifest (which have status "active").
#ORPHANS=$(echo "$ALL_RESULTS" | jq -r '.[] | select(.name == null and .tag_status == "inactive") | .digest')
# R2R: Testing with 'latest', since there are no 'null' names from above query.
ORPHANS=$(echo "$ALL_RESULTS" | jq -r '.[] | select(.name == "latest" and .tag_status == "active") | .digest')

if [ -z "$ORPHANS" ]; then
  echo "No orphaned images found to delete."
  exit 0
fi

echo "Found the following orphaned digests to delete:"
echo "$ORPHANS"

# R2R: try some SHAs I got via the web UI (Image Management).
#ORPHANS="sha256:ac8936533b947fa1cc2732652dae915b2477563dfd09efa875a70823bbd5209c" # really orphaned
#ORPHANS="ac8936533b947fa1cc2732652dae915b2477563dfd09efa875a70823bbd5209c" # really orphaned
#ORPHANS="sha256:701a11e3ede1f49df30c5bc4fc0ece2b5c73fd8fc43a4627f440313c9f47a0e2" # latest

for DIGEST in $ORPHANS; do
  if [ "${DRY_RUN}" = "true" ]; then
    echo "DRY RUN: Would delete orphaned manifest: $DIGEST"
  else
    echo "Deleting orphaned manifest: $DIGEST"
    # Use the correct API endpoint for deleting manifests by digest
    DELETE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE \
      -H "Authorization: JWT $ACCESS_TOKEN" \
      "https://hub.docker.com/v2/repositories/$REPO_FULL/manifests/$DIGEST")
# R2R: This API call always results in error 404 (Not Found), even when I
#      use it with the SHAs I know are there from looking at the web UI.
# R2R: The URL in the new scheme also doesn't work.
#      It gives error 405 (Method Not Allowed).
#      "https://hub.docker.com/v2/namespaces/$DOCKERHUB_USERNAME/repositories/$REPO/manifests/$DIGEST")

    if [ "$DELETE_STATUS" -ge 200 ] && [ "$DELETE_STATUS" -lt 300 ]; then
      echo "Successfully deleted $DIGEST (HTTP status: $DELETE_STATUS)"
    else
      echo "::warning::Failed to delete $DIGEST (HTTP status: $DELETE_STATUS)"
    fi
  fi
done

echo "Cleanup complete."

# vim: set diffopt+=iwhiteall
