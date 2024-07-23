#!/bin/sh

# set -xe # For debuguing if ever needed.

# Make sure to set your $GITHUB_ACTIVITY_REPO env var
#
# For example :
# export GITHUB_ACTIVITY_REPO=git@github.com:<your-github-handle>/activity-repo.git
#
# you can chose to have it private or not.

write_to_logfile(){
    local log_file="$1"
    local local_repo_path="$2"
    local remote_url="$3"
    local commit_hash="$4"
    local timestamp="$5"

    # Create the track log file if it doesn't exist
    [ ! -f "$log_file" ] && touch "$log_file"
    # Write information to the log file
    /bin/echo -ne "path=$local_repo_path::remote=$remote_url::hash-$commit_hash::at-$timestamp \n" >> "$log_file"
}

commit_and_push_activity(){
    local clone_dir="$1"
    local log_file="$2"
    local tracked_month="$3"

    # Commit and push the changes
    cd "$clone_dir"
    git add "$(basename "$log_file")"
    git commit -m "update activity log for $tracked_month"
    git push origin master
}

# Create the repo activity-repo in your github.
# This should be in:
# $HOME/.config/git/template/hooks/post-commit (don't forget the +x)
# and
# set in the global config as a template dir
# so for each project/.git/ it will create it
# with :
# git config --global init.templateDir '~/.config/git/template'
#
# For already created local project just run : 'git init' to reset/add
# what was missing.
#
# We only want to track activity from foreign remote other than github.com
git_track_hook(){
    # Check if it's from GitHub or not
    # local remote_url="$(git remote get-url origin)"
    local remote_url=$(git remote get-url origin)
    /bin/echo "$remote_url" | grep -q "github.com" && return

    # We exit if the remote url is empty
    # This happens a lot when we're just creating repository
    if [ ${#remote_url} -lt 3 ]; then
        return
    fi

    # local variables
    local commit_hash=$(git rev-parse HEAD)
    local local_repo_path=$(basename "$(git rev-parse --show-toplevel)")
    # don't track the tracker project itself
    /bin/echo "$local_repo_path" | grep -q "activity-repo" && return

    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local tracked_month=$(date +"%Y-%m")
    local clone_dir="$HOME/activity-repo"
    local log_file="$clone_dir/.git_activity_for_$tracked_month"

    # Clone the github repository if not present in $HOME
    [ ! -d "$clone_dir" ] && git clone "$GITHUB_ACTIVITY_REPO" "$clone_dir"

    # we don't want to continue if the commit hash is already in the file
    grep -i $commit_hash $log_file && return

    /bin/echo "(git-track) post-commit hook processing..."

    write_to_logfile $log_file $local_repo_path $remote_url $commit_hash $timestamp

    commit_and_push_activity $clone_dir $log_file $tracked_month

    /bin/echo "(git-track) post-commit hook success."
}
