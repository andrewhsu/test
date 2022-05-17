#!/usr/bin/env bash

# type-branch job
# Create issue step

source $SCRIPT_DIR/gh_wrapper.sh

if [[ -n $(echo $ORIG_LABELS | jq '.[] | select(.name == "kind/backport")') ]]; then
  msg="The issue is already a backport."

  gh issue comment "$ORIG_ISSUE_URL" \
    --repo "$TARGET_FULL_REPO" \
    --body "$msg"

  backport_failure "$msg"
fi

backport_issue_url=$(gh_issue_url)
if [[ -z $backport_issue_url ]]; then
  gh issue create --title "[$BACKPORT_BRANCH] $ORIG_TITLE" \
    --label "kind/backport" \
    --repo "$TARGET_ORG/$TARGET_REPO" \
    --assignee "$ORIG_ASSIGNEES" \
    --milestone "$TARGET_MILESTONE" \
    --body "Backport $ORIG_ISSUE_URL to branch $BACKPORT_BRANCH"
else
  gh issue comment "$ORIG_ISSUE_URL" \
    --repo "$TARGET_FULL_REPO" \
    --body "Backport issue already exists: $backport_issue_url"
fi
