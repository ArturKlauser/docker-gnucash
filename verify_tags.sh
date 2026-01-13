#!/bin/bash

# Simulate the input from steps.meta.outputs.tags
TAGS_INPUT="user/repo:latest,user/repo:1.2.3,user/repo:v1"

echo "Input Tags: $TAGS_INPUT"

# Logic to convert comma-separated tags to -t arguments
IFS=',' read -ra TAG_ARRAY <<< "$TAGS_INPUT"
TAG_ARGS=""
for tag in "${TAG_ARRAY[@]}"; do
  TAG_ARGS="$TAG_ARGS -t $tag"
done

# Trim leading space if necessary (though shell handles spaces in args fine, mostly for display)
TAG_ARGS=${TAG_ARGS:1}

echo "Generated Arguments: $TAG_ARGS"

# Verification
EXPECTED="-t user/repo:latest -t user/repo:1.2.3 -t user/repo:v1"
if [ "$TAG_ARGS" == "$EXPECTED" ]; then
  echo "SUCCESS: Tags parsed correctly."
else
  echo "FAILURE: Expected '$EXPECTED', got '$TAG_ARGS'"
fi
