# backport-type job
# "Get type of backport (issue or pr)" step

#!/usr/bin/env bash

# Import gh_wrapper functions
source $SCRIPT_DIR/gh_wrapper.sh

gh_branch_exists() {
  [[ -n $(gh api "/repos/$TARGET_FULL_REPO/branches" --jq \
    '.[] | select(.name == '\"$BACKPORT_BRANCH\"')') ]] && return 0
  return 1
}

if [[ $(echo $CLIENT_PAYLOAD | jq 'has("pull_request")') == true ]]; then
  commented_on=pr
else
  commented_on=issue
fi

if ! gh_branch_exists; then
  msg="Branch name \"$BACKPORT_BRANCH\" not found."
  case $commented_on in
    issue)
      link=$ORIGINAL_ISSUE_URL
      ;;
    pr)
      link=$PR_NUMBER
      ;;
  esac

  gh $commented_on comment "$link" \
    --repo "$TARGET_FULL_REPO" \
    --body "$msg"

  backport_failure "$msg"
fi

echo "::set-output name=commented_on::$commented_on"
