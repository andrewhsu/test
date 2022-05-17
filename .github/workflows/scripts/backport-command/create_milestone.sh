#!/usr/bin/env bash

# type-branch job
# Discover and create milestone step

if [[ $TARGET_MILESTONE == "auto" ]]; then
  major=$(echo $BACKPORT_BRANCH | grep -Eo '^v[0-9]{2}\.[0-9]{1,2}\.')

  list_released=$(gh api "repos/redpanda-data/redpanda/releases" --jq '.[] | select(.draft==false).name')
  latest_released=$(echo "$list_released" | grep -m1 -F "$major" || true)
  if [[ -z $latest_released ]]; then
    echo "INFO no previous releases found with major prefix $major."
    assignee_milestone="${major}1"
  else
    echo "INFO found previous releases with major prefix $major."
    assignee_milestone=$(echo $latest_released | awk -F. -v OFS=. '{$NF += 1; print; exit}')
  fi
else
  assignee_milestone=$TARGET_MILESTONE
fi
if [[ $(gh api "repos/$TARGET_ORG/$TARGET_REPO/milestones" --jq .[].title | grep "$assignee_milestone") == "" ]]; then
  # The below fails if something goes wrong
  gh api "repos/$TARGET_ORG/$TARGET_REPO/milestones" --silent --method POST -f title="$assignee_milestone"
  sleep 20 # wait for milestone creation to be propagated
fi
echo ::set-output name=milestone::$assignee_milestone
